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
                    Image(mate.rawValue)
                        .mateStyle()
                        .onTapGesture { selectedMate = mate }
                }
            }
        }
    }
}

#Preview {
    MateView(selectedMate: .constant(.grrr)) // 미리보기 용도
}
