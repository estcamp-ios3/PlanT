
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
        print("💾 [saveOffsets] 호출됨: routineId=\(routineId), offsets=\(offsets)")

        // 기존 알림 삭제
        let descriptor = FetchDescriptor<RoutineAlarm>(
            predicate: #Predicate { $0.routineId == routineId }
        )
        do {
            let existing = try context.fetch(descriptor)
            for alarm in existing {
                context.delete(alarm)
            }
            print("🧹 [saveOffsets] 기존 알림 \(existing.count)개 삭제 완료")

            // 새 알림 저장
            for offset in offsets {
                let newAlarm = RoutineAlarm(routineId: routineId, offset: offset)
                context.insert(newAlarm)
            }
            try context.save()
            print("✅ [saveOffsets] \(offsets.count)개 저장 완료")

        } catch {
            print("❌ [saveOffsets] 저장 실패: \(error)")
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
