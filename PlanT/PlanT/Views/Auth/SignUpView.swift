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
                .font(.system(size: 26, weight: .bold))
                .frame(maxWidth: .infinity, alignment: .leading)
            
            VStack {
                Text("User Name")
                    .font(.system(size: 24, weight: .bold))
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(6)
                TextField("이름을 입력하세요", text: $userAuthModel.userName)
                    .authTextFieldStyle()
                
                Text("Nick Name")
                    .font(.system(size: 24, weight: .bold))
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(6)
                TextField("닉네임을 입력하세요", text: $userAuthModel.nickName)
                    .authTextFieldStyle()
                
                Text("E-mail")
                    .font(.system(size: 24, weight: .bold))
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(6)
                TextField("로그인에 사용할 Email을 입력하세요", text: $userAuthModel.email)
                    .authTextFieldStyle()
                
                Text("Password")
                    .font(.system(size: 24, weight: .bold))
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(6)
                TextField("비밀번호를 입력하세요", text: $userAuthModel.password)
                    .authTextFieldStyle()
            }
        }
        .padding()
    }
}

#Preview {
    NavigationStack {
        SignUpView()
    }
}
