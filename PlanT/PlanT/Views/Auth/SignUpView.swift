//
//  SignUpView.swift
//  PlanT
//
//  Created by 이지훈 9/29/25.
//

import SwiftUI

struct SignUpView: View {
    @EnvironmentObject var authStore: AuthStore
    @StateObject private var userAuthModel = UserAuthModel()
    @StateObject private var signUpViewModel = SignUpViewModel()
    @Environment(\.dismiss) private var dismiss   // ✅ 모달 닫기용
    
    @State private var errorMessage: String? = nil // 회원가입용 에러 메시지
    
    private enum Field: Hashable { case userName, nickName, email, password, passwordConfirm }
    @FocusState private var focus: Field?
    
    // ✅ 유효성 검사 (mate 선택까지 포함)
    private var isSignUpValid: Bool {
        userAuthModel.userName.count >= 2 &&
        userAuthModel.nickName.count >= 1 &&
        userAuthModel.email.count >= 4 &&
        userAuthModel.password.count >= 4 &&
        userAuthModel.passwordConfirm.count == userAuthModel.password.count &&
        signUpViewModel.selectedMate != nil
    }
    
    var body: some View {
        ScrollView {
            VStack {
                Text("무엇부터 시작해야 할지 모르겠다면,\n'PlanT'와 함께.🌱")
                    .font(.title2)
                    .bold()
                    .frame(maxWidth: .infinity, alignment: .leading)
            }
            .padding(.leading, vertical4)
            
            VStack {
                Text("User Name")
                    .signUpLabelStyle()
                    .padding(.top, vertical1)
                TextField("이름을 입력하세요", text: $userAuthModel.userName)
                    .authTextFieldStyle(.signUp)
                    .focusRoute($focus, equals: .userName, submit: .next, next: .nickName)
                
                Text("Nick Name")
                    .signUpLabelStyle()
                    .padding(.top, vertical2)
                TextField("닉네임을 입력하세요", text: $userAuthModel.nickName)
                    .authTextFieldStyle(.signUp)
                    .focusRoute($focus, equals: .nickName, submit: .next, next: .email)
                
                Text("E-mail")
                    .signUpLabelStyle()
                    .padding(.top, vertical2)
                TextField("로그인에 사용할 Email을 입력하세요", text: $userAuthModel.email)
                    .authTextFieldStyle(.signUp)
                    .focusRoute($focus, equals: .email, submit: .next, next: .password)
                
                Text("Password")
                    .signUpLabelStyle()
                    .padding(.top, vertical2)
                SecureField("비밀번호를 입력하세요", text: $userAuthModel.password)
                    .authTextFieldStyle(.signUp)
                    .focusRoute($focus, equals: .password, submit: .next, next: .passwordConfirm)
                
                Text("Password Confirm")
                    .signUpLabelStyle()
                    .padding(.top, vertical2)
                SecureField("입력한 비밀번호를 확인합니다", text: $userAuthModel.passwordConfirm)
                    .authTextFieldStyle(.signUp)
                    .focusRoute($focus, equals: .passwordConfirm, submit: .done, next: nil)
            }
            .padding(.horizontal)
            
            VStack {
                Text("Selected Mate")
                    .padding(.top, vertical2)
                    .signUpLabelStyle()
            }
            .padding(.horizontal)
            
            // ✅ 메이트 선택
            MateView(selectedMate: $signUpViewModel.selectedMate)
                .padding(.bottom, vertical4)
            // ✅ 선택한 mate → UserAuthModel에 동기화 (서버 전송 용)
                .onChange(of: signUpViewModel.selectedMate) { _, newValue in
                    userAuthModel.mate = newValue?.rawValue ?? ""
                    print("🐾 선택된 메이트: \(userAuthModel.mate)")
                }
            
            // ✅ 에러 메시지 표시
            if let error = errorMessage {
                Text(error)
                    .foregroundColor(.red)
                    .font(.system(size: vertical4, weight: .semibold))
                    .padding(.top, 8)
            }
            
            Button("회원가입") {
                Task {
                    do {
                        try await authStore.signUp(user: userAuthModel)
                        dismiss()
                    } catch let error as AuthError {
                        // ✅ 우리가 만든 AuthError를 우선 처리
                        errorMessage = error.localizedDescription
                    } catch {
                        // 기타 에러는 그대로 표시
                        errorMessage = error.localizedDescription
                    }
                }
            }
            .plantPrimaryButton()
            .padding(.horizontal, vertical4)
            .disabled(!isSignUpValid)
            .opacity(isSignUpValid ? 1 : 0.5) // 시각적 피드백

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
