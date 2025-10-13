//
//  CommonTypes.swift
//  PlanT
//
//  Created by catharina J on 10/13/25.
//

import Foundation

// MARK: - 공통 타입(선택) — 안전한 표현
enum Weekday: String, Codable, CaseIterable, Hashable {
    case mon, tue, wed, thu, fri, sat, sun
}

enum DurationUnit: String, Codable {
    case minute, ml, count
}

/// 서버쪽 "주당 빈도 id"가 "3x"처럼 올 예정이면 그대로 String 유지 가능.
/// 필요하면 Int로 파싱하는 computed property만 하나 두면 됨.
extension String {
    var frequencyAsInt: Int? {
        // "3x" -> 3
        Int(self.replacingOccurrences(of: "x", with: ""))
    }
}
