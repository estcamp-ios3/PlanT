//
//  SettingView.swift
//  PlanT
//
//  Created by 이지훈 on 10/16/25.
//

import SwiftUI

struct SettingView: View {
    @EnvironmentObject var authStore: AuthStore

    var body: some View {
        ScrollView {
            VStack {
            }
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
        .navigationTitle("설정")
        .navigationBarTitleDisplayMode(.inline)
    }
}

#Preview {
    NavigationStack {
        SettingView()
            .environmentObject(AuthStore())
    }
}
