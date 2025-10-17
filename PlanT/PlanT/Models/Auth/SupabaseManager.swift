//
//  SupabaseManager.swift
//  PlanT
//
//  Created by 이지훈 on 10/13/25.
//

// supabase 연결관리

import Foundation
import Supabase

// MARK: - 사용자 모델
struct User {
    let userName: String?
    let nickName: String?
    let email: String?
    let mate: String?
}

// MARK: - 전역 Supabase 클라이언트 (모든 곳에서 공용 사용)
let supabaseClient = SupabaseClient(
    supabaseURL: URL(string: "https://zgkbeonrsmpqxmdluuke.supabase.co")!,
    supabaseKey: "sb_publishable_Du9vakPpo5HS9voxeMkoRQ_FnGpIa5P"
)

// MARK: - Supabase 관리 객체
struct SupabaseManager {

    // MARK: - 로그인
    func signIn(email: String, password: String) async throws -> User {
        let session = try await supabaseClient.auth.signIn(email: email, password: password)

        let meta = session.user.userMetadata
        let user = User(
            userName: meta["userName"]?.stringValue,
            nickName: meta["nickName"]?.stringValue,
            email: session.user.email,
            mate: meta["mate"]?.stringValue
        )
        return user
    }

    // MARK: - 회원가입
    func signUp(user: UserAuthModel) async throws {
        guard user.password == user.passwordConfirm else {
            throw AuthError.passwordsDoNotMatch
        }

        let meta: [String: AnyJSON] = [
            "userName": .string(user.userName),
            "nickName": .string(user.nickName),
            "mate": .string(user.mate)
        ]

        _ = try await supabaseClient.auth.signUp(
            email: user.email,
            password: user.password,
            data: meta
        )
    }

    // MARK: - 로그아웃
    func signOut() async throws {
        try await supabaseClient.auth.signOut()
    }

    // MARK: - 세션 복원
    func restoreSession() async throws -> Session? {
        try await supabaseClient.auth.session
    }

    // MARK: - 프로필 불러오기
    func loadProfileFallback(for userId: String) async throws -> Profile {
        let response = try await supabaseClient
            .from("profiles")
            .select()
            .eq("id", value: userId)
            .single()
            .execute()

        return try JSONDecoder().decode(Profile.self, from: response.data)
    }
}
