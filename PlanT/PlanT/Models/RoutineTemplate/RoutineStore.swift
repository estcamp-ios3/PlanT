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
    
    
    
    
    func addRoutine(from seed: Seed) {
        let newRoutine = Routine(
            title: "\(seed.name) 루틴",
            detail: RoutineDetail(duration: "3일", goal: "목표 없음", alarm: .every24Hours),
            seedName: seed.name
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
