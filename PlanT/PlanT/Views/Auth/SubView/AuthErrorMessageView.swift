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

    var backgroundColor: Color {
        switch self {
        case .error:   return Color.red.opacity(0.92)
        case .success: return Color.green.opacity(0.92)
        case .info:    return Color.gray.opacity(0.92)
        }
    }

    var iconName: String {
        switch self {
        case .error:   return "exclamationmark.triangle.fill"
        case .success: return "checkmark.circle.fill"
        case .info:    return "info.circle.fill"
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
        HStack(spacing: 8) {
            Image(systemName: style.iconName)
                .font(.system(size: 14, weight: .bold))
                .foregroundColor(.white)
            Text(text)
                .font(.system(size: 14, weight: .semibold))
                .foregroundColor(.white)
                .multilineTextAlignment(.leading)
        }
        .padding(.vertical, 10)
        .padding(.horizontal, 14)
        .background(
            Capsule(style: .continuous)
                .fill(style.backgroundColor)
                .shadow(color: .black.opacity(0.15), radius: 8, y: 4)
        )
        .padding(.horizontal, 16)
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
        bottomPadding: CGFloat = 20
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
