//
//  View+ThemedBackground.swift
//  PlanT
//
//  Created by 박성관 on 10/28/25.
//

import SwiftUI

extension View {
    func themedBackground() -> some View {
        self.modifier(ThemedBackgroundModifier())
    }
}

struct ThemedBackgroundModifier: ViewModifier {
    @Environment(\.colorScheme) var colorScheme

    func body(content: Content) -> some View {
        ZStack {
            (colorScheme == .dark ? Color.white : Color.black)
                .ignoresSafeArea()
            content
                .foregroundColor(colorScheme == .dark ? .black : .white)
        }
    }
}
