//
//  SettingUserCardView.swift
//  PlanT
//
//  Created by 이지훈 on 10/23/25.
//

import SwiftUI

/// 설정 화면에서 쓰는 유저 카드 (레이아웃만 다름)
struct SettingUserCardView: View {
    @StateObject private var viewModel: MypageUserCardViewModel

    /// ✅ AuthStore를 주입받아 내부에서 ViewModel 생성
    init(authStore: AuthStore) {
        _viewModel = StateObject(wrappedValue: MypageUserCardViewModel(authStore: authStore))
    }

    var body: some View {
        VStack {

            // 상단 프로필 블록 (아바타 크게 + 닉네임 좌정렬)
            VStack {
                Image(viewModel.model.mateName)
                    .resizable()
                    .scaledToFit()
                    .frame(width: 100, height: 100)
                    .padding(8)
                    .background(
                        Circle()
                            .fill(.white)
                            .shadow(color: .black.opacity(0.06), radius: 4, y: 2)
                    )
                    Text(viewModel.model.nickName)
                        .font(.system(size: vertical5, weight: .heavy))
                        .foregroundColor(.primary)
                        .lineLimit(2)
                        .minimumScaleFactor(0.85)
            }


        }
        .padding(12)
        .background(
            RoundedRectangle(cornerRadius: 20, style: .continuous)
                .fill(Color(UIColor.systemGray6))
        )
    }
}

// MARK: - 타일 스타일 통계 뷰 (설정 카드 전용)
private struct StatTile: View {
    let icon: Image
    let title: String
    let value: Int
    let tint: Color

    var body: some View {
        VStack(spacing: vertical2) {
            icon
                .resizable()
                .scaledToFit()
                .frame(width: 36, height: 36)
                .shadow(color: .black.opacity(0.08), radius: 2, y: 1)

            Text(title)
                .font(.system(size: vertical3, weight: .semibold))
                .foregroundColor(.primary)
                .lineLimit(1)
                .minimumScaleFactor(0.9)

            Text(value.formatted(.number.grouping(.automatic)))
                .font(.system(size: vertical5, weight: .bold))
                .foregroundColor(tint)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, vertical3)
        .background(
            RoundedRectangle(cornerRadius: 14, style: .continuous)
                .fill(.white)
                .shadow(color: .black.opacity(0.05), radius: 6, y: 3)
        )
    }
}

// MARK: - Preview
#Preview {
    let mock = AuthStore()
    mock.nickName = "설정 화면용 카드\n닉네임 예시"
    mock.mate = "MrPurr"

    return NavigationStack {
        SettingUserCardView(authStore: mock)
            .environmentObject(mock)
            .padding()
            .background(Color.white)
    }
}
