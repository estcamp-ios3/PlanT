//
//  RoutineAlarmStore.swift
//  PlanT
//
//  Created by 박성관 on 10/18/25.
//

import Foundation
import SwiftData
import SwiftUI
import Combine

@MainActor
final class RoutineAlarmStore: ObservableObject {
    private var context: ModelContext
    
    init(context: ModelContext) {
        self.context = context
    }
    
    func fetchOffsets(for routineId: UUID) -> [Int] {
        do {
        let descriptor = FetchDescriptor<RoutineAlarm>(
            predicate: #Predicate { $0.routineId == routineId }
        )
            let alarms = try context.fetch(descriptor)
            return alarms.map { $0.offset }
        } catch {
            print(" RoutineAlarm fetch 실패:", error)
            return []
        }
    }
    func saveOffsets(for routineId: UUID, offsets: [Int]) {
        deleteOffsets(for: routineId)
        
        for offset in offsets {
            let alarm = RoutineAlarm(routineId: routineId, offset: offset)
            context.insert(alarm)
        }
        do {
            try context.save()
            print(" RoutineAlarm 저장 완료:", offsets)
        } catch {
            print(" RoutineAlarm 저장 실패:", error)
        }
    }
    
    func deleteOffsets(for routineId: UUID) {
        let descriptor = FetchDescriptor<RoutineAlarm>(
            predicate: #Predicate { $0.routineId == routineId }
        )
        do {
            let alarms = try context.fetch(descriptor)
            alarms.forEach { context.delete($0) }
            try context.save()
        } catch {
            print(" RoutineAlarm 삭제 실패:", error)
        }
    }
    
}
