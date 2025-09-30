//
//  MypageMainView.swift
//  PlanT
//
//  Created by catharina J on 9/29/25.
//

import SwiftUI

struct MypageMainView: View {
    var body: some View {
        VStack {
            MypageUserCardView(
                viewModel: MypageUserCardViewModel(
                    model: MypageUserCardModel(
                        mateName: "MrPurr",
                        nickName: "닉네임: 나는 확신의 P이다\n이번에는 꼭 완료해야지",
                        growingCount: 12,
                        harvestedCount: 1032,
                        points: 1200
                    ),
                    onTapSettings: { print("설정 탭") }
                )
            )
        }
        .padding()
        .background(Color.white)
    }
}

#Preview {
    MypageMainView()
}
