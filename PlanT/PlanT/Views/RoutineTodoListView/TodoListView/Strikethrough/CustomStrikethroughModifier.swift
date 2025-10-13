//
//  CustomStrikethroughModifier.swift
//  PlanT
//
//  Created by APPLE on 2025-10-04.
//

import SwiftUI

struct CustomStrikethroughModifier: ViewModifier {
    let text: String
    let active: Bool
    let color: Color
    let alphanumericOffset: CGFloat  // 영어+숫자만 있을 때
    let mixedOffset: CGFloat         // 다른 문자 포함될 때
    let thickness: CGFloat

    // 텍스트가 알파벳+숫자만 포함하는지 확인
    private func isAlphanumericOnly(_ text: String) -> Bool {

//        let cleanedText = text.replacingOccurrences(of: " ", with: "") // 스페이스 제거
//                             .replacingOccurrences(of: "\n", with: "") // 줄바꿈 제거

        let pattern = "^[a-zA-Z0-9\\s]*$"
        return text.range(of: pattern, options: .regularExpression) != nil
    }

    // 적절한 offset 값 계산
    private var calculatedOffset: CGFloat {
        return isAlphanumericOnly(text) ? alphanumericOffset : mixedOffset
    }

    func body(content: Content) -> some View {
        ZStack(alignment: .leading) {
            content

            if active {
                GeometryReader { geometry in
                    Rectangle()
                        .frame(height: thickness)
                        .foregroundColor(color)
                        .offset(y: geometry.size.height / 2 + calculatedOffset)
                }
            }
        }
    }
}

extension View {
    func customStrikethrough(
        text: String,
        active: Bool = true,
        color: Color = .black,
        alphanumericOffset: CGFloat = 0,    // 영어+숫자 취소선 위치(대문자 기준) : 소문자 + 숫자 미구현
        mixedOffset: CGFloat = 0,           // 영어+숫자 외 취소선 위치
        thickness: CGFloat = 1
    ) -> some View {
        modifier(CustomStrikethroughModifier(
            text: text,
            active: active,
            color: color,
            alphanumericOffset: alphanumericOffset,
            mixedOffset: mixedOffset,
            thickness: thickness
        ))
    }
}

struct ContentView2: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            Text("기본 취소선")
                .strikethrough()

            let text1 = "사과나무"
            Text(text1)
                .customStrikethrough(
                                    text: text1,
                                    color: .red,
                                    alphanumericOffset: 0,  // 영어는 위로
                                    mixedOffset: -15           // 한글은 아래로
                                )

//            Text("아래로 내린 취소선")
//                .customStrikethrough(color: .blue, offset: 5)
//
//            Text("두꺼운 취소선")
//                .customStrikethrough(color: .green, thickness: 3)
        }
        .font(.title2)
        .padding()
    }
}

//#Preview {
//    ContentView2()
//}
