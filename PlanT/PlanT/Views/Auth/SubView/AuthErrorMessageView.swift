//
//  AuthErrorMessageView.swift
//  PlanT
//
//  Created by 이지훈 on 10/29/25.
//

import SwiftUI

/// 토스트 스타일
public enum AuthToastStyle {
    case error
    case success
    case info

    var mainColor: Color {
        switch self {
        case .error:   return Color.red
        case .success: return Color.green
        case .info:    return Color.gray
        }
    }

    var backgroundColor: Color {
        switch self {
        case .error, .success, .info:
            return Color.white
        }
    }
}

/// 공통 토스트 배너 뷰
public struct AuthToastBanner: View {
    let text: String
    let style: AuthToastStyle

    public init(text: String, style: AuthToastStyle = .error) {
        self.text = text
        self.style = style
    }

    public var body: some View {
        HStack(spacing: vertical2) {
            Text(text)
                .font(.system(size: vertical4, weight: .semibold))
                .foregroundColor(style.mainColor)
                .multilineTextAlignment(.leading)
        }
        .padding(.vertical, vertical3)
        .padding(.horizontal, vertical4)
        .background(
            Capsule(style: .continuous)
                .fill(style.backgroundColor)
                .overlay(
                    Capsule(style: .continuous)
                        .stroke(style.mainColor, lineWidth: 1.5) // 아웃라인
                )
                .shadow(color: .black.opacity(0.08), radius: vertical2, y: vertical1)
        )
        .padding(.horizontal, vertical4)
    }
}

/// 오버레이 토스트 뷰 모디파이어
private struct AuthToastOverlay: ViewModifier {
    @Binding var isPresented: Bool
    @Binding var message: String?
    var style: AuthToastStyle
    var alignment: Alignment
    var bottomPadding: CGFloat

    func body(content: Content) -> some View {
        content
            .overlay(alignment: alignment) {
                if isPresented, let msg = message, !msg.isEmpty {
                    AuthToastBanner(text: msg, style: style)
                        .padding(.bottom, bottomPadding)
                        .transition(.move(edge: .bottom).combined(with: .opacity))
                        .animation(.spring(response: 0.35, dampingFraction: 0.9), value: isPresented)
                        .zIndex(1)
                }
            }
    }
}

public extension View {
    func authToast(
        isPresented: Binding<Bool>,
        message: Binding<String?>,
        style: AuthToastStyle = .error,
        alignment: Alignment = .bottom,
        bottomPadding: CGFloat = 20 // 여긴 왜때문에 디자인 토큰 적용이 안돼지
    ) -> some View {
        modifier(AuthToastOverlay(
            isPresented: isPresented,
            message: message,
            style: style,
            alignment: alignment,
            bottomPadding: bottomPadding
        ))
    }
}
