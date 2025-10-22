//
//  MateAndSpeechBubbleView.swift
//  PlanT
//
//  Created by 이지훈 on 10/21/25.
//

import SwiftUI

// MARK: - (꼬리 없는) 말풍선 뷰
struct SpeechBubbleView: View {
    let message: String

    // 스타일 파라미터
    var maxWidth: CGFloat = UIScreen.main.bounds.width * 0.78
    var background: Color = Color("Gray400")
    var textColor: Color = .primary
    var cornerRadius: CGFloat = vertical5
    var hPadding: CGFloat = vertical5
    var vPadding: CGFloat = vertical4
    var shadowColor: Color = .black.opacity(0.10)
    var shadowRadius: CGFloat = vertical2
    var shadowY: CGFloat = vertical1
    var font: Font = .system(size: vertical4, weight: .semibold)
    var lineSpacing: CGFloat = vertical1

    var body: some View {
        ZStack(alignment: .leading) {
            // ✅ 꼬리 없는 둥근 사각형
            RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                .fill(background)

            Text(message.isEmpty ? " " : message)
                .font(font)
                .foregroundColor(textColor)
                .multilineTextAlignment(.leading)
                .lineSpacing(lineSpacing)
                .frame(maxWidth: .infinity, alignment: .leading)
                .fixedSize(horizontal: false, vertical: true)
                .padding(.horizontal, hPadding)
                .padding(.vertical, vPadding)
                .layoutPriority(1)
        }
        .frame(maxWidth: maxWidth, alignment: .leading)
        .shadow(color: shadowColor, radius: shadowRadius, y: shadowY)
    }
}

// MARK: - Mate 아바타 배지 (그대로)
struct MateBadge: View {
    let imageName: String
    var body: some View {
        ZStack {
            Image(imageName.isEmpty ? "MrPurr" : imageName)
                .resizable()
                .scaledToFit()
                .padding(8)
        }
        .frame(width: 80, height: 80)
    }
}

// ====== 프리뷰 전용 래퍼 ======
private struct MateToastPreview: View {
    let message =
    """
    러닝 1회 20분씩
    10회 루틴을 진행하시려고 하시는 군요!
    매일 00하게 하면 할 수 있어요.
    """

    var body: some View {
        ZStack(alignment: .bottomLeading) {
            Color.black.opacity(0.04).ignoresSafeArea()

            // 레이아웃 파라미터
            let avatarWidth: CGFloat = 80
            let leftPadding: CGFloat = 20
            let baseSpacing: CGFloat = 10
            let overlapX: CGFloat = 12 // 좌우값
            let overlapY: CGFloat = 0 // 상하값

            ZStack(alignment: .bottomLeading) {
                MateBadge(imageName: "MrPurr")
                    .padding(.leading, leftPadding)
                    .zIndex(5)

                SpeechBubbleView(
                    message: message,
                    maxWidth: UIScreen.main.bounds.width * 0.75
                )
                .padding(.leading, leftPadding + avatarWidth + baseSpacing)
                .offset(x: -overlapX, y: -overlapY)
                .zIndex(10)
            }
            .padding(.bottom, 20)
        }
    }
}

#Preview("Mate Toast (No Tail)") {
    MateToastPreview()
        .preferredColorScheme(.light)
}
