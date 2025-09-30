//
//  SignUpViewModel.swift
//  PlanT
//
//  Created by 이지훈 on 9/29/25.
//

import Foundation
import Combine
import SwiftUI

// 텍스트 모디파이어
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
        self.modifier(SignUpLabelModifier())
    }
}

// Mate 모디파이어
struct MateImageModifier: ViewModifier {
    var size: CGFloat = 100
    
    func body(content: Content) -> some View {
        content
            .frame(width: size, height: size)
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
