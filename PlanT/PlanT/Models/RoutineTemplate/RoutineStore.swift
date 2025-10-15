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

@MainActor
final class RoutineStore: ObservableObject {
    @Published private(set) var routines: [Routine] = []
    
    private var context: ModelContext
    private let client = SupabaseManager.shared.client
    
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
            detail: routine.detail,
            categoryId: categoryId,
            seedName: seed.name,
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
