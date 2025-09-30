//
//  MypageUserCardView.swift
//  PlanT
//
//  Created by 이지훈 on 9/30/25.
//

import SwiftUI

struct MypageUserCardView: View {
    @ObservedObject var viewModel: MypageUserCardViewModel

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            // 상단: 아바타 + 타이틀 + 설정
            HStack(alignment: .center, spacing: 12) {
                Image(viewModel.model.mateName)
                    .resizable()
                    .scaledToFit()
                    .frame(width: 48, height: 48)
                    .padding(6)
                    .background(Circle().fill(Color.white))

                Text(viewModel.model.nickName)
                    .font(.system(size: 18, weight: .heavy))
                    .foregroundColor(.black)
                    .lineSpacing(2)
                    .fixedSize(horizontal: false, vertical: true)

                Spacer()

                Button("설정") {
                    viewModel.onTapSettings?()
                }
                .font(.system(size: 14, weight: .semibold))
                .foregroundColor(.gray)
            }

            // 하단 통계 3칼럼
            HStack(spacing: 16) {
                StatItem(
                    icon: Image(systemName: "leaf.fill"),
                    label: "성장중인 작물",
                    value: viewModel.model.growingCount,
                    tint: .green
                )
                StatItem(
                    icon: Image(systemName: "globe"),
                    label: "수확한 작물",
                    value: viewModel.model.harvestedCount,
                    tint: .blue
                )
                StatItem(
                    icon: Image(systemName: "circlebadge.fill"),
                    label: "보유포인트",
                    value: viewModel.model.points,
                    tint: .orange
                )
            }
        }
        .padding(8)
        .background(
            RoundedRectangle(cornerRadius: 20, style: .continuous)
                .fill(Color(UIColor.systemGray6))
        )
    }
}

// 내부에서 쓰는 서브뷰(같은 파일에 포함)
private struct StatItem: View {
    let icon: Image
    let label: String
    let value: Int
    let tint: Color

    var body: some View {
        HStack(spacing: 10) {
            icon
                .resizable()
                .scaledToFit()
                .frame(width: 28, height: 28)
                .foregroundStyle(tint)
                .shadow(color: .black.opacity(0.08), radius: 2, x: 0, y: 1)

            VStack(alignment: .leading, spacing: 2) {
                Text(label)
                    .font(.system(size: 14, weight: .semibold))
                    .lineLimit(1)
                    .minimumScaleFactor(0.9)

                Text(value.formatted(.number.grouping(.automatic)))
                    .font(.system(size: 20, weight: .bold))
                    .foregroundColor(tint)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}

#Preview {
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
    .padding()
    .background(Color.white)
}
