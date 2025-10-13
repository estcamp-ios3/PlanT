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
    @Environment(\.dismiss) private var dismiss

    private enum Field: Hashable { case userName, nickName, email, password, passwordConfirm }
    @FocusState private var focus: Field?

    private var isSignUpValid: Bool {
        return userAuthModel.userName.count >= 2 &&
        userAuthModel.nickName.count >= 1 &&
        userAuthModel.email.count >= 4 &&
        userAuthModel.password.count >= 4 &&
        userAuthModel.passwordConfirm == userAuthModel.password
    }

    var body: some View {
        ScrollView {
            VStack(spacing: 16) {
                Text("PlanT에 오신 것을 환영합니다 🌱")
                    .font(.title2).bold()
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.horizontal)

                Group {
                    TextField("User Name", text: $userAuthModel.userName)
                    TextField("Nick Name", text: $userAuthModel.nickName)
                    TextField("E-mail", text: $userAuthModel.email)
                    SecureField("Password", text: $userAuthModel.password)
                    SecureField("Confirm Password", text: $userAuthModel.passwordConfirm)
                }
                .textFieldStyle(.roundedBorder)
                .padding(.horizontal)

                Button("회원가입") {
                    Task {
                        do {
                            try await authStore.signUp(user: userAuthModel)
                            dismiss()
                        } catch {
                            print("❌ 회원가입 실패:", error.localizedDescription)
                        }
                    }
                }
                .buttonStyle(.borderedProminent)
                .disabled(!isSignUpValid)
            }
            .padding(.top, 40)
        }
    }
}

#Preview {
    NavigationStack {
        SignUpView()
            .environmentObject(AuthStore())
    }
}
