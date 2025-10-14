//
//  SignUpView.swift
//  PlanT
//
//  Created by 이지훈 9/29/25.
//

import SwiftUI

struct SignUpView: View {
    @StateObject private var userAuthModel = UserAuthModel()
    @StateObject private var signUpViewModel = SignUpViewModel()
    @Environment(\.dismiss) private var dismiss   // ✅ 모달 닫기용
    
    // ✅ 유효성 검사
    private var isSignUpValid: Bool {
        print("UserName:", userAuthModel.userName.count)
        print("NickName:", userAuthModel.nickName.count)
        print("Email:", userAuthModel.email.count)
        print("Password:", userAuthModel.password)
        print("Confirm:", userAuthModel.passwordConfirm)
        return userAuthModel.userName.count >= 2 &&
               userAuthModel.nickName.count >= 1 &&
               userAuthModel.email.count >= 4 &&
               userAuthModel.password.count >= 4 &&
               userAuthModel.passwordConfirm == userAuthModel.password
    }
    
    var body: some View {
        ScrollView {
            VStack {
                Text("무엇부터 시작해야 할지 모르겠다면,\n'PlanT'와 함께.🌱")
                    .font(.title2)
                    .bold()
                .frame(maxWidth: .infinity, alignment: .leading)
            }
            .padding(.leading, 16)
            
            VStack {
                Text("User Name")
                    .signUpLabelStyle()
                    .padding(.top, 4)
                TextField("이름을 입력하세요", text: $userAuthModel.userName)
                    .authTextFieldStyle(.signUp)
                
                Text("Nick Name")
                    .signUpLabelStyle()
                    .padding(.top, 10)
                TextField("닉네임을 입력하세요", text: $userAuthModel.nickName)
                    .authTextFieldStyle(.signUp)
                
                Text("E-mail")
                    .signUpLabelStyle()
                    .padding(.top, 10)
                TextField("로그인에 사용할 Email을 입력하세요", text: $userAuthModel.email)
                    .authTextFieldStyle(.signUp)
                
                Text("Password")
                    .signUpLabelStyle()
                    .padding(.top, 10)
                SecureField("비밀번호를 입력하세요", text: $userAuthModel.password)
                    .authTextFieldStyle(.signUp)
                
                Text("Password Confirm")
                    .signUpLabelStyle()
                    .padding(.top, 10)
                SecureField("입력한 비밀번호를 확인합니다", text: $userAuthModel.passwordConfirm)
                    .authTextFieldStyle(.signUp)
            }
            .padding(.horizontal)
            VStack {
                Text("Selected Mate")
                    .padding(.top, 10)
                    .signUpLabelStyle()
            }
            .padding(.horizontal)
            
            MateView(selectedMate: $signUpViewModel.selectedMate)
                .padding(.bottom, 16)
            
            Button {
                // TODO: 실제 회원가입 처리 로직 넣기
                dismiss()   // 모달 닫기
            } label: {
                Text("회원가입")
            }
            .plantPrimaryButton()
            .padding(.horizontal, 16)
            .disabled(!isSignUpValid)
        }
        .padding(.top, 40)
    }
}
#Preview {
    NavigationStack {
        SignUpView()
            .environmentObject(AuthStore())
    }
}
