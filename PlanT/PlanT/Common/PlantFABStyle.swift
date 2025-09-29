//
//  PlantFABStyle.swift
//  PlanT
//
//  Created by catharina J on 9/29/25.
//

import SwiftUI

// MARK: - Floating Action Button Style
struct PlantFABStyle: ButtonStyle {
    var diameter: CGFloat = 56        // 터치 타깃 확보(44pt 이상 권장)
    var iconSize: CGFloat = 22
    var useAccent: Bool = true        // 포인트 컬러 vs 기본 컬러

    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    func makeBody(configuration: Configuration) -> some View {
        // 에셋 폴백(프리뷰/미설정 안전)
        let accent = Color(uiColor: UIColor(named: "BrandAccent")  ?? .systemOrange)

        let bg = accent
        let fg = Color.white

        return configuration.label
            .font(.system(size: iconSize, weight: .bold))
            .foregroundStyle(fg)
            .frame(width: diameter, height: diameter)
            .contentShape(Circle()) // 정확한 히트 영역
            .background(bg, in: Circle())
            .shadow(color: Color.black.opacity(0.18),
                    radius: 6, x: 0, y: 3)
            .scaleEffect(configuration.isPressed && !reduceMotion ? 0.94 : 1)
            .opacity(configuration.isPressed ? 0.97 : 1)
            .animation(reduceMotion ? .none
                      : .spring(response: 0.25, dampingFraction: 0.9),
                       value: configuration.isPressed)
            .accessibilityAddTraits(.isButton)
            .accessibilityLabel(Text("새로 만들기"))
    }
}

// MARK: - 편의 모디파이어
extension View {
    func plantFABStyle(
        diameter: CGFloat = 56,
        iconSize: CGFloat = 22,
        useAccent: Bool = true
    ) -> some View {
        self.buttonStyle(PlantFABStyle(diameter: diameter,
                                       iconSize: iconSize,
                                       useAccent: useAccent))
    }
}
