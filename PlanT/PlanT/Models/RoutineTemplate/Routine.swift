//
//  Routine.swift
//  PlanT
//
//  Created by 박성관 on 10/2/25.
//

import Foundation
import SwiftData

// MARK: - 루틴 모델
// 개별 루틴 하나를 표현하는 데이터
@Model
final class Routine: Identifiable {
    var id = UUID()
    var title: String
    var detail: RoutineDetail
    var categoryId: String
    var seedName: String?
    var note: String?
    var isCompleted: Bool = false
    var createdAt: Date
    var modifiedAt: Date

    init(
        id: UUID = UUID(),
        title: String,
        detail: RoutineDetail,
        categoryId: String,
        seedName: String? = nil,
        note: String? = nil,
        isCompleted: Bool = false,
        createdAt: Date = Date(),
        modifiedAt: Date = Date()
    ) {
        self.id = id
        self.title = title
        self.detail = detail
        self.categoryId = categoryId
        self.seedName = seedName
        self.note = note
        self.isCompleted = isCompleted
        self.createdAt = createdAt
        self.modifiedAt = modifiedAt
    }
}

struct RoutineDTO: Codable {
    var id: UUID
    var title: String
    var categoryId: String
    var seedName: String?
    var note: String?
    var isCompleted: Bool
    var duration: String
    var goal: String
    var alarm: String
    var createdAt: Date
    var modifiedAt: Date
    
    enum CodingKeys: String, CodingKey {
            case id
            case title
            case categoryId = "category_id"
            case seedName = "seed_name"
            case note
            case isCompleted = "is_completed"
            case duration
            case goal
            case alarm
            case createdAt = "created_at"
            case modifiedAt = "modified_at"
        }
}

@MainActor
extension Routine {
    var dto: RoutineDTO {
        RoutineDTO(
            id: id,
            title: title,
            categoryId: categoryId,
            seedName: seedName,
            note: note,
            isCompleted: isCompleted,
            duration: detail.duration,
            goal: detail.goal,
            alarm: detail.alarm.rawValue,
            createdAt: createdAt,
            modifiedAt: modifiedAt
            )
    }

}
