//
//  UserAuthModel.swift
//  PlanT
//
//  Created by 이지훈 on 9/29/25.
//

import Foundation
import Combine
import Supabase

@MainActor
final class UserAuthModel: ObservableObject {
    @Published var userName: String = ""
    @Published var nickName: String = ""
    @Published var email: String = ""
    @Published var password: String = ""
    @Published var passwordConfirm: String = ""
    @Published var mate: String = ""

    private let client = SupabaseManager.shared.client

    // MARK: - 회원가입
    func signUp() async throws {
        guard password == passwordConfirm else {
            throw AuthError.passwordsDoNotMatch
        }

        let response = try await client.auth.signUp(
            email: email,
            password: password,
            data: [
                "userName": .string(userName),
                "nickName": .string(nickName),
                "mate": .string(mate)
            ]
        )

        // ✅ user는 non-optional, email은 optional
        print("✅ 회원가입 성공:", response.user.email ?? "Unknown")
    }

    // MARK: - 로그인
    func signIn() async throws {
        let response = try await client.auth.signIn(
            email: email,
            password: password
        )
        print("✅ 로그인 성공:", response.user.email ?? "Unknown")
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
