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
            
            MypagePlantsCardView()
        }
        .padding()
        .background(Color.white)
        
        // ✅ 네비게이션 상단 오른쪽에 로그아웃 버튼 추가
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button {
                    Task {
                        await authStore.signOut()
                    }
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
            .environmentObject(AuthStore())  // ✅ 미리보기에서도 필요
    }
}
