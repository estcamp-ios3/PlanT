//
//  UserAuthModel.swift
//  PlanT
//
//  Created by 이지훈 on 9/29/25.
//

import Foundation
import Combine

/// 회원가입/로그인 입력값을 보관하는 순수 모델
final class UserAuthModel: ObservableObject {
    @Published var userName: String = ""
    @Published var nickName: String = ""
    @Published var email: String = ""
    @Published var password: String = ""
    @Published var passwordConfirm: String = ""
    @Published var mate: String = ""
}

enum AuthError: Error, LocalizedError {
    case passwordsDoNotMatch
    case emailAlreadyExists

    var errorDescription: String? {
        switch self {
        case .passwordsDoNotMatch:
            return "비밀번호가 일치하지 않습니다."
        case .emailAlreadyExists:
            return "이미 등록된 이메일입니다."
        }
    }
}
