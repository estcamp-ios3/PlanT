//
//  CheckLabelView.swift
//  PlanT
//
//  Created by catharina J on 10/14/25.
//

import SwiftUI

struct CheckLabelView: View {
    @Binding var isChecked: Bool
    let label: String
    @State private var isAllDay = false
    var body: some View {
        Button {
            isChecked.toggle()
        } label: {
            HStack(spacing: vertical1) {
                Image(systemName: isChecked ? "checkmark.circle.fill" : "circle")
                    .font(.system(size: 24))
                    .foregroundStyle(isChecked ? Color.blue : Color.gray.opacity(0.4))
                
                Text(label)
                    .font(.headline)
                    .foregroundColor(Color("Gray900"))
            }
        }
        .buttonStyle(.plain) // 버튼 기본효과 제거
    }
}
