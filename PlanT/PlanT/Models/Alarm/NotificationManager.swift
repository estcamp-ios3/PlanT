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

    // MARK: - 권한 요청
    func requestPermission() {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .badge, .sound]) { granted, error in
            if let error = error {
                print(" 알림 권한 요청 실패: \(error)")
            } else {
                print(granted ? " 알림 권한 허용" : " 알림 권한 거부")
            }
        }
    }

    // MARK: - 알림 예약
    func scheduleNotification(
        for routineID: UUID,
        title: String,
        baseDate: Date,
        offsets: [Int],
        weekdays: [Weekday]? = nil   //  요일 기반 반복 알림 지원
    ) {
        let center = UNUserNotificationCenter.current()        
        let calendar = Calendar.current

        //  요일 반복 알림이 지정된 경우
        if let weekdays = weekdays, !weekdays.isEmpty {
            for day in weekdays {
                let weekdayNumber = weekdayToCalendarValue(day)
                for offset in offsets {
                    var dateComponents = calendar.dateComponents([.hour, .minute], from: baseDate)
                    dateComponents.weekday = weekdayNumber
                    
                    let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: true)
                    
                    let content = UNMutableNotificationContent()
                    content.title = title
                    content.body = "오늘의 루틴을 시작할 시간이에요!"
                    content.sound = .default
                    
                    let request = UNNotificationRequest(
                        identifier: "\(routineID.uuidString)-\(day.rawValue)-\(offset)",
                        content: content,
                        trigger: trigger
                    )
                    center.add(request)
                    print(" 반복 알림 예약됨: \(day.rawValue)요일, \(dateComponents.hour ?? 0):\(dateComponents.minute ?? 0)")
                }
            }
            return
        }
        
        // ✅ 단발성 알림 (요일 지정 없을 때)
        for offset in offsets {
            let triggerDate = baseDate.addingTimeInterval(TimeInterval(-offset * 60))
            
            if triggerDate <= Date() {
                continue
            }
            
            let content = UNMutableNotificationContent()
            content.title = title
            content.body = "\(offset)분 후에 시작할 시간이에요!"
            content.sound = .default
            
            let trigger = UNCalendarNotificationTrigger(
                dateMatching: calendar.dateComponents([.year, .month, .day, .hour, .minute], from: triggerDate),
                repeats: false
            )
            
            let requestID = "\(routineID.uuidString)_\(offset)"
            let request = UNNotificationRequest(identifier: requestID, content: content, trigger: trigger)
            center.add(request)
            
            print(" 단발 알림 예약됨: \(requestID)")
            print(" 기준시간: \(baseDate)")
            print(" 트리거시각: \(triggerDate)")
        }
        
    }

    // MARK: - 알림 취소
    func cancelNotifications(for routineId: UUID) {
        let center = UNUserNotificationCenter.current()
        center.getPendingNotificationRequests { requests in
            let relatedIds = requests
                .filter { $0.identifier.hasPrefix(routineId.uuidString) }
                .map { $0.identifier }
            center.removePendingNotificationRequests(withIdentifiers: relatedIds)
            print("루틴 \(routineId) 관련 알림 제거됨: \(relatedIds)")
        }
    }

    // MARK: - 디버그용 로그
    func debugPendingNotifications() {
        UNUserNotificationCenter.current().getPendingNotificationRequests { requests in
            for request in requests {
                if let trigger = request.trigger as? UNCalendarNotificationTrigger,
                   let date = trigger.nextTriggerDate() {
                    print("""
                        ID: \(request.identifier)
                        Title: \(request.content.title)
                        Body: \(request.content.body)
                        Next Trigger: \(NotificationManager.localString(date))
                        """)
                } else {
                }
            }
        }
    }

    // MARK: - 요일 변환 (Weekday → Calendar.weekday)
    private func weekdayToCalendarValue(_ day: Weekday) -> Int {
        switch day {
        case .sun: return 1
        case .mon: return 2
        case .tue: return 3
        case .wed: return 4
        case .thu: return 5
        case .fri: return 6
        case .sat: return 7
        }
    }
}

extension NotificationManager {
    func scheduleTomorrow9AMNotification(for routine: Routine) {
        let calendar = Calendar.current
        
        let tomorrow = calendar.date(byAdding: .day, value: 1, to: Date())!
        let baseDate = calendar.date(bySettingHour: 9, minute: 0, second: 0, of: tomorrow
        ) ?? tomorrow
        
        let offset = 15
        
        let triggerDate = baseDate.addingTimeInterval(-Double(offset) * 60)
        
        print(" 내일 9시 루틴 알림 예약됨 -> \(NotificationManager.localString(triggerDate))")
        
        let content = UNMutableNotificationContent()
                content.title = routine.title
                content.body = "\(offset) 후에 루틴을 시작할 시간이에요!"
                content.sound = .default
                
                let trigger = UNCalendarNotificationTrigger(
                    dateMatching: calendar.dateComponents([.year, .month, .day, .hour, .minute], from: triggerDate),
                    repeats: false
                )
                
                let request = UNNotificationRequest(
                    identifier: "\(routine.id.uuidString)_tomorrow",
                    content: content,
                    trigger: trigger
                )
                
                UNUserNotificationCenter.current().add(request)
                print(" 내일 루틴 알림 등록 완료 (\(routine.title))")
    }
    static func localString(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "Ko_KR")
        formatter.timeZone = .current
        formatter.dateFormat = "yyyy년 MM월 dd일 (E) HH:mm:ss ZZZZ"
        return formatter.string(from: date)
    }
}





