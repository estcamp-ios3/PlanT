//
//  LoginView.swift
//  PlanT
//
//  Created by 이지훈 on 9/29/25.
//

import SwiftUI
import Supabase

struct LoginView: View {
    @EnvironmentObject var authStore: AuthStore
    @StateObject private var userAuthModel = UserAuthModel()
    @State private var isPresentingSignUp = false

    // 키보드 관련 상태
    @State private var keyboardHeight: CGFloat = 0
    @State private var isKeyboardVisible: Bool = false

    private enum Field: Hashable { case id, pw }
    @FocusState private var focus: Field?
    
    // ✅ 더미 계정 정보
    private let dummyEmail = "test@plant.com"
    private let dummyPassword = "Test123!"

    var body: some View {
        VStack(spacing: 0) {
            Image("PlanTLogo")
                .resizable()
                .scaledToFit()
                .frame(width: 400, height: 500)
                .padding(.top, 10)

            VStack(spacing: 16) {
                TextField("E-mail", text: $userAuthModel.email)
                    .authTextFieldStyle(.signIn)
                    .focusRoute($focus, equals: .id, submit: .next, next: .pw)

                SecureField("Password", text: $userAuthModel.password)
                    .authTextFieldStyle(.signIn)
                    .focusRoute($focus, equals: .pw, submit: .go, next: nil)

                Button("로그인") {
                    Task {
                        do {
                            try await authStore.signIn(email: userAuthModel.email,
                                                       password: userAuthModel.password)
                        } catch {
                            print("❌ 로그인 실패:", error.localizedDescription)
                        }
                    }
                }
                .plantPrimaryButton()

                Button("Sign Up") { isPresentingSignUp = true }
                    .foregroundColor(.black)
                    .sheet(isPresented: $isPresentingSignUp) {
                        SignUpView()
                            .environmentObject(authStore)
                    }
            }
            .padding(.horizontal, 24)
            .padding(.bottom, keyboardHeight)   // 키보드만큼 올림
        }
        .ignoresSafeArea(.keyboard, edges: .bottom)
        .onAppear {
            observeKeyboard()
            Task { await authStore.restoreSession() }
            
            // ✅ 앱 실행 시 자동으로 더미 계정 정보 입력
            userAuthModel.email = dummyEmail
            userAuthModel.password = dummyPassword // 더미 테스트 끝나면 지우기
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
        LoginView()
            .environmentObject(AuthStore()) // 프리뷰에서도 주입
    }
}
