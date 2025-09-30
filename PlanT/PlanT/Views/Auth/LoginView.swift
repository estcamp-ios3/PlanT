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

    var body: some View {
        VStack(spacing: 0) {
            Image("PlanTLogo")
                .resizable()
                .scaledToFit()
                .frame(width: 500, height: 500)
                .padding(.top, 10)

            // 입력 필드
            VStack(spacing: 16) {
                TextField("ID", text: $userAuthModel.email)
                    .authTextFieldStyle(.signIn)

                SecureField("PW", text: $userAuthModel.password)
                    .authTextFieldStyle(.signIn)

                // 로그인 버튼
                Button {
                    isLoggedIn = true // 로그인 성공시(파이어베이스 나중에 연결)
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
        }
        .fullScreenCover(isPresented: $isLoggedIn) {
            ContentView()
        }
    }
}

#Preview {
    NavigationView { LoginView() }
}
