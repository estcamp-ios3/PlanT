//
//  RoutineDetail.swift
//  PlanT
//
//  Created by 박성관 on 10/7/25.
//

import Foundation

// NOTE: Do not add @MainActor or other actor isolation here, as SwiftData requires Codable conformances to be nonisolated.
enum AlarmCycle: String, Codable {
    case every24Hours
    case every48Hours
}

struct RoutineDetail: Codable, Equatable {
    var duration: String
    var goal: String
    var alarm: AlarmCycle
}
