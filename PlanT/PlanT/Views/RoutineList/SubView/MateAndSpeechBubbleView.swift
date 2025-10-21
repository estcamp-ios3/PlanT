//
//  MateAndSpeechBubbleView.swift
//  PlanT
//
//  Created by 이지훈 on 10/21/25.
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
            // 말풍선
            BubbleShape()
                .fill(Color.gray.opacity(0.25))
            
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


// MARK: - 작은 서브뷰: mate 아바타 배지(원형 + 테두리)
struct MateBadge: View {
    let imageName: String

    var body: some View {
        ZStack {
            Circle()
                .fill(Color.white)
                .overlay(
                    Circle().stroke(Color.gray.opacity(0.4), lineWidth: 2)
                )
            Image(imageName.isEmpty ? "MrPurr" : imageName)
                .resizable()
                .scaledToFit()
                .padding(8)
        }
        .frame(width: 80, height: 80)
        // .onTapGesture { /* TODO: 토스트 띄우기 or 화면 이동 */ }
    }
}
