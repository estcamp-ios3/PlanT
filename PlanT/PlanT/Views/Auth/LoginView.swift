//
//  LoginView.swift
//  PlanT
//
//  Created by 이지훈 on 9/29/25.
//

import SwiftUI

struct LoginView: View {
    @EnvironmentObject var authStore: AuthStore
    @StateObject private var viewModel: LoginViewModel
    @State private var isPresentingSignUp = false

    @State private var keyboardHeight: CGFloat = 0
    @State private var isKeyboardVisible: Bool = false

    private enum Field: Hashable { case id, pw }
    @FocusState private var focus: Field?

    // ✅ 더미 계정 정보
    private let dummyEmail = "test@plant.com"
    private let dummyPassword = "Test123!"

    // ✅ 초기화 (authStore를 ViewModel에 전달)
    init(authStore: AuthStore) {
        _viewModel = StateObject(wrappedValue: LoginViewModel(authStore: authStore))
    }

    var body: some View {
        VStack(spacing: 0) {
            Image("PlanTLogo")
                .resizable()
                .scaledToFit()
                .frame(width: 400, height: 500)
                .padding(.top, 50)

            VStack(spacing: 0) {
                TextField("E-mail", text: $viewModel.email)
                    .authTextFieldStyle(.signIn)
                    .focusRoute($focus, equals: .id, submit: .next, next: .pw)
                    .padding(.bottom, vertical3)

                SecureField("Password", text: $viewModel.password)
                    .authTextFieldStyle(.signIn)
                    .focusRoute($focus, equals: .pw, submit: .go, next: nil)
                    .padding(.bottom, vertical4)

                Button {
                    Task { await viewModel.signIn() }
                } label: {
                    if viewModel.isLoading {
                        ProgressView()
                    } else {
                        Text("로그인")
                    }
                }
                .plantPrimaryButton()
                .disabled(viewModel.isLoading)
                .padding(.bottom, vertical5)

                Button("Sign Up") { isPresentingSignUp = true }
                    .padding(.bottom, 50)
                    .foregroundColor(.black)
                    .sheet(isPresented: $isPresentingSignUp) {
                        SignUpView()
                            .environmentObject(authStore)
                    }

                // ✅ 에러 표시
                if let error = viewModel.errorMessage {
                    Text(error)
                        .font(.footnote)
                        .foregroundColor(.red)
                }
            }
            .padding(.horizontal, vertical6)
            .padding(.bottom, isPresentingSignUp ? 0 : keyboardHeight)
        }
        .ignoresSafeArea(.keyboard, edges: .bottom)
        .onAppear {
            observeKeyboard()
            Task { await viewModel.restoreSession() }

            // ✅ 더미 계정 자동 입력
            viewModel.email = dummyEmail
            viewModel.password = dummyPassword
        }
        .onDisappear { removeKeyboardObserver() }
    }

    // MARK: - Keyboard 옵저버(간단)
    private func observeKeyboard() {
        NotificationCenter.default.addObserver(
            forName: UIResponder.keyboardWillShowNotification,
            object: nil, queue: .main
        ) { note in
            guard let frame = note.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? CGRect else { return }
            withAnimation(.easeOut(duration: 0.25)) {
                keyboardHeight = frame.height
                isKeyboardVisible = true
            }
        }

        NotificationCenter.default.addObserver(
            forName: UIResponder.keyboardWillHideNotification,
            object: nil, queue: .main
        ) { _ in
            withAnimation(.easeOut(duration: 0.25)) {
                keyboardHeight = 0
                isKeyboardVisible = false
            }
        }
    }

    private func removeKeyboardObserver() {
        NotificationCenter.default.removeObserver(self)
    }
}

#Preview {
    NavigationView {
        LoginView(authStore: AuthStore())
            .environmentObject(AuthStore())
    }
}
