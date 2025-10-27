//
//  String+Extension.swift
//  PlanT
//
//  Created by 박성관 on 10/27/25.
//

import Foundation

extension String {
    /// "21일", "35일" 등 문자열을 일수(Int)로 변환
    func extractDays() -> Int {
        let digits = self.filter { $0.isNumber }
        return Int(digits) ?? 1
    }
}
