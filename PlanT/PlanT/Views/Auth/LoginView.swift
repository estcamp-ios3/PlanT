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

                Button {
                    // 로그인 액션
                } label: {
                    Text("로그인")
                }
                .plantPrimaryButton()

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
    }
}

#Preview {
    NavigationView { LoginView() }
}
