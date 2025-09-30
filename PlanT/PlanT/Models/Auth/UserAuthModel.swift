//
//  UserAuthModel.swift
//  PlanT
//
//  Created by 이지훈 on 9/29/25.
//

import Foundation
import Combine
import SwiftUI

final class UserAuthModel: ObservableObject {
    @Published var userName: String = ""
    @Published var nickName: String = ""
    @Published var email: String = ""
    @Published var password: String = ""
}


// 텍스트 필드 모디파이어 임시
struct AuthTextFieldModifier: ViewModifier {
    enum Style {
        case signIn // 로그인 텍스트 필드
        case signUp // 회원가입 텍스트 필드
    }
    
    var style: Style
    
    func body(content: Content) -> some View {
        switch style {
        case .signIn:
            content
                .padding()
                .overlay(
                    RoundedRectangle(cornerRadius: 24)
                        .stroke(Color.gray400, lineWidth: 2)
                )
                .font(.system(size: 16, weight: .bold))
        case .signUp:
            content
                .padding(12)
                .overlay(
                    RoundedRectangle(cornerRadius: 24)
                        .stroke(Color.gray400, lineWidth: 2)
                )
                .font(.system(size: 16, weight: .bold))
        }
    }
}

extension View {
    func authTextFieldStyle(_ style: AuthTextFieldModifier.Style = .signIn) -> some View {
        self.modifier(AuthTextFieldModifier(style: style))
    }
}
