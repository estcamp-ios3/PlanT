//
//  ChecklistDetailView.swift
//  PlanT
//
//  Created by APPLE on 2025-10-12.
//

import SwiftUI

struct TodoListDetailView: View {
    let item: TodoListCard

    var body: some View {
        VStack {
            Text("상세 화면")
//            Text("선택된 항목: \(item.name)")
        }
        .navigationTitle("상세정보")
        .navigationBarTitleDisplayMode(.inline)
    }
}

//#Preview {
//    ChecklistDetailView()
//}
