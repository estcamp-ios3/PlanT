//
//  AlarmPresetDTO.swift
//  PlanT
//
//  Created by 박성관 on 10/17/25.
//

import Foundation


struct AlarmPresetDTO: Codable, Identifiable {
    var id: UUID? = nil
    var minutes: Int
    var user_id: UUID? = nil
    var is_default: Bool = false
    var created_at: Date? = nil
}
