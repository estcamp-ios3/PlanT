//
//  SignUpView.swift
//  PlanT
//
//  Created by 이지훈 9/29/25.
//

import SwiftUI

struct SignUpView: View {
    @State private var userAuthModel = UserAuthModel()
    
    var body: some View {
        VStack {
            Text("무엇부터 시작해야 할지 모르겠다면,\n'PlanT'와 함께.🌱")
                .font(.system(size: 22, weight: .bold))
                .frame(maxWidth: .infinity, alignment: .leading)
        }
        .padding(.top, 16)
        .padding(.leading, 16)
        
        VStack {
            Text("User Name")
                .font(.system(size: 22, weight: .bold))
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.top, 4)
                .padding(.leading, 8)
            TextField("이름을 입력하세요", text: $userAuthModel.userName)
                .authTextFieldStyle(.signUp)
            
            Text("Nick Name")
                .font(.system(size: 22, weight: .bold))
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.leading, 8)
            TextField("닉네임을 입력하세요", text: $userAuthModel.nickName)
                .authTextFieldStyle(.signUp)
            
            Text("E-mail")
                .font(.system(size: 22, weight: .bold))
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.leading, 8)
            TextField("로그인에 사용할 Email을 입력하세요", text: $userAuthModel.email)
                .authTextFieldStyle(.signUp)
            
            Text("Password")
                .font(.system(size: 22, weight: .bold))
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.leading, 8)
            SecureField("비밀번호를 입력하세요", text: $userAuthModel.password)
                .authTextFieldStyle(.signUp)
            
            Text("Password Confirm")
                .font(.system(size: 22, weight: .bold))
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.leading, 8)
            SecureField("입력한 비밀번호를 확인합니다", text: $userAuthModel.password)
                .authTextFieldStyle(.signUp)
        }
        .padding(.horizontal)
        VStack {
            Text("Selected Mate")
                .font(.system(size: 22, weight: .bold))
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.leading, 8)
        }
        .padding(.horizontal)
        
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 16) {
                Image("MrGrrr")
                    .mateStyle()
                
                Image("MrNibble")
                    .mateStyle()
                
                Image("MrPurr")
                    .mateStyle()
                
                Image("MrBarky")
                    .mateStyle()
                
                Image("MrZippy")
                    .mateStyle()
                
                Image("MrWooly")
                    .mateStyle()
            }
        }
        .padding(.bottom, 16)
        
        Button(action: {
        }) {
            Text("회원가입")
        }
        .plantPrimaryButton()
        .padding(.horizontal, 16)
    }
}
#Preview {
    NavigationStack {
        SignUpView()
    }
}
