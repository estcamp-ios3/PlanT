//
//  MypageMainView.swift
//  PlanT
//
//  Created by catharina J on 9/29/25.
//

import SwiftUI

struct MypageMainView: View {
    @EnvironmentObject var authStore: AuthStore   // ✅ 전역 로그인 상태 접근

    var body: some View {
        VStack(spacing: 20) {
            // ✅ 사용자 카드 (닉네임 & 메이트 연동)
            MypageUserCardView(
                viewModel: MypageUserCardViewModel(
                    model: MypageUserCardModel(
                        mateName: authStore.mate ?? "MrPurr",  // ✅ 서버 메타데이터에서 반영
                        nickName: "닉네임: \(authStore.nickName ?? "불러오는 중...")",
                        growingCount: 12,
                        harvestedCount: 1032,
                        points: 1200
                    ),
                    onTapSettings: { print("설정 탭") }
                )
            )

            MypagePlantsCardView()

            // ✅ 현재 사용자 정보 표시 (디버그용)
            VStack(spacing: 4) {
                if let email = authStore.userEmail {
                    Text("📧 \(email)")
                }
                if let name = authStore.userName {
                    Text("👤 \(name)")
                }
                if let mate = authStore.mate {
                    Text("🐾 \(mate)")
                }
            }
            .font(.footnote)
            .foregroundColor(.gray)
        }
        .padding()
        .background(Color.white)
        .navigationTitle("마이페이지")
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button {
                    Task { await authStore.signOut() }
                } label: {
                    Text("로그아웃")
                        .foregroundColor(.red)
                }
            }
        }
    }
}

#Preview {
    NavigationStack {
        MypageMainView()
            .environmentObject(AuthStore())
    }
}
