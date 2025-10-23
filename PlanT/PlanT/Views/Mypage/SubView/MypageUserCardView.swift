//
//  MypageUserCardView.swift
//  PlanT
//
//  Created by 이지훈 on 9/30/25.
//

import SwiftUI

struct MypageUserCardView: View {
    @StateObject private var viewModel: MypageUserCardViewModel

    /// ✅ AuthStore를 주입받아 내부에서 ViewModel 생성
    init(authStore: AuthStore) {
        _viewModel = StateObject(wrappedValue: MypageUserCardViewModel(authStore: authStore))
    }

    var body: some View {
        VStack(alignment: .leading, spacing: vertical3) {
            // 상단: 아바타 + 닉네임 + 설정 버튼
            HStack(alignment: .center, spacing: vertical3) {
                Image(viewModel.model.mateName)
                    .resizable()
                    .scaledToFit()
                    .frame(width: 48, height: 48)
                    .padding(6)
                    .background(Circle().fill(Color.white))

                Text(viewModel.model.nickName)
                    .font(.system(size: vertical5, weight: .heavy))
                    .foregroundColor(.black)
                    .lineSpacing(2)

                Spacer()
            }

            // 하단 통계 섹션
            HStack(spacing: 16) {
                StatItem(
                    icon: Image("sprout"),
                    label: "성장중인 작물",
                    value: viewModel.model.growingCount,
                    tint: Color.green,
                    iconSize: 170
                )
                StatItem(
                    icon: Image("pumpkin"),
                    label: "수확한 작물",
                    value: viewModel.model.harvestedCount,
                    tint: Color.blue,
                    iconSize: 170
                )
                StatItem(
                    icon: Image("point"),
                    label: "보유포인트",
                    value: viewModel.model.points,
                    tint: Color.orange,
                    iconSize: 170
                )
            }
        }
        .padding(8)
        .background(
            RoundedRectangle(cornerRadius: 20, style: .continuous)
                .fill(Color(UIColor.systemGray6))
        )
        // ✅ ViewModel의 상태를 기반으로 네비게이션 전환
        .navigationDestination(isPresented: $viewModel.isShowingSetting) {
            SettingView()
        }
    }
}

// MARK: - 하위 뷰
private struct StatItem: View {
    let icon: Image
    let label: String
    let value: Int
    let tint: Color
    var iconSize: CGFloat = 36

    var body: some View {
        HStack(spacing: vertical2) {
            ZStack {
                icon
                    .resizable()
                    .scaledToFit()
                    .frame(width: iconSize, height: iconSize)
                    .foregroundStyle(tint)
                    .shadow(color: .black.opacity(0.08), radius: 2, x: 0, y: 1)
            }
            .frame(width: 36, height: 36)
            .offset(x: vertical1)

            VStack(alignment: .leading, spacing: 2) {
                Text(label)
                    .font(.system(size: vertical3, weight: .semibold))
                    .lineLimit(1)
                    .minimumScaleFactor(0.8)

                Text(value.formatted(.number.grouping(.automatic)))
                    .font(.system(size: vertical5, weight: .bold))
                    .foregroundColor(tint)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}

#Preview {
    let mock = AuthStore()
    mock.nickName = "나는 확신의 P이다\n이번에는 꼭 완료해야지"
    mock.mate = "MrPurr"

    return NavigationStack {
        MypageUserCardView(authStore: mock)
            .environmentObject(mock)
            .padding()
            .background(Color.white)
    }
}
