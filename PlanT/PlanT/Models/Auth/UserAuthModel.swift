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
    func body(content: Content) -> some View {
        content
            .padding()
            .background(Color(.systemGray6))
            .cornerRadius(24)
            .textInputAutocapitalization(.never)
            .autocorrectionDisabled(true)
    }
}

extension View {
    func authTextFieldStyle() -> some View {
        self.modifier(AuthTextFieldModifier())
    }
}
