//
//  ToastEvents.swift
//  PlanT
//
//  Created by 이지훈 on 10/21/25.
//

import Foundation

extension Notification.Name {
    /// Mate 토스트를 특정 메시지로 보여달라는 이벤트
    /// userInfo: ["message": String]
    static let showMateToast = Notification.Name("showMateToast")
}

/// 간편 호출용 헬퍼
enum MateToastCenter {
    /// Mate 토스트 메시지를 전역으로 뿌림
    static func show(_ message: String) {
        NotificationCenter.default.post(
            name: .showMateToast,
            object: nil,
            userInfo: ["message": message]
        )
    }
}
