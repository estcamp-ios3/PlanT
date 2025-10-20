//
//  SpeechBubbleView.swift
//  PlanT
//
//  Created by 이지훈 on 10/20/25.
//

import SwiftUI

// MARK: - 말풍선 도형
private struct BubbleShape: Shape {
    let cornerRadius: CGFloat = 18
    
    func path(in rect: CGRect) -> Path {
        var path = Path()
        path.addRoundedRect(
            in: rect,
            cornerSize: CGSize(width: cornerRadius, height: cornerRadius)
        )
        return path
    }
}

// MARK: - 말풍선 뷰 (동적 높이 대응)
struct SpeechBubbleView: View {
    let message: String
    var maxWidth: CGFloat = UIScreen.main.bounds.width * 0.68
    
    var body: some View {
        ZStack {
            // 말풍선 배경
            BubbleShape()
                .fill(Color.gray.opacity(0.25)) // 필요 시 Color("Gray400")로 변경 가능
            
            // 텍스트
            Text(message.isEmpty ? " " : message)
                .font(.system(size: 16, weight: .semibold))
                .foregroundColor(.primary)
                .multilineTextAlignment(.leading)
                .fixedSize(horizontal: false, vertical: true)
                .padding(.horizontal, 40)
                .padding(.vertical, 14)
                .layoutPriority(1)
        }
        .frame(maxWidth: maxWidth, alignment: .leading)
        .shadow(color: .gray.opacity(0.08), radius: 6, y: 2)
    }
}

// MARK: - Preview
#Preview {
    SpeechBubbleView(
        message: "러닝 1회 20분씩 10회 루틴을 진행하시려는 군요! 매일 조금씩 하면 할 수 있어요!"
    )
}


