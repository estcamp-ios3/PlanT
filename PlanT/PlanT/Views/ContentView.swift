//
//  ContentView.swift
//  PlanT
//
//  Created by catharina J on 9/29/25.
//

import SwiftUI

struct ContentView: View {
    @State private var path = NavigationPath()
    var body: some View {
        TabView {
            // 리스트 탭
            NavigationStack(path: $path) {
                RoutineTodoListTabView(path: $path)
                    .navigationTitle("루틴/할일 목록")
                    .navigationBarTitleDisplayMode(.inline)
            }
            .tabItem {
                Label("리스트", systemImage: "list.bullet")
            }
            .tag(0)

            // 마이페이지 탭
            NavigationStack {
                MypageMainView()
                    .navigationTitle("마이페이지")
                    .navigationBarTitleDisplayMode(.inline)
            }
            .tabItem {
                Label("마이페이지", systemImage: "person.crop.circle")
            }
            .tag(1)
        }
    }
}

#Preview {
    ContentView()
}
