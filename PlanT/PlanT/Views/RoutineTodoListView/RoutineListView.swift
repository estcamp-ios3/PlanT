//
//  RoutineListView.swift
//  PlanT
//
//  Created by catharina J on 9/29/25.
//

import SwiftUI

struct RoutineListView: View {
    var body: some View {
        ScrollView {
            VStack(spacing: vertical5) {
                Text("Routine List")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                Text("여기에 루틴이 추가됩니다.")
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .init(horizontal: .leading, vertical: .top))

        }
        .padding(20)
        .overlay(alignment: .bottomTrailing) {
            Button { /* action */ } label: { Image(systemName: "plus") }
                .plantFABStyle(diameter: 56, iconSize: 30, useAccent: true)
                .padding(20)
        }
    }
}

#Preview {
    RoutineListView()
}
