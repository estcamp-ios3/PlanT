//
//  RoutineDetailView.swift
//  PlanT
//
//  Created by 박성관 on 9/29/25.
//

import SwiftUI

enum RoutineRegisterMode {
    case create // 신규등록
    case edit(Routine) // 수정모드
}

struct RoutineRegisterView: View {
    
    @StateObject private var viewModel = RoutineSurveyViewModel()
    @State private var selectedCategory = "선택하세요"
    @State private var useDate = true
    @State private var dateMode: DateMode = .endDate
    @State private var startDate = Date()
    @State private var endDate = Date()
    @State private var selectedAlarms: Set<Int> = [15]
    
    let mode: RoutineRegisterMode
    
    let alarms = [30, 15, 10, 5, 1]
    
    enum DateMode { case endDate, allDay }
    
    var body: some View {
        
        ScrollView {
            VStack(spacing: 16) {
                Text("루틴 상세히보기")
                    .font(.title3)
                    .bold()
                    .padding(.top, 12)
                categorySection()
                Divider()
                dateSection()
                Divider()
                goalSection()
                Divider()
                alarmSection()
                Divider()
                
                addButton()
                
            }
            .padding(.horizontal)
            .onAppear {
                setupMode()
            }
        }
    }
}

extension RoutineRegisterView {
    private var modeTitle: String {
        switch mode {
        case .create:
            return "새 할 일 등록하기"
        case .edit:
            return "루틴 수정하기"
        }
    }
    private func setupMode() {
        switch mode {
        // 신규 등록 시 초기화
        case .create:
            selectedCategory = "선택하세요"
            useDate = true
            selectedAlarms = [15]
//        case .edit(let routine):
            // 기존 루틴 데이터를 State로 불러오기
//            selectedCategory = routine.categoryTitle
//            startDate = routine.detail.startDate
//            endDate = routine.detail.endDate
//            selectedAlarms = routine.detail.alarms
        case .edit(_):
            ""
        }
    }
}

extension RoutineRegisterView {
    @ViewBuilder
    // 카테고리 선택 + 제목
    private func categorySection() -> some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text("카테고리 선택")
                    .font(.subheadline).bold()
                
                Menu {
                    ForEach(viewModel.categoryTitles, id: \.self) { title in
                        Button {
                            selectedCategory = title
                        } label: {
                            Text(title)
                        }
                    }
                } label: {
                    HStack {
                        Text(selectedCategory)
                            .fontWeight(selectedCategory == "선택하세요" ? .regular : .bold)
                            .foregroundColor(selectedCategory == "선택하세요" ? .gray : .black)
                        if selectedCategory == "선택하세요" {
                            Image(systemName: "chevron.down")
                                .foregroundColor(.gray)
                        }
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 12)
                    .padding(.horizontal, 12)
                    .background(Color(.systemGray6))
                    .cornerRadius(8)
                }
            }
            
            TextField("루틴 제목을 입력하세요", text: .constant(""))
                .textFieldStyle(RoundedBorderTextFieldStyle())
        }
    }
}

extension RoutineRegisterView {
    @ViewBuilder
    private func dateSection() -> some View {
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
                    HStack {
                        Spacer()
                        
                        VStack(alignment: .leading, spacing: 12) {
                            DatePicker("시작일", selection: $startDate, displayedComponents: .date)
                                .datePickerStyle(.compact)
                                .labelsHidden()
                                .frame(height: 40)
                            
                            DatePicker("", selection: $startDate, displayedComponents: .hourAndMinute)
                                .datePickerStyle(.compact)
                                .labelsHidden()
                                .frame(height: 40)
                            
                        }
                        Image("greater_than_chevron_wide")
                            .resizable()
                            .frame(width: 20, height: 20)
                        
                        VStack(alignment: .leading, spacing: 12) {
                            DatePicker("종료일", selection: $endDate, displayedComponents: .date)
                                .datePickerStyle(.compact)
                                .labelsHidden()
                                .frame(height: 40)
                            
                            DatePicker("", selection: $endDate, displayedComponents: .hourAndMinute)
                                .datePickerStyle(.compact)
                                .labelsHidden()
                                .frame(height: 40)
                            
                        }
                        Spacer()
                    }
                    
                }
                
                else {
                    VStack(alignment: .leading, spacing: 12) {
                        DatePicker("종일 날짜", selection: $endDate, displayedComponents: .date)
                            .datePickerStyle(.compact)
                            .labelsHidden()
                            .frame(height: 40)
                        DatePicker("", selection: $endDate, displayedComponents: .hourAndMinute)
                            .datePickerStyle(.compact)
                            .labelsHidden()
                            .frame(height: 40)
                    }
                    .padding(.top, 8)
                }
            }
        }
    }
}

extension RoutineRegisterView {
    @ViewBuilder
    private func goalSection() -> some View {
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
            .frame(maxWidth: .infinity, alignment: .leading)
        }
    }
}

extension RoutineRegisterView {
    @ViewBuilder
    private func alarmSection() -> some View {
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
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}
extension RoutineRegisterView {
    @ViewBuilder
    private func addButton() -> some View {
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
