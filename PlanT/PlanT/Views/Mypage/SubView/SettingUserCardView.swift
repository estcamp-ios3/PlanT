//
//  SettingUserCardView.swift
//  PlanT
//
//  Created by 이지훈 on 10/23/25.
//

import SwiftUI

struct SettingUserCardView: View {
    @EnvironmentObject var authStore: AuthStore
    @StateObject private var viewModel: MypageUserCardViewModel

    // AuthStore 주입, 내부에서 ViewModel 생성
    init(authStore: AuthStore) {
        _viewModel = StateObject(wrappedValue: MypageUserCardViewModel(authStore: authStore))
    }

    var body: some View {
        VStack(alignment: .leading, spacing: vertical3) {
            Image(viewModel.model.mateName)
                .resizable()
                .scaledToFit()
                .frame(width: 150, height: 150)
                .padding(8)
                .background(
                    Circle()
                        .fill(.white)
                        .shadow(color: .black.opacity(0.06), radius: 4, y: 2)
                )

            VStack(alignment: .leading, spacing: vertical2) {
                profileInfo(label: "이름",   value: authStore.userName)
                profileInfo(label: "닉네임", value: authStore.nickName)
                profileInfo(label: "이메일", value: authStore.userEmail)
            }
        }
        .padding(.leading, vertical3)
        .padding(.vertical, vertical3)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(
            RoundedRectangle(cornerRadius: 20, style: .continuous)
                .fill(Color(UIColor.systemGray6))
                .ignoresSafeArea(edges: .horizontal)
        )
    }
}


// MARK: - 재사용 가능한 스타일 & 헬퍼
private struct ProfileInfoStyle: ViewModifier {
    func body(content: Content) -> some View {
        content
            .font(.system(size: 18, weight: .heavy))
            .foregroundColor(.primary)
            .lineLimit(1)
            .minimumScaleFactor(0.85)
    }
}


// MARK: - 텍스트 모디파이어
private extension View {
    func profileInfoStyle() -> some View {
        modifier(ProfileInfoStyle())
    }
}
@ViewBuilder
private func profileInfo(label: String, value: String?) -> some View {
    Text("\(label) : \(value ?? "불러오는 중...")")
        .profileInfoStyle()
}


// MARK: - Preview
#Preview {
    let mock = AuthStore()
    mock.userName = "테스트"
    mock.nickName = "Test"
    mock.mate = "MrPurr"
    mock.userEmail = "test@plant.com"

    return NavigationStack {
        SettingUserCardView(authStore: mock)
            .environmentObject(mock)
            .padding()
            .background(Color.white)
    }
}
