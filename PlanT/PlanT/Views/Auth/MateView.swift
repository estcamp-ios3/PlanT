//
//  MateView.swift
//  PlanT
//
//  Created by 이지훈 on 9/30/25.
//

import SwiftUI

struct MateView: View {
    @Binding var selectedMate: Mate?
    
    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 16) {
                ForEach(Mate.allCases) { mate in
                    let isSelected = (selectedMate == mate)
                    
                    ZStack(alignment: .topTrailing) {
                        Image(mate.rawValue)
                            .mateStyle()
                            .onTapGesture {
                                withAnimation(.spring(response: 0.3, dampingFraction: 0.85)) {
                                    selectedMate = (selectedMate == mate) ? nil : mate
                                }
                            }
                        
                        if isSelected {
                            Text("Hi~")
                                .font(.system(size: 12, weight: .bold))
                                .padding(.vertical, 8)
                                .padding(.horizontal, 10)
                                .background(
                                    Capsule()
                                        .fill(Color("F2BF80"))
                                        .overlay(
                                            Capsule()
                                                .stroke(Color("F2B263"), lineWidth: 2)
                                        )
                                )
                                .offset(x: 16, y: 0) // 말풍선 위치값
                                .transition(.scale.combined(with: .opacity))
                                .animation(.spring(response: 0.3, dampingFraction: 0.85), value: isSelected)
                        }
                    }
                }
            }
            .padding(.horizontal, 8)
            .padding(.vertical, 10)
        }
    }
}

#Preview {
    MateView(selectedMate: .constant(nil))
}
