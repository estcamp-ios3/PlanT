//
//  LoginView.swift
//  PlanT
//
//  Created by 이지훈 9/29/25.
//

import SwiftUI

struct LoginView: View {
    @StateObject private var userAuthModel = UserAuthModel()
    @State private var isPresentingSignUp = false
    @State private var isLoggedIn = false
    
    @State private var keyboardHeight: CGFloat = 0
    @State private var isKeyboardVisible: Bool = false
    @State private var lockedKeyboardHeight: CGFloat = 0
    
    // ✅ FocusState: 로그인 필드 체인
        private enum Field: Hashable { case id, pw }
        @FocusState private var focus: Field?
    
    var body: some View {
        Group {
            if isLoggedIn {
                // 뷰를 완전히 교체 (모달 X)
                ContentView()
                    .transition(.opacity)
            } else {
                VStack(spacing: 0) {
                    Image("PlanTLogo")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 400, height: 500)
                        .padding(.top, 10)
                    
                    // 입력 필드
                    VStack(spacing: 16) {
                        TextField("ID", text: $userAuthModel.email)
                            .authTextFieldStyle(.signIn)
                            .focusRoute($focus, equals: .id, submit: .next, next: .pw)
                        
                        SecureField("PW", text: $userAuthModel.password)
                            .authTextFieldStyle(.signIn)
                            .focusRoute($focus, equals: .pw, submit: .go, next: nil)
                        
                        // 로그인 버튼
                        Button {
                            withAnimation(.easeInOut(duration: 0.25)) { // 페이드 애니메이션
                                isLoggedIn = true   // 전환 트리거
                            }// 로그인 성공시(supabase 나중에 연결)
                        } label: {
                            Text("로그인")
                        }
                        .plantPrimaryButton()
                        
                        // 회원가입 버튼
                        Button {
                            isPresentingSignUp = true
                        } label: {
                            Text("Sign Up")
                                .foregroundColor(.black)
                        }
                        .sheet(isPresented: $isPresentingSignUp) {
                            SignUpView()
                                .presentationDetents([.large])
                                .presentationDragIndicator(.visible)
                        }
                    }
                    .padding(.horizontal, 24)
                    .padding(.bottom, keyboardHeight)
                }
                                .ignoresSafeArea(.keyboard, edges: .bottom)
                                .onDisappear { removeKeyboardObserver() }
                            }
                        }
                    }
    
    
    // MARK: - Keyboard 옵저버
    private func observeKeyboard() {
        NotificationCenter.default.addObserver(
            forName: UIResponder.keyboardWillShowNotification,
            object: nil, queue: .main
        ) { note in
            guard let frame = note.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? CGRect else { return }
            let bottomInset = Self.keyWindow()?.safeAreaInsets.bottom ?? 0
            let height = max(0, frame.height - bottomInset)
            
            // ⬇️ 이미 키보드가 올라와 있으면 무시 (떨림 방지) 가 일단 안됨 *차후 수정 예정
            if isKeyboardVisible {
                return
            }
            
            lockedKeyboardHeight = height
            withAnimation(.easeOut(duration: 0.25)) {
                keyboardHeight = lockedKeyboardHeight
                isKeyboardVisible = true
            }
        }
        
        NotificationCenter.default.addObserver(
            forName: UIResponder.keyboardWillHideNotification,
            object: nil, queue: .main
        ) { _ in
            withAnimation(.easeOut(duration: 0.20)) {
                keyboardHeight = 0
                isKeyboardVisible = false
                lockedKeyboardHeight = 0
            }
        }
    }
    
    private func removeKeyboardObserver() {
        NotificationCenter.default.removeObserver(self,
                                                  name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.removeObserver(self,
                                                  name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    private static func keyWindow() -> UIWindow? {
        UIApplication.shared.connectedScenes
            .compactMap { $0 as? UIWindowScene }
            .flatMap { $0.windows }
            .first { $0.isKeyWindow }
    }
}

#Preview {
    NavigationView {
        LoginView()
    }
}
