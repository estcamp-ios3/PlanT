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
    // MARK: - Published Properties
    @Published var isAuthenticated = false
    @Published var userEmail: String?
    @Published var userName: String?
    @Published var nickName: String?

    private let client = SupabaseManager.shared.client

    // MARK: - 로그인
    func signIn(email: String, password: String) async throws {
        let result = try await client.auth.signIn(email: email, password: password)
        isAuthenticated = true
        userEmail = result.user.email

        // ✅ Supabase에서 메타데이터 가져오기 (AnyJSON → String)
        let meta = result.user.userMetadata
        nickName = meta["nickName"]?.stringValue
        userName = meta["userName"]?.stringValue

        print("✅ 로그인 성공:", userEmail ?? "Unknown")
        print("✅ 불러온 닉네임:", nickName ?? "(없음)")
    }

    // MARK: - 회원가입
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
            nickName = user.nickName
            userName = user.userName
        }

        print("✅ 회원가입 완료:", user.email)
    }

    // MARK: - 로그아웃
    func signOut() async {
        do {
            try await client.auth.signOut()
            isAuthenticated = false
            userEmail = nil
            userName = nil
            nickName = nil
            print("👋 로그아웃 완료")
        } catch {
            print("❌ 로그아웃 실패:", error.localizedDescription)
        }
    }

    // MARK: - 세션 복원 (앱 재시작 시)
    func restoreSession() async {
        if let session = try? await client.auth.session {
            isAuthenticated = true
            userEmail = session.user.email

            // ✅ 세션 복원 시에도 메타데이터 다시 읽기
            let meta = session.user.userMetadata
            nickName = meta["nickName"]?.stringValue
            userName = meta["userName"]?.stringValue

            print("✅ 세션 복원:", userEmail ?? "Unknown")
            print("✅ 복원된 닉네임:", nickName ?? "(없음)")
        } else {
            isAuthenticated = false
            userEmail = nil
            userName = nil
            nickName = nil
            print("❌ 세션 없음")
        }
    }
}
