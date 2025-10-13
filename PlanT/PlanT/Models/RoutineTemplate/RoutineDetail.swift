//
//  RoutineDetail.swift
//  PlanT
//
//  Created by 박성관 on 10/7/25.
//

import Foundation

enum AlarmCycle: String, Codable {
    case every24Hours
    case every48Hours
}

struct RoutineDetail: Codable, Equatable {
    var duration: String
    var goal: String
    var alarm: AlarmCycle
}
