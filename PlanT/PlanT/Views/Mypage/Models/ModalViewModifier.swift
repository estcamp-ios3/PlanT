//
//  ModalViewModifier.swift
//  PlanT
//
//  Created by 이지훈 on 10/27/25.
//

import SwiftUI

/// 모달에서 공통으로 쓰는 "닫기(X)" 버튼 툴바 모디파이어
private struct ModalViewModifier: ViewModifier {
    @Environment(\.dismiss) private var dismiss

    var placement: ToolbarItemPlacement
    var icon: Image
    var iconSize: CGFloat

    func body(content: Content) -> some View {
        content.toolbar {
            ToolbarItem(placement: placement) {
                Button {
                    dismiss()
                } label: {
                    icon
                        .font(.system(size: iconSize, weight: .bold))
                }
                .accessibilityLabel("닫기")
            }
        }
    }
}

public extension View {
    /// - Parameters:
    ///   - placement: 버튼 위치(기본: .navigationBarTrailing)
    ///   - icon: 아이콘(기본: xmark)
    ///   - iconSize: 아이콘 크기(기본: 14)
    func modalToolbar(
        placement: ToolbarItemPlacement = .navigationBarTrailing,
        icon: Image = Image(systemName: "xmark"),
        iconSize: CGFloat = 14
    ) -> some View {
        modifier(
            ModalViewModifier(
                placement: placement,
                icon: icon,
                iconSize: iconSize
            )
        )
    }
}
