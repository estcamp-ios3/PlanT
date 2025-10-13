//
//  OptionGridItem.swift
//  PlanT
//
//  Created by catharina J on 9/30/25.
//

import SwiftUI

struct OptionGridItem: View {
    let option: Option
    let selected: Bool
    let action: () -> Void

    
    var body: some View {
        Button{
            action()
        } label: {
            
            HStack(spacing: 10) {
                if let symbol = option.icon, !symbol.isEmpty {
                    // Prefer SF Symbol when provided (Category uses icon_name)
                    Image(systemName: symbol)
                        .font(.system(size: 28, weight: .semibold))
                        .frame(width: 40, height: 40, alignment: .center)
                        .foregroundStyle(Color("Gray900"))
                        .padding(.trailing, 4)
                } else if let name = option.thumb, !name.isEmpty {
                    // Fallback to asset thumbnail
                    Image(name)
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(height: 80)
                        .cornerRadius(cornerRadius2)
                } else {
                    // Final fallback
                    Image(systemName: "square.grid.2x2")
                        .font(.system(size: 24, weight: .regular))
                        .foregroundStyle(Color("Gray400"))
                }
                Text(option.title)
                    .font(.title3)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .fontWeight(selected ? .bold : .regular) // 선택되면 굵게
                    .foregroundStyle(Color("Gray900"))
                Spacer()
            }
        }
        .buttonStyle(OptionGridItemStyle(selected: selected))
    }
}

struct OptionGridItemStyle: ButtonStyle {
    let selected: Bool
    
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .padding(.vertical, 8)
            .padding(.horizontal, 12)
            .frame(maxWidth: .infinity)
            .background(selected ? Color("Gray100") : Color(.systemBackground))
            .overlay {
                RoundedRectangle(cornerRadius: cornerRadius2, style: .continuous)
                    .stroke(selected ? Color(.systemBackground) : Color("Gray400"), lineWidth: 1)
            }
            .overlay(alignment: .topTrailing) {
                if selected {
                    Circle()
                        .fill(Color("BrandAccent"))
                        .frame(width: 32, height: 32)
                        .overlay(
                            Image(systemName: "checkmark")
                                .font(.system(size: 12, weight: .bold))
                                .foregroundStyle(.white)
                        )
                        .padding(8)
                }
            }
            .cornerRadius(cornerRadius2)
            .contentShape(RoundedRectangle(cornerRadius: cornerRadius2, style: .continuous))
            .animation(.snappy, value: selected)
    }
}
