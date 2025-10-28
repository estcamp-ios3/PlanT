//
//  RoutineAlarm.swift
//  PlanT
//
//  Created by 박성관 on 10/18/25.
//

import Foundation
import SwiftData


@Model
final class RoutineAlarm {
    var id = UUID()
    var routineId: UUID
    var offset: Int
    
    init(routineId: UUID, offset: Int) {
        self.routineId = routineId
        self.offset = offset
    }
}
