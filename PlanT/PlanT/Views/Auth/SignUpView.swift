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

    // ✅ 회원가입 에러 메시지 + 토스트 제어
    @State private var errorMessage: String? = nil
    @State private var showToast: Bool = false

    private enum Field: Hashable { case userName, nickName, email, password, passwordConfirm }
    @FocusState private var focus: Field?

    // ✅ 유효성 검사 (mate 선택 포함)
    private var isSignUpValid: Bool {
        userAuthModel.userName.count >= 2 &&
        userAuthModel.nickName.count >= 1 &&
        isValidEmail(userAuthModel.email) &&
        userAuthModel.password.count >= 6 &&
        userAuthModel.passwordConfirm == userAuthModel.password &&
        signUpViewModel.selectedMate != nil
    }
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading) {
                Text("무엇부터 시작해야 할지 모르겠다면,\n'PlanT'와 함께.🌱")
                    .font(.title2)
                    .bold()
                    .frame(maxWidth: .infinity, alignment: .leading)
            }
            .padding(.leading, vertical4)
            
            VStack(alignment: .leading, spacing: vertical3) {
                
                // MARK: - User Name
                fieldLabel("User Name", hint: userAuthModel.userName.count < 2 ? "2글자 이상 입력해주세요." : nil)
                TextField("이름을 입력하세요", text: $userAuthModel.userName)
                    .authTextFieldStyle(.signUp)
                    .focusRoute($focus, equals: .userName, submit: .next, next: .nickName)
                
                // MARK: - Nick Name
                fieldLabel("Nick Name", hint: userAuthModel.nickName.isEmpty ? "1글자 이상 입력해주세요." : nil)
                TextField("닉네임을 입력하세요", text: $userAuthModel.nickName)
                    .authTextFieldStyle(.signUp)
                    .focusRoute($focus, equals: .nickName, submit: .next, next: .email)
                
                // MARK: - E-mail
                fieldLabel("E-mail", hint: !isValidEmail(userAuthModel.email) && !userAuthModel.email.isEmpty ? "올바른 이메일 형식이 아닙니다." : nil)
                TextField("로그인에 사용할 Email을 입력하세요", text: $userAuthModel.email)
                    .authTextFieldStyle(.signUp)
                    .focusRoute($focus, equals: .email, submit: .next, next: .password)
                
                // MARK: - Password
                fieldLabel("Password", hint: userAuthModel.password.count < 4 && !userAuthModel.password.isEmpty ? "연속되지 않은 문자, 숫자 조합으로 6자 이상 입력해주세요." : nil)
                SecureField("비밀번호를 입력하세요", text: $userAuthModel.password)
                    .authTextFieldStyle(.signUp)
                    .focusRoute($focus, equals: .password, submit: .next, next: .passwordConfirm)
                
                // MARK: - Password Confirm
                fieldLabel("Password Confirm",
                           hint: (!userAuthModel.passwordConfirm.isEmpty && userAuthModel.passwordConfirm != userAuthModel.password)
                           ? "같은 비밀번호를 입력해주세요." : nil)
                SecureField("입력한 비밀번호를 확인합니다", text: $userAuthModel.passwordConfirm)
                    .authTextFieldStyle(.signUp)
                    .focusRoute($focus, equals: .passwordConfirm, submit: .done, next: nil)
            }
            .padding(.horizontal)
            
            VStack(alignment: .leading) {
                Text("Selected Mate")
                    .padding(.top, vertical2)
                    .signUpLabelStyle()
            }
            .padding(.horizontal)
            
            // MARK: - 메이트 선택
            MateView(selectedMate: $signUpViewModel.selectedMate)
                .padding(.bottom, vertical4)
                .onChange(of: signUpViewModel.selectedMate) { _, newValue in
                    userAuthModel.mate = newValue?.rawValue ?? ""
                    print("🐾 선택된 메이트: \(userAuthModel.mate)")
                }
            
            // MARK: - 회원가입 버튼
            Button("회원가입") {
                Task {
                    do {
                        errorMessage = nil
                        try await authStore.signUp(user: userAuthModel)
                        dismiss()
                    } catch let error as AuthError {
                        showToastMessage(error.localizedDescription)
                    } catch {
                        showToastMessage(error.localizedDescription)
                    }
                }
            }
            .plantPrimaryButton()
            .padding(.horizontal, vertical4)
            .disabled(!isSignUpValid)
            .opacity(isSignUpValid ? 1 : 0.5)
        }
        .padding(.top, 40)
        
        // ✅ 에러 토스트
        .authToast(
            isPresented: $showToast,
            message: $errorMessage,
            style: .error,
            alignment: .bottom,
            bottomPadding: -vertical3
        )
    }
    
    // MARK: - Helper Methods
    
    /// 이메일 정규식 검사
    private func isValidEmail(_ email: String) -> Bool {
        let emailRegEx = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,}"
        return NSPredicate(format: "SELF MATCHES %@", emailRegEx).evaluate(with: email)
    }
    
    /// 라벨 + 유효성 문구 뷰
    @ViewBuilder
    private func fieldLabel(_ title: String, hint: String?) -> some View {
        HStack(alignment: .firstTextBaseline, spacing: 6) {
            Text(title)
                .signUpLabelStyle()
                .fixedSize(horizontal: true, vertical: false)

            // 유효성 멘트 글자 스타일
            if let hint {
                Text(hint)
                    .font(.system(size: 12, weight: .medium))
//                    .foregroundColor(Color("567319")) // 글자색 앱 스타일
                    .foregroundColor(.red) // 글자색 red
                    .lineLimit(1)
                    .truncationMode(.tail)
                    .layoutPriority(1)
            }
        }
        .padding(.top, 2)
    }
    
    private func showToastMessage(_ message: String) {
        errorMessage = message
        withAnimation { showToast = true }
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.2) {
            withAnimation { showToast = false }
        }
    }
}

#Preview {
    NavigationStack {
        SignUpView()
            .environmentObject(AuthStore())
    }
}
