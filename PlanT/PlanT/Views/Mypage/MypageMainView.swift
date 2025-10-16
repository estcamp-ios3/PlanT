//
//  MypageMainView.swift
//  PlanT
//
//  Created by catharina J on 9/29/25.
//

import SwiftUI

struct MypageMainView: View {
    @EnvironmentObject var authStore: AuthStore

    var body: some View {
        ScrollView {
            VStack(spacing: vertical3) {
                // ✅ ViewModel이 직접 authStore를 구독하도록 변경됨
                MypageUserCardView(
                    viewModel: MypageUserCardViewModel(authStore: authStore)
                )

                MypageItemView()
                MypagePlantsCardView()
            }
            .padding()
            .background(Color.white)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button {
                        Task { await authStore.signOut() }
                    } label: {
                        Image(systemName: "door.left.hand.open")
                            .foregroundColor(.red)
                    }
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
