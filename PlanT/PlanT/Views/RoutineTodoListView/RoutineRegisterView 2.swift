////
////  RoutineDetailView.swift
////  PlanT
////
////  Created by 박성관 on 9/29/25.
////
//
//import SwiftUI
//import SwiftData
//
//enum RoutineRegisterMode: Equatable {
//    case create // 신규등록
//    case details(Routine) // 자세히보기
//    case edit(Routine) // 수정모드
//}
//
//struct RoutineRegisterView: View {
//    @EnvironmentObject var store: RoutineStore
//    @Environment(\.modelContext) private var context
//    @Environment(\.dismiss) private var dismiss
//
//    @State private var routineTitle: String = ""
//    @StateObject private var viewModel = RoutineSurveyViewModel()
//    @State private var selectedCategory = "선택하세요"
//    @State private var useDate = true
//    @State private var dateMode: DateMode = .endDate
//    @State private var startDate = Date()
//    @State private var endDate = Date()
//    @State private var selectedAlarms: Set<Int> = [15]
//    @State private var currentMode: RoutineRegisterMode
//    @State private var goToseedStatus = false
//    @State private var goalDays: String = "3"
//    @State private var goalHours: String = "24"
//    @State private var goalTask: String = "5page"
//    @Binding var path: NavigationPath
//
//    private var isFormValid: Bool {
//        selectedCategory != "선택하세요" &&
//        !routineTitle.trimmingCharacters(in: .whitespaces).isEmpty
//    }
//
//    private var isDetailsMode: Bool {
//        if case .details = currentMode { true } else { false }
//    }
//
//    let alarms = [30, 15, 10, 5, 1]
//
//    enum DateMode { case endDate, allDay }
//
//    init(mode: RoutineRegisterMode, categoryTitle: String? = nil, path: Binding<NavigationPath>) {
//        _currentMode = State(initialValue: mode)
//        if let categoryTitle = categoryTitle {
//            _selectedCategory = State(initialValue: categoryTitle)
//        }
//        self._path = path // ADD: path binding
//    }
//
//    var body: some View {
//        ScrollView {
//            VStack(spacing: 16) {
//                categorySection()
//                Divider()
//                dateSection()
//                Divider()
//                goalSection()
//                Divider()
//                alarmSection()
//                Divider()
//                addButton()
//            }
//            .padding(.horizontal)
//            .onAppear { setupMode() }
//            .disabled(isDetailsMode)
//        }
//        .navigationTitle(modeTitle)
//        .toolbar { toolbarContent() }
//        .navigationDestination(isPresented: $goToseedStatus) {
//            SeedStatusView(
//                state: .notPlanted,
//                draft: draft,
//                path: $path
//            )
//        }
//    }
//}
//
//extension RoutineRegisterView {
//    private var modeTitle: String {
//        switch currentMode {
//        case .create:
//            return "새 할 일 등록하기"
//        case .details:
//            return "루틴 자세히 보기"
//        case .edit:
//            return "루틴 수정하기"
//        }
//    }
//    private func setupMode() {
//        switch currentMode {
//        case .create:
//            selectedCategory = "선택하세요"
//            useDate = true
//            selectedAlarms = [15]
//        case .details(let routine),
//             .edit(let routine):
//            routineTitle = routine.title
//            if selectedCategory == "선택하세요" {
//                selectedCategory = "알 수 없는 카테고리"
//            }
//            startDate = Date()
//            endDate = Date()
//            selectedAlarms = [15]
//        }
//    }
//}
//
//extension RoutineRegisterView {
//    private var draft: RoutineDraft {
//        return RoutineDraft(
//            categoryId: selectedCategory,
//            categoryTitle: selectedCategory,
//            routineTypeId: routineTitle,
//            routineTypeTitle: routineTitle,
//            frequencyPerWeekId: "3x",
//            frequencyPerWeekTitle: "주 3회",
//            durationId: "3일",
//            durationTitle: "3일",
//            periodIsNoLimit: !useDate,
//            reminderOn: !selectedAlarms.isEmpty,
//            goal: "\(goalDays)일 \(goalHours)시간마다 \(goalTask) 하기",
//            isFavorite: false
//        )
//    }
//}
//
//extension RoutineRegisterView {
//    @ViewBuilder
//    private func categorySection() -> some View {
//        VStack(alignment: .leading, spacing: 8) {
//            HStack {
//                Text("카테고리 선택")
//                    .font(.subheadline).bold()
//
//                if case .details = currentMode {
//                    Text(selectedCategory)
//                        .padding(.vertical, 12)
//                        .padding(.horizontal, 12)
//                        .frame(maxWidth: .infinity, alignment: .leading)
//                        .background(Color(.systemGray6))
//                        .cornerRadius(8)
//                } else {
//                    Menu {
//                        ForEach(viewModel.categoryTitles, id: \.self) { title in
//                            Button {
//                                selectedCategory = title
//                            } label: {
//                                Text(title)
//                            }
//                        }
//                    } label: {
//                        HStack {
//                            Text(selectedCategory)
//                                .fontWeight(selectedCategory == "선택하세요" ? .regular : .bold)
//                                .foregroundColor(selectedCategory == "선택하세요" ? .gray : .black)
//                            if selectedCategory == "선택하세요" {
//                                Image(systemName: "chevron.down")
//                                    .foregroundColor(.gray)
//                            }
//                        }
//                        .frame(maxWidth: .infinity)
//                        .padding(.vertical, 12)
//                        .padding(.horizontal, 12)
//                        .background(Color(.systemGray6))
//                        .cornerRadius(8)
//                    }
//                }
//            }
//            if case .details = currentMode {
//                Text(routineTitle)
//                    .padding(.vertical, 12)
//                    .padding(.horizontal, 12)
//                    .frame(maxWidth: .infinity, alignment: .leading)
//                    .background(Color(.systemGray6))
//                    .cornerRadius(8)
//            } else {
//                TextField("루틴 제목을 입력하세요", text: $routineTitle)
//                    .textFieldStyle(RoundedBorderTextFieldStyle())
//            }
//        }
//    }
//}
//
//extension RoutineRegisterView {
//    @ViewBuilder
//    private func dateSection() -> some View {
//        VStack(alignment: .leading, spacing: 8) {
//            HStack {
//                Text("날짜 사용")
//                    .font(.subheadline).bold()
//                Spacer()
//                Toggle("", isOn: $useDate)
//                    .labelsHidden()
//            }
//
//            if useDate {
//                HStack(spacing: 16) {
//                    RadioButton(
//                        label: "종료일",
//                        isSelected: dateMode == .endDate
//                    ) {
//                        dateMode = .endDate
//                    }
//
//                    RadioButton(
//                        label: "종일",
//                        isSelected: dateMode == .allDay
//                    ) {
//                        dateMode = .allDay
//                    }
//                }
//
//                if dateMode == .endDate {
//                    HStack {
//                        Spacer()
//                        VStack(alignment: .leading, spacing: 12) {
//                            DatePicker("시작일", selection: $startDate, displayedComponents: .date)
//                                .datePickerStyle(.compact)
//                                .labelsHidden()
//                                .frame(height: 40)
//                            DatePicker("", selection: $startDate, displayedComponents: .hourAndMinute)
//                                .datePickerStyle(.compact)
//                                .labelsHidden()
//                                .frame(height: 40)
//                        }
//                        Image("greater_than_chevron_wide")
//                            .resizable()
//                            .frame(width: 20, height: 20)
//                        VStack(alignment: .leading, spacing: 12) {
//                            DatePicker("종료일", selection: $endDate, displayedComponents: .date)
//                                .datePickerStyle(.compact)
//                                .labelsHidden()
//                                .frame(height: 40)
//                            DatePicker("", selection: $endDate, displayedComponents: .hourAndMinute)
//                                .datePickerStyle(.compact)
//                                .labelsHidden()
//                                .frame(height: 40)
//                        }
//                        Spacer()
//                    }
//                } else {
//                    VStack(alignment: .leading, spacing: 12) {
//                        DatePicker("종일 날짜", selection: $endDate, displayedComponents: .date)
//                            .datePickerStyle(.compact)
//                            .labelsHidden()
//                            .frame(height: 40)
//                        DatePicker("", selection: $endDate, displayedComponents: .hourAndMinute)
//                            .datePickerStyle(.compact)
//                            .labelsHidden()
//                            .frame(height: 40)
//                    }
//                    .padding(.top, 8)
//                }
//            }
//        }
//    }
//}
//
//extension RoutineRegisterView {
//    @ViewBuilder
//    private func goalSection() -> some View {
//        VStack(alignment: .leading, spacing: 8) {
//            Text("목표")
//                .font(.subheadline).bold()
//            HStack {
//                TextField("3", text: $goalDays)
//                    .frame(width: 40)
//                    .textFieldStyle(RoundedBorderTextFieldStyle())
//                Text("일")
//                TextField("24", text: $goalHours)
//                    .frame(width: 50)
//                    .textFieldStyle(RoundedBorderTextFieldStyle())
//                Text("시간 마다")
//                TextField("5page", text: $goalTask)
//                    .frame(width: 80)
//                    .textFieldStyle(RoundedBorderTextFieldStyle())
//                Text("하기")
//            }
//            .frame(maxWidth: .infinity, alignment: .leading)
//        }
//    }
//}
//
//extension RoutineRegisterView {
//    @ViewBuilder
//    private func alarmSection() -> some View {
//        VStack(alignment: .leading, spacing: 8) {
//            Text("알림")
//                .font(.subheadline).bold()
//            HStack {
//                ForEach(alarms, id: \.self) { minute in
//                    Button(action: {
//                        if selectedAlarms.contains(minute) {
//                            selectedAlarms.remove(minute)
//                        } else {
//                            selectedAlarms.insert(minute)
//                        }
//                    }) {
//                        Text("\(minute)분 전")
//                            .font(.subheadline)
//                            .padding(.vertical, 8)
//                            .padding(.horizontal, 10)
//                            .background(selectedAlarms.contains(minute) ? Color.orange : Color.gray.opacity(0.2))
//                            .foregroundColor(.black)
//                            .cornerRadius(8)
//                    }
//                }
//            }
//        }
//        .frame(maxWidth: .infinity, alignment: .leading)
//    }
//}
//
//extension RoutineRegisterView {
//    @ViewBuilder
//    private func addButton() -> some View {
//        VStack {
//            if case .create = currentMode {
//                Button(action: {
//                    saveRoutine()
//                    goToseedStatus = true
//                }) {
//                    Text("다음")
//                        .frame(maxWidth: .infinity)
//                }
//                .plantPrimaryButton()
//                .disabled(!isFormValid)
//                .opacity(isFormValid ? 1.0 : 0.5)
//                .padding(.horizontal, 20)
//            }
//            else if case .edit = currentMode {
//                HStack(spacing: 16) {
//                    Button(action: deleteRoutine) {
//                        Text("삭제")
//                            .frame(maxWidth: .infinity)
//                    }
//                    .plantSecondaryButton()
//
//                    Button(action: saveRoutine) {
//                        Text("수정 완료")
//                            .frame(maxWidth: .infinity)
//                    }
//                    .plantPrimaryButton()
//                    .disabled(!isFormValid)
//                    .opacity(isFormValid ? 1.0 : 0.5)
//                }
//                .padding(.horizontal, 20)
//            }
//        }
//        .padding(.vertical, 12)
//    }
//
//    @ToolbarContentBuilder
//    private func toolbarContent() -> some ToolbarContent {
//        switch currentMode {
//        case .details(let routine):
//            ToolbarItem(placement: .navigationBarTrailing) {
//                Button("편집") {
//                    currentMode = .edit(routine)
//                }
//            }
//        default:
//            ToolbarItem(placement: .navigationBarTrailing) {
//                EmptyView()
//            }
//        }
//    }
//
//    private func saveRoutine() {
//        switch currentMode {
//        case .create:
//            print("새 루틴 등록 로직 실행")
//        case .edit(let routine):
//            routine.title = routineTitle
//            routine.modifiedAt = Date()
//            do {
//                try context.save()
//                print("루틴 수정 완료: \(routine.title)")
//                dismiss()
//            } catch {
//                print("X 루틴 수정 실패:", error)
//            }
//        default:
//            break
//        }
//    }
//
//    private func deleteRoutine() {
//        switch currentMode {
//        case .create:
//            print("아직 생성되지 않은 루틴은 삭제할 수 없습니다.")
//        case .edit(let routine):
//            store.deleteRoutine(routine)
//            print("루틴 삭제 완료: \(routine.title)")
//            dismiss()
//        case .details:
//            break
//        }
//    }
//}
//
//struct RadioButton: View {
//    let label: String
//    let isSelected: Bool
//    let action: () -> Void
//
//    var body: some View {
//        Button(action: action) {
//            HStack(spacing: 8) {
//                ZStack {
//                    Circle()
//                        .stroke(Color.gray, lineWidth: 2)
//                        .frame(width: 24, height: 24)
//
//                    if isSelected {
//                        Circle()
//                            .fill(Color.blue)
//                            .frame(width: 20, height: 20)
//                        Image(systemName: "checkmark")
//                            .font(.system(size: 12, weight: .bold))
//                            .foregroundColor(.white)
//                    }
//                }
//                Text(label)
//                    .font(.subheadline)
//                    .foregroundColor(.black)
//            }
//        }
//        .buttonStyle(.plain)
//    }
//}
//
