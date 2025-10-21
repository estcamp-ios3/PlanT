//
//  ToastEvents.swift
//  PlanT
//
//  Created by 이지훈 on 10/21/25.
//

import Foundation

extension Notification.Name {
    static let showMateToast = Notification.Name("showMateToast")
}

/// 간편 호출용 헬퍼
enum MateToastCenter {
    static func show(_ message: String) {
        NotificationCenter.default.post(
            name: .showMateToast,
            object: nil,
            userInfo: ["message": message]
        )
    }
}
