//
//  RoutineStore.swift
//  PlanT
//
//  Created by 박성관 on 10/2/25.
//
import Foundation
import SwiftData
import Combine

@MainActor
final class RoutineStore: ObservableObject {
    @Published private(set) var routines: [Routine] = []
    
    private var context: ModelContext
    
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
    
    
    
    
    func addRoutine(from seed: Seed, basedOn routine: Routine) {
        let newRoutine = Routine(
            title: routine.title,
            detail: routine.detail,
            seedName: seed.name,
            createdAt: Date(),
            modifiedAt: Date()
        )
        context.insert(newRoutine)
        
        do {
            try context.save()
            loadRoutines()
        } catch {
            print("X 루틴 저장 실패:", error)
        }
    }
    
    func deleteRoutine(_ routine: Routine) {
        context.delete(routine)
        do {
            try context.save()
            loadRoutines()
        } catch {
            print("X 루틴 삭제 실패:", )
        }
    }
}
