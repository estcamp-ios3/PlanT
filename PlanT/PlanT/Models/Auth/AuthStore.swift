//
//  AuthStore.swift
//  PlanT
//
//  Created by 이지훈 on 10/14/25.
//

import Foundation
import Combine
import Supabase

/// 🔑 Supabase 인증 상태를 전역에서 관리
@MainActor
final class AuthStore: ObservableObject {
    @Published var isAuthenticated = false
    @Published var userEmail: String?

    private let client = SupabaseManager.shared.client

    // 로그인
    func signIn(email: String, password: String) async throws {
        let result = try await client.auth.signIn(email: email, password: password)
        isAuthenticated = true
        userEmail = result.user.email
        print("✅ 로그인 성공:", userEmail ?? "Unknown")
    }

    // 회원가입
    func signUp(user: UserAuthModel) async throws {
        guard user.password == user.passwordConfirm else {
            throw AuthError.passwordsDoNotMatch
        }

        let meta: [String: AnyJSON] = [
            "userName": .string(user.userName),
            "nickName": .string(user.nickName)
        ]

        let result = try await client.auth.signUp(
            email: user.email,
            password: user.password,
            data: meta
        )

        if result.session != nil {
            isAuthenticated = true
            userEmail = result.user.email
        }
        print("✅ 회원가입 완료:", user.email)
    }

    // 로그아웃
    func signOut() async {
        do {
            try await client.auth.signOut()
            isAuthenticated = false
            userEmail = nil
            print("👋 로그아웃 완료")
        } catch {
            print("❌ 로그아웃 실패:", error.localizedDescription)
        }
    }

    // 세션 복원
    func restoreSession() async {
        if let session = try? await client.auth.session {
            isAuthenticated = true
            userEmail = session.user.email
            print("✅ 세션 복원:", userEmail ?? "Unknown")
        } else {
            isAuthenticated = false
            userEmail = nil
            print("❌ 세션 없음")
        }
    }
}
