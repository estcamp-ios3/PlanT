//
//  Routine.swift
//  PlanT
//
//  Created by 박성관 on 10/2/25.
//

import Foundation

// MARK: - 루틴 모델
// 개별 루틴 하나를 표현하는 데이터
struct Routine: Identifiable, Equatable {
    var id = UUID()
    var title: String
    var detail: RoutineDetail
    var seed: Seed? = nil
    var description: String?
    var isCompleted: Bool = false
}




