//
//  TutorialOverlayView.swift
//  PlanT
//
//  Created by 박성관 on 10/23/25.
//

import SwiftUI

struct TutorialOverlayView: View {
    @ObservedObject var manager: TutorialManager
    let frames: [String: CGRect]
    let onFinish: () -> Void

    var body: some View {
        guard let step = manager.currentStep else {
            return AnyView(EmptyView())
        }
        let target = frames[step.id] ?? .zero

        return AnyView(
            ZStack {
                // ✅ 반투명 배경 (밑 UI 터치 허용)
                Color.black.opacity(0.6)
                    .ignoresSafeArea()
                    .allowsHitTesting(false)

                // ✅ 하이라이트 구멍
                if !target.isEmpty {
                    ZStack {
                        Color.black.opacity(0.6)
                            .blendMode(.darken)
                            .ignoresSafeArea()

                        RoundedRectangle(cornerRadius: 20)
                            .frame(width: target.width + 8, height: target.height + 8)
                            .position(x: target.midX, y: target.midY)
                            .blendMode(.destinationOut)
                            .shadow(color: .white.opacity(0.6), radius: 8)
                    }
                    .compositingGroup()
                    .allowsHitTesting(false)
                }

                // ✅ 문구 + 화살표
                VStack {
                    Spacer()
                        .frame(height: target.isEmpty ? 250 : target.maxY + 40)
                    HStack {
                        Spacer()
                            .frame(width: target.isEmpty ? 24 : max(0, target.midX - 80))

                        VStack(alignment: .leading, spacing: 12) {
                            Text(step.message)
                                .foregroundColor(.white)
                                .font(.headline)
                                .padding(14)
                                .background(.black.opacity(0.6))
                                .cornerRadius(12)

                            if !target.isEmpty {
                                Image(systemName: "arrow.up")
                                    .font(.system(size: 36, weight: .bold))
                                    .foregroundColor(.yellow)
                                    .padding(.leading, 16)
                            }

                            if step.showNextButton {
                                Button(action: {
                                    manager.next()
                                }) {
                                    Text("다음")
                                        .font(.system(size: 15, weight: .bold))
                                        .padding(.vertical, 10)
                                        .padding(.horizontal, 20)
                                        .background(Color("BrandPrimary"))
                                        .foregroundColor(.black)
                                        .cornerRadius(30)
                                }
                            }
                        }
                        Spacer()
                    }
                    Spacer()
                }
            }
            .animation(.easeInOut(duration: 0.3), value: manager.currentIndex)
        )
    }
}

