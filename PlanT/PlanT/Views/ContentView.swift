//
//  ContentView.swift
//  PlanT
//
//  Created by catharina J on 9/29/25.
//

import SwiftUI

struct ContentView: View {
    @State private var path = NavigationPath()
    @State private var showAddRoutineSheet = false
    var body: some View {
        ZStack {
            TabView {
                // 리스트 탭
                NavigationStack(path: $path) {
                    RoutineTodoListTabView(path: $path, showAddRoutineSheet: $showAddRoutineSheet)
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
            if showAddRoutineSheet {
                BottomSheetView(isPresented: $showAddRoutineSheet) {
                    AddAlarmSheetContent(showAddAlarmSheet: $showAddRoutineSheet)
                }
                .ignoresSafeArea(edges: .bottom)
                .zIndex(999)
            }
        }
    }
}
#Preview {
    ContentView()
}

