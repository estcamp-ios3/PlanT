//
//  MypageItemView.swift
//  PlanT
//
//  Created by 이지훈 on 10/16/25.
//

import SwiftUI

import SwiftUI

struct MypageItemView: View {
    var body: some View {
        HStack(alignment: .top, spacing: vertical4) {
            Button(action: {}) {
                ItemColumn(imageName: "myIcon01", title: "도감보기")
            }
            Button(action: {}) {
                ItemColumn(imageName: "myIcon03", title: "작물/아이템 창고")
            }
            Button(action: {}) {
                ItemColumn(imageName: "myIcon02", title: "포인트 교환/내역")
            }
        }
        .frame(maxWidth: .infinity)
        .padding(.horizontal, vertical4)
    }
}

private struct ItemColumn: View {
    let imageName: String
    let title: String

    var body: some View {
        VStack(spacing: vertical2) {
            Image(imageName)
                .resizable()
                .scaledToFit()
                .frame(width: 80, height: 80)

            Text(title)
                .font(.system(size: vertical3, weight: .semibold))
                .multilineTextAlignment(.center)
                .lineLimit(nil)
        }
        .frame(maxWidth: .infinity, alignment: .top)
    }
}

#Preview {
    MypageItemView()
}
