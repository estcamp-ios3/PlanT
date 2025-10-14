//
//  OptionRow.swift
//  PlanT
//
//  Created by catharina J on 9/30/25.
//

import SwiftUI

struct OptionRow: View {
    let option: Option
    let selected: Bool
    let action: () -> Void
    
    var body: some View {
        Button {

            action()
        } label: {
            HStack (spacing:vertical2) {
                if let name = option.icon, !name.isEmpty {
                    Image(systemName: name)
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 20, height: 20)
                    
                } else {
                    Image(systemName: "leaf.fill")  // 기본 System Image
                }
                Text(option.title)
                    .font(.title3)
                    .fontWeight(selected ? .bold : .regular) // 선택되면 굵게
                    .foregroundStyle(Color("Gray900"))
                    .contentTransition(.identity)
            }
        }
        .buttonStyle(OptionRowStyle(selected: selected))
    }
}

struct OptionRowStyle: ButtonStyle {
    let selected: Bool
    
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .padding(.vertical, 12)
            .padding(.horizontal, 24)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(selected ? Color("BrandAccent"): Color("BrandSecondary"))
            .cornerRadius(cornerRadius4)
            .animation(.snappy, value: selected)
    }
}
