//
//  NotificationManager.swift
//  PlanT
//
//  Created by 박성관 on 10/18/25.
//
import Foundation
import UserNotifications

final class NotificationManager {
    static let shared = NotificationManager()
    private init() {}

    func requestPermission() {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .badge, .sound]) { granted, error in
            if let error = error {
                print(" 알림 권한 요청 실패: \(error)")
            } else {
                print(granted ? "알림 권한 허용" : "알림 권한 거부")
            }
        }
    }

func scheduleNotification(
    for routineID: UUID,
    title: String,
    baseDate: Date,
    offsets: [Int]
) {
    let center = UNUserNotificationCenter.current()
    cancelNotifications(for: routineID)
    
    for offset in offsets {
        let triggerDate = Calendar.current.date(byAdding: .minute, value: -offset, to: baseDate) ?? baseDate
        
        if triggerDate <= Date() {
            print(" \(offset)분 전 알람은 현재 시간보다 이전이라 스킵됨")
            continue
        }
        let content = UNMutableNotificationContent()
        content.title = "\(title)"
        content.body = "\(offset)분 후에 시작할 시간이에요!"
        content.sound = .default
        
        let trigger = UNCalendarNotificationTrigger(
            dateMatching: Calendar.current.dateComponents([.year, .month, .day, .hour, .minute], from: triggerDate),
            repeats: false
        )
        let requestID = "\(routineID.uuidString)_\(offset)"
        let request = UNNotificationRequest(identifier: requestID, content: content, trigger: trigger)
        
        center.add(request)
        print("알림 예약됨: \(requestID)")
        self.debugPendingNotifications()
    }
}
    
    func cancelNotifications(for routineID: UUID) {
        UNUserNotificationCenter.current().getPendingNotificationRequests { requests in
            let idsToRemove = requests
                .map { $0.identifier }
                .filter { $0.starts(with: routineID.uuidString) }
            
            UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: idsToRemove)
            print(" 삭제된 알림 ID들:", idsToRemove)
        }
    }
    func debugPendingNotifications() {
        UNUserNotificationCenter.current().getPendingNotificationRequests { requests in
            print(" 현재 등록된 알림 수: \(requests.count)")
            for request in requests {
                if let trigger = request.trigger as? UNCalendarNotificationTrigger,
                   let date = trigger.nextTriggerDate() {
                    print("""
                        ID: \(request.identifier)
                        Title: \(request.content.title)
                        Body: \(request.content.body)
                        Next Trigger: \(date)
                        """)
                } else {
                    print( "ID: \(request.identifier) - 트리거 정보 없음 또는 반복 알림")
                }
            }
        }
    }
}

