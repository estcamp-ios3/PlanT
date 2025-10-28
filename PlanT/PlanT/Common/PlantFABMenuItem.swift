//
//  PlantFABMenuItem.swift
//  PlanT
//
//  Created by catharina J on 9/30/25.
//
import SwiftUI

struct PlantFABMenuItem: View {
    let title: String
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack {
                Text(title)
                    .font(.system(.body, design: .rounded))
                    .foregroundStyle(Color("3B4019"))
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 12)
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
    }
}
