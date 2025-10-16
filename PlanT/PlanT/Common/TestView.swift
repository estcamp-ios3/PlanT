//
//  TestView.swift
//  PlanT
//
//  Created by catharina J on 10/14/25.
//

import SwiftUI

struct TestView: View {
    // Checkbox Value
    @State private var isAny = false
    @State private var isAllDay = false        // “종일”
    @State private var hasEnd = true        // “종료일”

    // RoutineDateView: Date Value
    @State private var isEnabled = false        // 수정가능
    @State private var showDateHeader = true        // 헤더 사용
    @State private var useDate = true        // “날짜 사용” 토글

    @State private var startDate = Date()        // 시작(날짜+시간)
    @State private var endDate = Calendar.current.date(byAdding: .hour, value: 1, to: Date())!        // 종료(날짜+시간)
    
    var body: some View {
        VStack(spacing: 20) {
            // MARK: - Checkbox + Label
            HStack(spacing: vertical3) {
                CheckLabelView(isChecked: $isAllDay, label: "종일")
                CheckLabelView(isChecked: $isAny, label: "종료일")
            }
            
            // MARK: - RoutineDateView
            RoutineDateView(
                isEnabled: $isEnabled,
                showDateHeader: $showDateHeader,
                useDate: $useDate,
                isAllDay: $isAllDay,
                hasEnd: $hasEnd,
                startDate: $startDate,
                endDate: $endDate
            )
            
            // 상태 확인용
            VStack(alignment: .leading, spacing: 6) {
                Text("수정가능-> \t \t \t isEnabled: \(isEnabled.description)")
                Text("날짜사용 + 토글-> \t showDateHeader:  \(showDateHeader.description)")
                Text("토글-> \t \t \t \t useDate: \(useDate.description)")
                Text("종일 체크박스-> \t isAllDay: \(isAllDay.description)")
                Text("종료일 체크박스-> \t hasEnd: \(hasEnd.description)")
                Text("시작일-> \t\t start: \(startDate.formatted(date: .abbreviated, time: .shortened))")
                Text("종료일-> \t\t end:   \(endDate.formatted(date: .abbreviated, time: .shortened))")
            }
            Button{
                isEnabled.toggle()
            } label:{
                Text(isEnabled ? "완료" : "수정")
            }
            .plantPrimaryButton()
        }
        .frame(maxWidth:.infinity)
        .padding()
    }
}

#Preview {
    TestView()
}
