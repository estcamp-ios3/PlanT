//
//  RoutineStore.swift
//  PlanT
//
//  Created by 박성관 on 10/2/25.
//
import Foundation
import Combine

class RoutineStore: ObservableObject {
    @Published var routines: [Routine] = []
    
    func addRoutine(from seed: Seed) {
        let newRoutine = Routine(
            title: "\(seed.name) 루틴",
            detail: RoutineDetail(duration: "3일", goal: "목표 없음", alarm: .every24Hours),
            seed: seed
        )
        routines.insert(newRoutine, at: 0)
    }
    
    func deleteRoutine(_ routine: Routine) {
        routines.removeAll { $0.id == routine.id }
    }
}
