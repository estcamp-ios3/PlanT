//
//  RoutineStore.swift
//  PlanT
//
//  Created by 박성관 on 10/2/25.
//
import Foundation
import SwiftData
import Combine
import Supabase
import SwiftUI

@MainActor
final class RoutineStore: ObservableObject {
    @Published private(set) var routines: [Routine] = []
    @Published var refreshTrigger = UUID()
    private var context: ModelContext
    private let client = supabaseClient
    
    init(context: ModelContext) {
        self.context = context
        loadRoutines()
    }
    
    func loadRoutines() {
        let fetchDescriptor = FetchDescriptor<Routine>()
        do {
            routines = try context.fetch(fetchDescriptor)
        } catch {
            print("X 루틴 불러오기 실패:", error)
        }
    }
    
    func addRoutine(from seed: Seed, basedOn routine: Routine, categoryId: String) {
        let newRoutine = Routine(
            title: routine.title,
            categoryId: categoryId,
            seedName: seed.name,
            duration: routine.duration,
            goal:  routine.goal,
            alarm: routine.alarm,
            frequencyPerWeekId: routine.frequencyPerWeekId,
            frequencyPerWeekTitle: routine.frequencyPerWeekTitle,
            note: routine.note,
            isCompleted: false,
            createdAt: Date(),
            modifiedAt: Date()
        )
        context.insert(newRoutine)
        do {
            try context.save()
            print(" SwiftData 저장 완료:", newRoutine.title)
        } catch {
            print("SwiftData 저장 실패:", error)
        }
        Task {
            do {
                try await client.from("routines").insert(newRoutine.dto).execute()
                print(" Supabase 업로드 완료:", newRoutine.title)
            } catch {
                print(" Supabase 업로드 실패:", error.localizedDescription)
            }
        }
        loadRoutines()
    }
    
    func deleteRoutine(_ routine: Routine) {
        context.delete(routine)
        do {
            try context.save()
            print(" SwiftData 삭제 완료:", routine.title)
        } catch {
            print("SwiftData 삭제 실패:", error)
        }
        Task {
            do {
                try await client.from("routines")
                    .delete()
                    .eq("id", value: routine.id)
                    .execute()
                print(" Supabase 삭제 완료:", routine.title)
            } catch {
                print(" Supabase 삭제 실패:", error.localizedDescription)
            }
        }
        loadRoutines()
    }
}

extension RoutineStore {
    func completedCount(for routine: Routine) -> Int {
        routine.completedCount
    }
    func totalCount(for routine: Routine) -> Int {
        Int(routine.frequencyPerWeekId.replacingOccurrences(of: "x", with: "")) ?? 0
    }
    func progress(for routine: Routine) -> Double {
        let total = totalCount(for: routine)
        guard total > 0 else { return 0}
        let completed = completedCount(for: routine)
        return min(100, (Double(completed) / Double(total)) * 100)
    }
}

extension RoutineStore {
    func increaseProgress(for routine: Routine) {
        routine.completedCount += 1
        routine.modifiedAt = .now
        
        do {
            try context.save()
            print(" SwiftData 완료횟수 증가 저장됨(\(routine.completedCount)회")
        } catch {
            print(" SwiftData 저장 실패:", error)
        }
        Task {
            do {
                try await client
                    .from("routines")
                    .update(["completed_count": routine.completedCount])
                    .eq("id", value: routine.id)
                    .execute()
                print("Supabase 완료횟수 업데이트 완료")
            } catch {
                print( "Supabase 완료횟수 업데이트 실패:", error.localizedDescription)
            }
        }
        loadRoutines()
        withAnimation(.spring()) {
             refreshTrigger = UUID()
        }
    }
}
