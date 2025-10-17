//
//  Routine.swift
//  PlanT
//
//  Created by 박성관 on 10/2/25.
//

import Foundation
import SwiftData

enum AlarmCycle: String, Codable {
    case every24Hours = "every24Hours"
    case every48Hours = "every48Hours"
    case off = "off"
}
var seedName: String?
var seedPrefix: String?
// MARK: - 루틴 모델
// 개별 루틴 하나를 표현하는 데이터
@Model
final class Routine: Identifiable{
    var id = UUID()
    var title: String
    
    var categoryId: String
    var seedName: String?
    
    var duration: String
    var goal: String
    var alarm: AlarmCycle
    
    var frequencyPerWeekId: String
    var frequencyPerWeekTitle: String
    
    var note: String?
    var isCompleted: Bool = false
    var completedCount: Int = 0
    var createdAt: Date
    var modifiedAt: Date

    init(
        id: UUID = UUID(),
        title: String,
        categoryId: String,
        
        seedName: String? = nil,
        duration: String,
        goal: String,
        alarm: AlarmCycle,
        
        frequencyPerWeekId: String,
        frequencyPerWeekTitle: String,
        
        note: String? = nil,
        isCompleted: Bool = false,
        completedCount: Int = 0,
        createdAt: Date = Date(),
        modifiedAt: Date = Date()
    ) {
        
        self.id = id
        self.title = title
        self.duration = duration
        self.goal = goal
        self.alarm = alarm
        self.frequencyPerWeekId = frequencyPerWeekId
        self.frequencyPerWeekTitle = frequencyPerWeekTitle

        self.categoryId = categoryId
        self.seedName = seedName
        self.note = note
        self.isCompleted = isCompleted
        self.completedCount = completedCount
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
    var completedCount: Int
    var duration: String
    var goal: String
    var alarm: String
    var frequencyPerWeekId: String
    var frequencyPerWeekTitle: String
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
            case frequencyPerWeekId = "frequency_per_week_id"
            case frequencyPerWeekTitle = "frequency_per_week_title"
            case completedCount = "completed_count"
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
            completedCount: completedCount,
            duration: duration,
            goal: goal,
            alarm: alarm.rawValue,
            frequencyPerWeekId: frequencyPerWeekId,
            frequencyPerWeekTitle: frequencyPerWeekTitle,
            createdAt: createdAt,
            modifiedAt: modifiedAt
        )
    }
}


