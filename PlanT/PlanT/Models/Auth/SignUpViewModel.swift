//
//  SignUpViewModel.swift
//  PlanT
//
//  Created by 이지훈 on 9/29/25.
//

import Foundation
import Combine
import SwiftUI

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
