//
//  UserAuthModel.swift
//  PlanT
//
//  Created by 이지훈 on 9/29/25.
//

import Foundation
import Combine
import Supabase

/// 회원가입/로그인 입력값을 보관하고 Supabase Auth를 호출하는 모델.
/// - NOTE: `@MainActor`를 붙이지 않았습니다.
///   이 모델은 주로 TextField 바인딩용이며, 네트워크 호출만 수행하고
///   내부에서 UI 상태를 변경하지 않습니다.
final class UserAuthModel: ObservableObject {
    // MARK: - Form Fields
    @Published var userName: String = ""
    @Published var nickName: String = ""
    @Published var email: String = ""
    @Published var password: String = ""
    @Published var passwordConfirm: String = ""
    @Published var mate: String = ""

    /// ✅ 전역 Supabase 인스턴스 사용
    private let client = supabaseClient

    // MARK: - 회원가입
    func signUp() async throws {
        guard password == passwordConfirm else {
            throw AuthError.passwordsDoNotMatch
        }

        let meta: [String: AnyJSON] = [
            "userName": .string(userName),
            "nickName": .string(nickName),
            "mate": .string(mate)
        ]

        let result = try await client.auth.signUp(
            email: email,
            password: password,
            data: meta
        )

        print("✅ 회원가입 성공: \(result.user.email ?? "Unknown")")
    }

    // MARK: - 로그인
    func signIn() async throws {
        let result = try await client.auth.signIn(
            email: email,
            password: password
        )
        print("✅ 로그인 성공: \(result.user.email ?? "Unknown")")
    }
}

enum AuthError: Error, LocalizedError {
    case passwordsDoNotMatch

    var errorDescription: String? {
        switch self {
        case .passwordsDoNotMatch:
            return "비밀번호가 일치하지 않습니다."
        }
    }
}
