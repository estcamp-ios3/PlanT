//
//  Mate.swift
//  PlanT
//
//  Created by 이지훈 on 9/30/25.
//

import Foundation

enum Mate: String, CaseIterable, Identifiable {
    case grrr = "MrGrrr"
    case nibble = "MrNibble"
    case purr = "MrPurr"
    case barky = "MrBarky"
    case zippy = "MrZippy"
    case wooly = "MrWooly"

    var id: String { rawValue }
}
