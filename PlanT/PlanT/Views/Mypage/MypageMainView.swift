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
                // ✅ ViewModel이 내부에서 authStore를 구독함
                MypageUserCardView(authStore: authStore)

                MypageItemView()
                MypagePlantsCardView(authStore: authStore)
            }
            .padding(.horizontal)
        }
    }
}

#Preview {
    NavigationStack {
        MypageMainView()
            .environmentObject(AuthStore())
    }
}
