//
//  AuthUIStyles.swift
//  PlanT
//
//  Created by 이지훈 on 9/30/25.
//

import SwiftUI

// 1) 폼 레이블 (회원가입 섹션 타이틀)
struct SignUpLabelModifier: ViewModifier {
    func body(content: Content) -> some View {
        content
            .font(.system(size: 22, weight: .bold))
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.leading, 8)
    }
}
extension View {
    func signUpLabelStyle() -> some View {
        modifier(SignUpLabelModifier())
    }
}

// 2) 텍스트필드 스타일 (로그인/회원가입)
struct AuthTextFieldModifier: ViewModifier {
    enum Style { case signIn, signUp }
    var style: Style

    func body(content: Content) -> some View {
        let stroke = RoundedRectangle(cornerRadius: 24)
            .stroke(Color.gray.opacity(0.4), lineWidth: 2)

        switch style {
        case .signIn: // 로그인
            return AnyView(
                content
                    .padding()
                    .overlay(stroke)
                    .font(.system(size: 16, weight: .bold))
                    .foregroundColor(.black)
            )
        case .signUp: // 회원가입
            return AnyView(
                content
                    .padding(12)
                    .overlay(stroke)
                    .font(.system(size: 16, weight: .bold))
                    .foregroundColor(.black)
            )
        }
    }
}
extension View {
    func authTextFieldStyle(_ style: AuthTextFieldModifier.Style = .signIn) -> some View {
        modifier(AuthTextFieldModifier(style: style))
    }
}

// 3) Mate 이미지 스타일
struct MateImageModifier: ViewModifier {
    var size: CGFloat = 100
    func body(content: Content) -> some View {
        content.frame(width: size, height: size)
    }
}
extension Image {
    func mateStyle(size: CGFloat = 100) -> some View {
        self
            .resizable()
            .scaledToFit()
            .modifier(MateImageModifier(size: size))
    }
}
