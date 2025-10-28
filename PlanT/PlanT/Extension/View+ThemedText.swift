//
//  View+ThemedText.swift
//  PlanT
//
//  Created by 박성관 on 10/28/25.
//

import SwiftUI

extension View {
    /// 다크모드일 때 폰트 색상을 자동으로 변경해주는 전역 modifier
    func themedTextColor() -> some View {
        self.modifier(ThemedTextModifier())
    }
}

struct ThemedTextModifier: ViewModifier {
    @Environment(\.colorScheme) var colorScheme

    func body(content: Content) -> some View {
        content
            .foregroundColor(colorScheme == .dark ? .white : .black)
    }
}
