//
//  TodoListViewModel.swift
//  PlanT
//
//  Created by APPLE on 2025-10-13.
//

import Foundation

// 개별 체크리스트 항목을 위한 모델
struct TodoListCheckItem: Identifiable, Hashable {
    let id = UUID()
    var text: String
    var isChecked: Bool
}

// 체크리스트 카드(그룹)를 위한 모델
struct TodoListCard: Identifiable, Hashable {
    let id = UUID()
    var title: String
    var items: [TodoListCheckItem]
}
