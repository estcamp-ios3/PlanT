//
//  ChecklistItemView.swift
//  PlanT
//
//  Created by APPLE on 2025-10-13.
//

import SwiftUI

struct TodoListCheckItemView: View {
    @Binding var item: TodoListCheckItem

    public var body: some View {
        HStack(spacing: 12) {
            // 체크 여부에 따라 다른 아이콘과 색상 표시
            Image(systemName: item.isChecked ? "checkmark.square.fill" : "square")
                .font(.title3)
                .foregroundColor(item.isChecked ? .blue : .gray.opacity(0.5))

            Text(item.text)
//                .strikethrough(item.isChecked, color: .red)
//                .customStrikethrough(item.isChecked, color: .red, offset: -1)
                .customStrikethrough(
                                    text: item.text,
                                    active: item.isChecked,
                                    color: .red,
//                                    alphanumericOffset: -2, // 영어
                                    mixedOffset: -2           // 한글
                                )

                .foregroundColor(.primary) // .black 대신 .primary를 사용하면 다크모드 대응 용이
                .lineLimit(1)

            Spacer()
        }

//        // 행 전체를 탭하여 상태를 변경할 수 있도록 Button으로 구현
//        Button(action: {
//            print("상세화면 이동")
//            // 애니메이션과 함께 상태 변경
//            withAnimation {
//                item.isChecked.toggle()
//            }
//        }) {
//            HStack(spacing: 12) {
//                // 체크 여부에 따라 다른 아이콘과 색상 표시
//                Image(systemName: item.isChecked ? "checkmark.square.fill" : "square")
//                    .font(.title3)
//                    .foregroundColor(item.isChecked ? .blue : .gray.opacity(0.5))
//
//                Text(item.text)
//                    .foregroundColor(.primary) // .black 대신 .primary를 사용하면 다크모드 대응 용이
//                    .lineLimit(1)
//
//                Spacer()
//            }
//        }
    }
}
