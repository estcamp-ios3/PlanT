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
        VStack(spacing: 40) {
            
            VStack(spacing: 16) {
                //                Image("에셋 로고 이미지 파일 이름")
                //                    .resizable()
                //                    .scaledToFit()
                //                    .frame(width: 120, height: 120)
            }
            //            .padding(.top, 60)
            
            // 입력 필드 / 레이아웃 스타일은 임시
            VStack(spacing: 15) {
                TextField("ID", text: $userAuthModel.username)
                    .padding()
                    .background(Color(.systemGray6))
                    .cornerRadius(30)
                    .textInputAutocapitalization(.never)
                    .autocorrectionDisabled(true)
                
                SecureField("PW", text: $userAuthModel.password)
                    .padding()
                    .background(Color(.systemGray6))
                    .cornerRadius(30)
                    .textInputAutocapitalization(.never)
                    .autocorrectionDisabled(true)
            }
            .padding(.horizontal, 25)
            
            // 로그인 버튼
            Button(action: {
            }) {
                Text("로그인")
                    .bold()
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.green)
                    .cornerRadius(20)
            }
            .padding(.horizontal, 25)
            
            // 회원가입 버튼
            Button(action: {
            }) {
                Text("Sign Up")
                    .foregroundColor(.black)
            }
            
            Spacer()
        }
    }
}

#Preview {
    NavigationView {
        LoginView()
    }
}
