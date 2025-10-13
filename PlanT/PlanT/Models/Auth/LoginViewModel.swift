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
    func signIn() async {
        isLoading = true
        errorMessage = nil
        do {
            try await authStore.signIn(email: email, password: password)
            print("✅ 로그인 성공:", email)
        } catch {
            errorMessage = "로그인 실패: \(error.localizedDescription)"
            print("❌ \(error)")
        }
        isLoading = false
    }

    // ✅ 세션 복원
    func restoreSession() async {
        await authStore.restoreSession()
    }
}
