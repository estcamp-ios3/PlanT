//
//  RoutineDetailView.swift
//  PlanT
//
//  Created by 박성관 on 9/29/25.
//

import SwiftUI

struct RoutineDetailView: View {
    enum DateMode {
        case endDate, allDay
    }
    
    @State private var dateMode: DateMode = .endDate
    @State private var useDate: Bool = true
    
    @State private var startDate = Date()
    @State private var endDate = Date()
    
    let alarms = [30, 15, 10, 5, 1]
    @State private var selectedAlarms: Set<Int> = [15]
    
    var body: some View {
        VStack(spacing: 16) {
            Text("루틴 상세히보기")
                .font(.title3)
                .bold()
                .padding(.top, 12)
            ScrollView {
                VStack(alignment: .leading, spacing: 24) {
                    
                    // 카테고리 선택 + 제목
                    VStack(alignment: .leading, spacing: 8) {
                        Text("카테고리 선택")
                            .font(.subheadline).bold()
                        TextField("루틴 제목을 입력하세요", text: .constant(""))
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                    }
                    
                    Divider()
                    
                    // 날짜 사용
                    VStack(alignment: .leading, spacing: 8) {
                        HStack {
                            Text("날짜 사용")
                                .font(.subheadline).bold()
                            Spacer()
                            Toggle("", isOn: $useDate)
                                .labelsHidden() 
                        }
                        
                        if useDate {
                            // 종료일 / 종일 버튼 그룹
                            HStack(spacing: 16) {
                                RadioButton(
                                    label: "종료일",
                                    isSelected: dateMode == .endDate
                                ) {
                                    dateMode = .endDate
                                }
                                
                                RadioButton(
                                    label: "종일",
                                    isSelected: dateMode == .allDay
                                ) {
                                    dateMode = .allDay
                                }
                            }
                            
                            // 모드에 따른 DatePicker
                            if dateMode == .endDate {
                                VStack(spacing: 12) {
                                    DatePicker("시작일", selection: $startDate, displayedComponents: [.date, .hourAndMinute])
                                    DatePicker("종료일", selection: $endDate, displayedComponents: [.date, .hourAndMinute])
                                }
                                .padding(.top, 8)
                            } else {
                                VStack(spacing: 12) {
                                    DatePicker("종일 날짜", selection: $startDate, displayedComponents: .date)
                                }
                                .padding(.top, 8)
                            }
                        }
                    }
                    
                    Divider()
                    
                    // 목표
                    VStack(alignment: .leading, spacing: 8) {
                        Text("목표")
                            .font(.subheadline).bold()
                        HStack {
                            TextField("3", text: .constant("3"))
                                .frame(width: 40)
                                .textFieldStyle(RoundedBorderTextFieldStyle())
                            Text("일")
                            TextField("24", text: .constant("24"))
                                .frame(width: 50)
                                .textFieldStyle(RoundedBorderTextFieldStyle())
                            Text("시간 마다")
                            TextField("5page", text: .constant("5page"))
                                .frame(width: 80)
                                .textFieldStyle(RoundedBorderTextFieldStyle())
                            Text("하기")
                        }
                    }
                    
                    Divider()
                    
                    // 알림
                    VStack(alignment: .leading, spacing: 8) {
                        Text("알림")
                            .font(.subheadline).bold()
                        HStack {
                            ForEach(alarms, id: \.self) { minute in
                                Button(action: {
                                    if selectedAlarms.contains(minute) {
                                        selectedAlarms.remove(minute)
                                    } else {
                                        selectedAlarms.insert(minute)
                                    }
                                }) {
                                    Text("\(minute)분 전")
                                        .font(.subheadline)
                                        .padding(.vertical, 8)
                                        .padding(.horizontal, 10)
                                        .background(selectedAlarms.contains(minute) ? Color.orange : Color.gray.opacity(0.2))
                                        .foregroundColor(.black)
                                        .cornerRadius(8)
                                }
                                
                            }
                        }
                    }
                    
                    Spacer(minLength: 50)
                    
                    // 삭제/수정 버튼
                    HStack(spacing: 16) {
                        Button(action: { print("삭제") }) {
                            Text("삭제")
                                
                        }
                        .plantSecondaryButton()

                        
                        Button(action: { print("수정") }) {
                            Text("수정")
                        }
                        .plantPrimaryButton()
                        
                    }
                }
                .padding(.horizontal)
            }
        }
    }
}


struct RadioButton: View {
    let label: String
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: 8) {
                ZStack {
                    Circle()
                        .stroke(Color.gray, lineWidth: 2)
                        .frame(width: 24, height: 24)
                    
                    if isSelected {
                        Circle()
                            .fill(Color.blue)
                            .frame(width: 20, height: 20)
                        Image(systemName: "checkmark")
                            .font(.system(size: 12, weight: .bold))
                            .foregroundColor(.white)
                    }
                }
                Text(label)
                    .font(.subheadline)
                    .foregroundColor(.black)
            }
        }
        .buttonStyle(.plain)
    }
}

#Preview {
    RoutineDetailView()
}

