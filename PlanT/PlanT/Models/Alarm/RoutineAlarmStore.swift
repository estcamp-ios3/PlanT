
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

    // MARK: - 특정 루틴의 알람 오프셋 불러오기
    func fetchOffsets(for routineId: UUID) -> [Int] {
        let descriptor = FetchDescriptor<RoutineAlarm>(
            predicate: #Predicate { $0.routineId == routineId }
        )
        do {
            let alarms = try context.fetch(descriptor)
            return alarms.map { $0.offset }.sorted()
        } catch {
            print("❌ RoutineAlarm fetch 실패:", error)
            return []
        }
    }

    // MARK: - 특정 루틴의 알람 오프셋 저장
    func saveOffsets(for routineId: UUID, offsets: [Int]) {
        // 1️⃣ 기존 알람 삭제 (중복 방지)
        deleteOffsets(for: routineId)

        // 2️⃣ 새로운 알람 저장
        for offset in offsets {
            let alarm = RoutineAlarm(routineId: routineId, offset: offset)
            context.insert(alarm)
        }

        do {
            try context.save()
            print("✅ [RoutineAlarmStore] 오프셋 저장 완료 → \(offsets)")
        } catch {
            print("❌ RoutineAlarm 저장 실패:", error)
        }
    }

    // MARK: - 특정 루틴의 알람 오프셋 삭제
    func deleteOffsets(for routineId: UUID) {
        let descriptor = FetchDescriptor<RoutineAlarm>(
            predicate: #Predicate { $0.routineId == routineId }
        )
        do {
            let alarms = try context.fetch(descriptor)
            for alarm in alarms {
                context.delete(alarm)
            }
            try context.save()
            print("🗑️ [RoutineAlarmStore] 오프셋 삭제 완료 → \(routineId)")
        } catch {
            print("❌ RoutineAlarm 삭제 실패:", error)
        }
    }
}
