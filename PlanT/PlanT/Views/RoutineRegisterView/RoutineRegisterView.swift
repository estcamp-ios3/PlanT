//
//  RoutineDetailView.swift
//  PlanT
//
//  Created by 박성관 on 9/29/25.
//

import SwiftUI
import SwiftData

enum RoutineRegisterMode: Equatable {
    case create // 신규등록
    case details(Routine) // 자세히보기
    case edit(Routine) // 수정모드
}

struct RoutineRegisterView: View {
    @EnvironmentObject var store: RoutineStore
    @Environment(\.modelContext) private var context
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject var alarmStore: AlarmStore
    @EnvironmentObject var routineAlarmStore: RoutineAlarmStore
    
    @State private var routineTitle: String = ""
    @StateObject private var viewModel = RoutineSurveyViewModel()
    @State private var selectedCategory = "선택하세요"
    @State private var useDate = true
    @State private var dateMode: DateMode = .endDate
    @State private var startDate = Date()
    @State private var endDate = Date()
    @State fileprivate var selectedAlarms: Set<Int> = [15]
    @State private var currentMode: RoutineRegisterMode
    @State private var goToseedStatus = false
    @State private var goalDays: String = ""
    @State private var goalHours: String = ""
    @State private var goalTask: String = ""
    @State private var showAlarms: Bool = true
    @State private var newAlarmInput: String = ""
    @Binding var path: NavigationPath
    @Binding var showAddAlarmSheet: Bool
    @State private var isDeleteMode: Bool = false
    @State private var isAllDay: Bool = false {
        didSet {
            dateMode = isAllDay ? . allDay : .endDate
        }
    }
    @State private var isEnabled: Bool = true
    @State private var showDateHeader: Bool = true
    @State private var hasEnd: Bool = true
    
    private var isFormValid: Bool {
        selectedCategory != "카테고리 선택 ⌵" &&
        !routineTitle.trimmingCharacters(in: .whitespaces).isEmpty
    }
    
    private var isDetailsMode: Bool {
        if case .details = currentMode { true } else { false }
    }
    
    private var routineFromMode: Routine? {
        if case .details(let routine) = currentMode { return routine }
        if case .edit(let routine) = currentMode { return routine }
        return nil
    }
    private var isCreateOrEdit: Bool {
        if case .create = currentMode { return true }
        if case .edit = currentMode { return true }
        return false
    }
    
    
    enum DateMode { case endDate, allDay }
    
    init(mode: RoutineRegisterMode,
         categoryTitle: String? = nil,
         path: Binding<NavigationPath>,
         showAddAlarmSheet: Binding<Bool>
    ) {
        _currentMode = State(initialValue: mode)
        
        if let categoryTitle = categoryTitle {
            _selectedCategory = State(initialValue: categoryTitle)
        }
        self._path = path
        self._showAddAlarmSheet = showAddAlarmSheet
    }
    
    var body: some View {
        ZStack{
            ScrollView {
                VStack(spacing: 16) {
                    categorySection()
                    Divider()
                    dateSection()
                    Divider()
                    goalSection()
                    Divider()
                    alarmSection()
                    Divider()
                }
                .disabled(isDetailsMode)
                
                if let routine = routineFromMode {
                    SeedGrowthStatusView(routine: routine, canCompleste: isDetailsMode)
                        .environmentObject(store)
                }
            }
            .padding(.horizontal)
            .onAppear { setupMode() }
            .navigationTitle(modeTitle)
            .toolbar { toolbarContent() }
            .safeAreaInset(edge: .bottom) {
                if !showAddAlarmSheet{
                    addButton()
                }
            }
            .navigationDestination(isPresented: $goToseedStatus) {
                SeedStatusView(
                    state: .notPlanted,
                    draft: draft,
                    path: $path, showAddAlarmSheet: $showAddAlarmSheet
                )
            }
        }
    }
}


extension RoutineRegisterView {
    private var modeTitle: String {
        switch currentMode {
        case .create:
            return "루틴 직접 등록하기"
        case .details:
            return "루틴 자세히 보기"
        case .edit:
            return "루틴 수정하기"
        }
    }
    private func setupMode() {
        switch currentMode {
        case .create:
            selectedCategory = "카테고리 선택 ⌵"
            useDate = true
            selectedAlarms = [15]
            
        case .details(let routine),
                .edit(let routine):
            
            routineTitle = routine.title
            if selectedCategory == "선택하세요" {
                selectedCategory = "알 수 없는 카테고리"
            }
            let savedOffsets = routineAlarmStore.fetchOffsets(for: routine.id)
            if !savedOffsets.isEmpty {
                selectedAlarms = Set(savedOffsets)
            }
            
            if routine.goal.contains("분") {
                goalHours = routine.goal.replacingOccurrences(of: "분/일", with: "")
            }
            
            goalDays = routine.frequencyPerWeekId.replacingOccurrences(of: "x", with: "")
            
            goalTask = routine.duration.replacingOccurrences(of: "일", with: "")
            
            startDate = routine.startDate ?? Date()
            endDate = routine.endDate ?? Date()
        }
    }
}

extension RoutineRegisterView {
    private var draft: RoutineDraft {
        RoutineDraft(
            categoryId: selectedCategory,
            categoryTitle: selectedCategory,
            routineTypeId: routineTitle,
            routineTypeTitle: routineTitle,
            frequencyPerWeekId: "\(goalDays)x",
            frequencyPerWeekTitle: "주 \(goalDays)회",
            durationId: "\(goalDays)min",
            durationTitle: "\(goalDays)일", // 기간
            periodIsNoLimit: !useDate,
            reminderOn: !selectedAlarms.isEmpty,
            goal: "\(goalHours)분 /일",
            isFavorite:  false
        )
    }
}

extension RoutineRegisterView {
    @ViewBuilder
    private func categorySection() -> some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                switch currentMode {
                case .details, .edit:
                    Text(selectedCategory)
                        .padding(.vertical, 12)
                        .padding(.horizontal, 12)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .background(Color("F2F0CE"))
                        .cornerRadius(30)
                default:
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
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(.vertical, 12)
                        .padding(.horizontal, 12)
                        .background(Color("F2F0CE"))
                        .cornerRadius(30)
                    }
                }
            }
            if case .details = currentMode {
                Text(routineTitle)
                    .padding(.vertical, 12)
                    .padding(.horizontal, 12)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .background(Color("Gray400"))
                    .cornerRadius(30)
            } else {
                TextField("루틴 제목을 입력하세요", text: $routineTitle)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .cornerRadius(30)
            }
        }
    }
}

extension RoutineRegisterView {
    @ViewBuilder
    private func dateSection() -> some View {
        RoutineDateView(
            isEnabled: $isEnabled,
            showDateHeader: $showDateHeader,
            useDate: $useDate,
            isAllDay: $isAllDay,
            hasEnd: $hasEnd,
            startDate: $startDate,
            endDate: $endDate
        )
        if !useDate {
            Text("알림기준: 다음루틴 오전 9시")
                .font(.footnote)
                .foregroundColor(.gray400)
                .padding(.top, 4)
        }
    }
}

extension RoutineRegisterView {
    @ViewBuilder
    private func goalSection() -> some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text("목표")
                    .font(.headline).bold()
                if isCreateOrEdit {
                    Spacer()
                    Button {
                        
                    } label: {
                        Image(systemName: "plus")
                            .font(.system(size: 18, weight: .bold))
                            .foregroundColor(.black)
                    }
                }
            }
            if case .create = currentMode {
                            VStack(spacing: 12) {
                                HStack {
                                    Text("하루 목표 시간")
                                        .font(.subheadline)
                                        .frame(width: 100, alignment: .leading)
                                    TextField("30", text: $goalHours)
                                        .keyboardType(.numberPad)
                                        .frame(width: 50)
                                        .multilineTextAlignment(.trailing)
                                        .textFieldStyle(.roundedBorder)
                                    Text("분/일")
                                        .font(.subheadline)
                                    Spacer()
                                }
                                HStack {
                                    Text("주 실행 빈도")
                                        .font(.subheadline)
                                        .frame(width: 100, alignment: .leading)
                                    TextField("5", text: $goalDays)
                                        .keyboardType(.numberPad)
                                        .frame(width: 50)
                                        .multilineTextAlignment(.trailing)
                                        .textFieldStyle(.roundedBorder)
                                    Text("회/주")
                                        .font(.subheadline)
                                    Spacer()
                                }
                                HStack {
                                    Text("총 실행 기간")
                                        .font(.subheadline)
                                        .frame(width: 100, alignment: .leading)
                                    TextField("21", text: $goalTask)
                                        .keyboardType(.numberPad)
                                        .frame(width: 50)
                                        .multilineTextAlignment(.trailing)
                                        .textFieldStyle(.roundedBorder)
                                    Text("일 동안")
                                        .font(.subheadline)
                                    Spacer()
                                }
                            }
                            .padding(12)
                            .background(Color("BrandSecondary"))
                            .cornerRadius(30)
                        }
            if case .details = currentMode {
                HStack {
                    Text("\(routineFromMode?.goal ?? "-")")
                    Text("주 \(routineFromMode?.frequencyPerWeekId.replacingOccurrences(of: "x", with: "") ?? "0")회 \(routineFromMode?.duration ?? "-")")
                    Spacer()
                }
                .font(.subheadline)
                .padding(10)
                .background(Color("Gray400"))
                .cornerRadius(30)
            }
            if case .edit = currentMode {
                HStack {
                    TextField("30", text: $goalHours)
                        .frame(width: 40)
                        .keyboardType(.numberPad)
                        .multilineTextAlignment(.trailing)
                        .textFieldStyle(.roundedBorder)
                    Text("분/일")
                    TextField("5", text: $goalDays)
                        .keyboardType(.numberPad)
                        .frame(width: 40)
                        .multilineTextAlignment(.trailing)
                        .textFieldStyle(.roundedBorder)
                    Text("회/주")
                    
                    TextField("21", text: $goalTask)
                        .keyboardType(.numberPad)
                        .frame(width: 40)
                        .multilineTextAlignment(.trailing)
                        .textFieldStyle(.roundedBorder)
                    Text("일 동안")
                }
                .frame(maxWidth: .infinity, alignment: .leading)
            }
        }
    }
}


extension RoutineRegisterView {
    @ViewBuilder
    private func alarmSection() -> some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text("알림")
                    .font(.subheadline).bold()
                Spacer()
                Text("맞춤 알림 생성,삭제")
                    .font(.footnote).bold()
                    .foregroundColor(.gray.opacity(0.6))

                if isDeleteMode {
                    Button("완료") { isDeleteMode = false }
                        .font(.subheadline).bold()
                        .foregroundColor(.red)
                } else {
                    Button(role: .destructive) {
                        isDeleteMode = true
                    } label: {
                        Image(systemName: "pencil.tip.crop.circle.badge.minus")
                            .font(.system(size: 20, weight: .bold))
                            .padding(6)
                    }
                }
                
                Toggle("", isOn: $showAlarms)
                    .labelsHidden()
                    .toggleStyle(CustomToggleStyle())
            }
            if showAlarms {
                LazyVGrid(
                    columns: [GridItem(.adaptive(minimum:60), spacing: 4)],
                    spacing: 10
                ) {
                    ForEach(alarmStore.alamPresets.filter {!isDeleteMode || !alarmStore.defaultPresets.contains($0) }, id: \.self) { minute in
                           Button(action: {
                               if isDeleteMode {
                                   if !alarmStore.defaultPresets.contains(minute) {
                                       Task { await alarmStore.deletePreset(minute) }
                                   }
                            } else {
                                if selectedAlarms.contains(minute) {
                                    selectedAlarms.remove(minute)
                                } else {
                                    selectedAlarms.insert(minute)
                                }
                            }
                        }) {
                            Text("\(minute)분 전")
                                .font(.subheadline)
                                .padding(.vertical, 8)
                                .padding(.horizontal, 10)
                                .frame(maxWidth: .infinity)
                                .background(
                                    isDeleteMode
                                    ? Color("BrandSecondary")
                                    : selectedAlarms.contains(minute) ? Color("BrandAccent") : Color("BrandSecondary"))
                                .foregroundColor(.black)
                                .cornerRadius(30)
                        }
                    }
                    if alarmStore.alamPresets.count < 10 {
                        Button(action: {
                            withAnimation {
                                showAddAlarmSheet = true
                            }
                        }) {
                            Image(systemName: "plus")
                                .font(.subheadline)
                                .padding(8)
                                .frame(maxWidth: .infinity, minHeight: 36)
                                .background(Color.gray.opacity(0.2))
                                .clipShape(Circle())
                        }
                    }
                }
                .transition(.opacity.combined(with: .move(edge: .top)))
                .animation(.spring(), value: showAlarms)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}

extension RoutineRegisterView {
    @ViewBuilder
    private func addButton() -> some View {
        VStack {
            if case .create = currentMode {
                Button(action: {
                    Task {
                        await saveRoutine()
                        await MainActor.run {
                            goToseedStatus = true
                        }
                    }
                }) {
                    Text("다음")
                        .frame(maxWidth: .infinity)
                }
                .plantPrimaryButton()
                .disabled(!isFormValid)
                .opacity(isFormValid ? 1.0 : 0.5)
                .padding(.horizontal, 20)
            }
            else if case .edit = currentMode {
                HStack(spacing: 16) {
                    Button(action: deleteRoutine) {
                        Text("삭제")
                            .frame(maxWidth: .infinity)
                    }
                    .plantSecondaryButton()
                    
                    Button(action: {
                        Task { await saveRoutine() }
                    }) {
                        Text("수정 완료")
                            .frame(maxWidth: .infinity)
                    }
                    .plantPrimaryButton()
                    .disabled(!isFormValid)
                    .opacity(isFormValid ? 1.0 : 0.5)
                }
                .padding(.horizontal, 20)
            }
        }
        .padding(.vertical, 12)
    }
    
    @ToolbarContentBuilder
    private func toolbarContent() -> some ToolbarContent {
        switch currentMode {
        case .details(let routine):
            ToolbarItem(placement: .navigationBarTrailing) {
                Button("편집") {
                    currentMode = .edit(routine)
                }
            }
        default:
            ToolbarItem(placement: .navigationBarTrailing) {
                EmptyView()
            }
        }
    }
    
    private func saveRoutine() async {
        switch currentMode {
        case .create:
            print("새 루틴 등록 로직 실행")
            if let routine = store.routines.last {
                
                routineAlarmStore.saveOffsets(
                    for: routine.id,
                    offsets: Array(selectedAlarms)
                )
                
                NotificationManager.shared.scheduleNotification(
                    for: routine.id,
                    title: routine.title,
                    baseDate: startDate,
                    offsets: Array(selectedAlarms)
                )
            }
            
        case .edit(let routine):
            routine.title = routineTitle
            routine.goal = "\(goalHours)분/일"
            routine.frequencyPerWeekId = "\(goalDays)x"
            routine.duration = "\(goalTask)일"
            routine.startDate = startDate
            routine.endDate = endDate
            routine.modifiedAt = Date()
    
            do {
                try context.save()
                
                await savePresetAndReschedule(for: routine)
                
                store.loadRoutines()
                store.refreshTrigger = UUID()
                print("루틴 수정 완료: \(routine.title)")
                dismiss()
            } catch {
                print("X 루틴 수정 실패:", error)
            }
        default:
            break
        }
    }
    
    private func deleteRoutine() {
        switch currentMode {
        case .create:
            print("아직 생성되지 않은 루틴은 삭제할 수 없습니다.")
        case .edit(let routine):
            store.deleteRoutine(routine)
            print("루틴 삭제 완료: \(routine.title)")
            dismiss()
        case .details:
            break
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

extension RoutineRegisterView {
    private func nextBaseDate() -> Date {
        if useDate {
            return startDate
        } else {
            let cal = Calendar.current
            let today9 = cal.date(bySettingHour: 9, minute: 0, second: 0, of: Date())!
            if today9 > Date() {
                return today9
            } else {
                let tomorrow = cal.date(byAdding: .day, value: 1, to: Date())!
                return cal.date(bySettingHour: 9, minute: 0, second: 0, of: tomorrow)!
            }
        }
    }
    private func savePresetAndReschedule(for routine:Routine) async {
            let offsets = Array(selectedAlarms).sorted()
            routineAlarmStore.saveOffsets(for: routine.id, offsets: offsets)
            print(" 알림 프리셋 저장: \(offsets)")
            
            Task {
                await MainActor.run {
                    NotificationManager.shared.cancelNotifications(for: routine.id)
                    
                }
                
                
                let base = routine.startDate ?? nextBaseDate()
                NotificationManager.shared.scheduleNotification(
                    for: routine.id,
                    title: routine.title,
                    baseDate: base,
                    offsets: offsets
                )
                print(" 알림 재예약 완료 (base: \(NotificationManager.localString(base)), offsets: \(offsets))")
            }
            await MainActor.run {
                NotificationManager.shared.debugPendingNotifications()
            }
    }
}

