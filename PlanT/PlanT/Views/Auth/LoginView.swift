//
//  LoginView.swift
//  PlanT
//
//  Created by 이지훈 9/29/25.
//
import SwiftUI

struct LoginView: View {
    @State private var userAuthModel = UserAuthModel()
    
    var body: some View {
        VStack(spacing: 0) {
            Image("PlanTLogo")
                .resizable()
                .scaledToFit()
                .frame(width: 500, height: 500)
                .padding(.top, 10)
            
            // 입력 필드 / 레이아웃 스타일은 임시
            VStack(spacing: 16) {
                TextField("ID", text: $userAuthModel.email)
                    .authTextFieldStyle()

                SecureField("PW", text: $userAuthModel.password)
                    .authTextFieldStyle()
                
                // 로그인 버튼
                Button(action: {
                }) {
                    Text("로그인")
                }
                .plantPrimaryButton()
                
                // 회원가입 버튼
                Button(action: {
                }) {
                    Text("Sign Up")
                        .foregroundColor(.black)
                }
            }
            .padding(.horizontal, 24)
            
        }
    }
}

#Preview {
    NavigationView {
        LoginView()
    }
}
