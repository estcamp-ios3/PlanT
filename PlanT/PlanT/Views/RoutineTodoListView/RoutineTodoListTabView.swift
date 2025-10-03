//
//  RoutineTodoListTabView.swift
//  PlanT
//
//  Created by catharina J on 9/29/25.
//

import SwiftUI

struct RoutineTodoListTabView: View {
    @Binding var path: NavigationPath
    enum Segment: String, CaseIterable, Identifiable {
        case routine = "Routine"
        case todo = "Todo"
        var id: Self { self }
        var title: String {
            switch self {
            case .routine: return "Routine"
            case .todo: return "Todo"
            }
        }
    }

    @State private var selected: Segment = .routine

    // 샘플 데이터 (필요 시 실제 데이터로 교체)
    private let routines: [String] = ["아침 운동", "물 마시기", "독서 30분"]
    private let todos: [String] = ["정우님", "뚜두", "뷰"]

    var body: some View {
        VStack(spacing: 12) {
            Picker("목록 유형", selection: $selected) {
                ForEach(Segment.allCases) { seg in
                    Text(seg.title).tag(seg)
                }
            }
            .pickerStyle(.segmented)
            .padding([.horizontal, .top])

            if selected == .routine {
                RoutineListView(path: $path)
            } else {
                TodoListView()
                    .listStyle(.insetGrouped)
//                List(todos, id: \.self) { item in
//                    Text("item")
//                }
//                .listStyle(.insetGrouped)
            }
        }
    }
}


