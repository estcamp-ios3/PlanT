//
//  SettingView.swift
//  PlanT
//
//  Created by 이지훈 on 10/16/25.
//

import SwiftUI

struct SettingView: View {
    @EnvironmentObject var authStore: AuthStore
    @State private var showSignOutAlert = false

    var body: some View {
        ScrollView {
            VStack {
                HStack {
                    SettingUserCardView(authStore: authStore)
                }
            }
            .padding(.horizontal, vertical4)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button {
                        showSignOutAlert = true
                    } label: {
                        Image(systemName: "door.left.hand.open")
                            .foregroundColor(.red)
                    }
                }
            }
        }
        .navigationTitle("설정")
        .navigationBarTitleDisplayMode(.inline)
        // ✅ Alert 추가
        .alert("현재 계정에서 로그아웃 됩니다.", isPresented: $showSignOutAlert) {
            Button("취소", role: .cancel) { }
            Button("로그아웃", role: .destructive) {
                Task { await authStore.signOut() }
            }
        }
    }
}

#Preview {
    NavigationStack {
        SettingView()
            .environmentObject(AuthStore())
    }
}
