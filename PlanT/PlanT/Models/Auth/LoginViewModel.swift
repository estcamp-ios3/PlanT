//
//  LoginViewModel.swift
//  PlanT
//
//  Created by 이지훈 9/29/25.
//

import Foundation
import Combine

@MainActor
final class LoginViewModel: ObservableObject {
    @Published var email: String = ""
    @Published var password: String = ""
    @Published var isLoading: Bool = false
    @Published var errorMessage: String?

    // ✅ Supabase AuthStore를 의존성으로 받음
    private let authStore: AuthStore

    init(authStore: AuthStore) {
        self.authStore = authStore
    }

    // ✅ 로그인 처리 로직
    @MainActor
    func signIn() async {
        errorMessage = nil
        isLoading = true
        defer { isLoading = false }

        do {
            try await authStore.signIn(email: email, password: password)
        } catch {
            let raw = error.localizedDescription.lowercased()
            if raw.contains("invalid login credentials") {
                errorMessage = "이메일 또는 비밀번호가 올바르지 않습니다."
            } else {
                errorMessage = "로그인에 실패했습니다. 잠시 후 다시 시도해 주세요."
            }
        }
    }

    // ✅ 세션 복원
    @MainActor
    func restoreSession() async {
        await authStore.restoreSession()
    }
}
