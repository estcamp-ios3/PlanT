//
//  RoutineDetailView.swift
//  PlanT
//
//  Created by 박성관 on 9/29/25.
//

import SwiftUI
import SwiftData

// 루틴 등록/상세/수정 화면의 모드(상태)를 구분하는 enum
enum RoutineRegisterMode: Equatable {
    case create         // 신규 루틴 등록 모드
    case details(Routine)   // 루틴 상세 보기 모드
    case edit(Routine)      // 루틴 수정 모드
}

// 루틴 등록, 상세, 수정 화면의 메인 뷰
struct RoutineRegisterView: View {
    // 여러 객체나 환경에서 공유하는 데이터 (루틴, 알람 등)를 환경변수로 주입받음
    @EnvironmentObject var store: RoutineStore               // 루틴 데이터 관리
    @Environment(\.modelContext) private var context         // SwiftData의 모델 컨텍스트
    @Environment(\.dismiss) private var dismiss              // 현재 화면 닫기(뒤로가기)
    @EnvironmentObject var alarmStore: AlarmStore            // 알람 프리셋 관리
    @EnvironmentObject var routineAlarmStore: RoutineAlarmStore // 루틴별 알람 관리

    // 화면 상태와 입력값을 저장하는 변수들
    @State private var routineTitle: String = ""             // 루틴 제목
    @StateObject private var viewModel = RoutineSurveyViewModel() // 카테고리 등 설문 데이터 관리
    @State private var selectedCategory = "선택하세요"         // 선택된 카테고리 이름
    @State private var useDate = true                        // 시작/종료일 사용 여부
    @State private var dateMode: DateMode = .endDate         // 날짜 입력 모드
    @State private var startDate = Date()                    // 루틴 시작일
    @State private var endDate = Date()                      // 루틴 종료일
    @State fileprivate var selectedAlarms: Set<Int> = [15]   // 선택된 알림(분 단위)
    @State private var currentMode: RoutineRegisterMode       // 현재 화면의 모드
    @State private var goToseedStatus = false                // 씨앗 상태화면으로 이동 여부
    @State private var goalDays: String = ""                 // 주간 목표(횟수)
    @State private var goalHours: String = ""                // 일간 목표(시간, 분 단위)
    @State private var goalTask: String = ""                 // 전체 실행 기간(일 단위)
    @State private var showAlarms: Bool = true               // 알람 섹션 보이기 여부
    @State private var newAlarmInput: String = ""            // 새 알림 추가 입력값
    @State private var showDeleteAlert: Bool = false         // 삭제 확인 알림창
    @Binding var path: NavigationPath                        // 네비게이션 경로 (부모로부터 바인딩)
    @Binding var showAddAlarmSheet: Bool                     // 알람 추가 시트 노출 여부(부모로부터 바인딩)
    @State private var isDeleteMode: Bool = false            // 알람 삭제 모드 활성화 여부
    @State private var isAllDay: Bool = false {              // 종일 여부 (날짜 모드와 연동됨)
        didSet {
            dateMode = isAllDay ? .allDay : .endDate
        }
    }
    @State private var isEnabled: Bool = true                // 날짜 입력 활성화 여부
    @State private var showDateHeader: Bool = true           // 날짜 입력 헤더 표시 여부
    @State private var hasEnd: Bool = true                   // 종료일 사용 여부

    // 폼이 제출 가능한지 체크 (필수 입력 완료 여부)
    private var isFormValid: Bool {
        selectedCategory != "카테고리 선택 ⌵" &&
        !routineTitle.trimmingCharacters(in: .whitespaces).isEmpty
    }

    // 현재 상세보기 모드인지(입력 비활성화용)
    private var isDetailsMode: Bool {
        if case .details = currentMode { true } else { false }
    }

    // 현재 편집/상세 모드일 때의 루틴 인스턴스 반환
    private var routineFromMode: Routine? {
        if case .details(let routine) = currentMode { return routine }
        if case .edit(let routine) = currentMode { return routine }
        return nil
    }
    // 신규등록, 수정 모드 여부
    private var isCreateOrEdit: Bool {
        if case .create = currentMode { return true }
        if case .edit = currentMode { return true }
        return false
    }

    // 날짜 입력 방식 구분
    enum DateMode { case endDate, allDay }

    // init에서 모드, 카테고리, 네비게이션 등 초기값 세팅
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
                    categorySection()   // 카테고리 선택 및 루틴 제목 입력
                    Divider()
                    dateSection()      // 날짜 및 기간 입력
                    Divider()
                    goalSection()      // 목표시간, 주기 등
                    Divider()
                    alarmSection()     // 알림 선택 및 관리
                    Divider()
                }
                .disabled(isDetailsMode)   // 상세보기 모드면 전체 입력 비활성화

                // 상세/수정 모드에서는 씨앗 성장상태 뷰 하단에 노출
                if let routine = routineFromMode {
                    SeedGrowthStatusView(routine: routine, canCompleste: isDetailsMode)
                        .environmentObject(store)
                }
            }
            .padding(.horizontal)
            .onAppear { setupMode() }      // 화면 진입 시 데이터 세팅
            .navigationTitle(modeTitle)    // 네비바 타이틀
            .toolbar { toolbarContent() }  // 우측 상단 툴바 (편집/비우기)
            .safeAreaInset(edge: .bottom) {
                if !showAddAlarmSheet{     // 알람 추가 시트가 아닐 때만 하단 버튼 표시
                    addButton()
                }
            }
            // "다음" 클릭 시 씨앗상태 화면으로 이동
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

// MARK: - 화면 상단 타이틀 (모드별)
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
    // 모드에 따라 입력값 초기화/적용
    private func setupMode() {
        switch currentMode {
        case .create:
            selectedCategory = "카테고리 선택 ⌵"
            useDate = true
            selectedAlarms = [15]
        case .details(let routine),
                .edit(let routine):
            // 기존 루틴 정보 반영
            routineTitle = routine.title
            if selectedCategory == "선택하세요" {
                selectedCategory = "알 수 없는 카테고리"
            }
            let savedOffsets = routineAlarmStore.fetchOffsets(for: routine.id)
            if !savedOffsets.isEmpty {
                selectedAlarms = Set(savedOffsets)
            }
            // 목표/기간/주기 값 세팅
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

// MARK: - 씨앗 생성화면으로 전달할 임시 데이터(Draft)
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
            isFavorite:  false,
            totalDays: Int(goalTask) ?? 0,
            routinePeriodDays: Int(goalTask) ?? 0
        )
    }
}

// MARK: - 카테고리/제목 입력 뷰
extension RoutineRegisterView {
    @ViewBuilder
    private func categorySection() -> some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                switch currentMode {
                case .details, .edit:
                    // 상세/수정 모드에서는 카테고리는 텍스트로만 표시
                    Text(selectedCategory)
                        .padding(.vertical, 12)
                        .padding(.horizontal, 12)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .background(Color("F2F0CE"))
                        .cornerRadius(30)
                default:
                    // 신규등록 모드에서는 카테고리 드롭다운 메뉴
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
                // 상세보기에서는 제목도 비활성화 텍스트로 표시
                Text(routineTitle)
                    .padding(.vertical, 12)
                    .padding(.horizontal, 12)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .background(Color("Gray400"))
                    .cornerRadius(30)
            } else {
                // 신규/수정 모드에서는 제목을 텍스트필드로 입력
                TextField("루틴 제목을 입력하세요", text: $routineTitle)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .cornerRadius(30)
            }
        }
    }
}

// MARK: - 날짜/기간 입력
extension RoutineRegisterView {
    @ViewBuilder
    private func dateSection() -> some View {
        // 별도의 날짜 입력용 뷰 사용(코드 분리)
        RoutineDateView(
            isEnabled: $isEnabled,
            showDateHeader: $showDateHeader,
            useDate: $useDate,
            isAllDay: $isAllDay,
            hasEnd: $hasEnd,
            startDate: $startDate,
            endDate: $endDate
        )
        // 기간제한 없음 선택 시 추가 안내 메시지
        if !useDate {
            Text("알림기준: 다음루틴 오전 9시")
                .font(.footnote)
                .foregroundColor(.gray400)
                .padding(.top, 4)
        }
    }
}

// MARK: - 목표시간/주기/기간 입력
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
                        // 목표 추가기능(추후 구현가능)
                    } label: {
                        Image(systemName: "plus")
                            .font(.system(size: 18, weight: .bold))
                            .foregroundColor(.black)
                    }
                }
            }
            // 신규 등록 모드: 세부 목표 입력필드(하루 시간, 주 빈도, 전체 실행기간)
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
            // 상세보기 모드: 목표/주기/기간 요약만 읽기전용으로 노출
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
            // 수정 모드: 목표 입력필드(수정 가능)
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

// MARK: - 알림 선택 및 관리
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
                // 삭제모드/일반모드 토글
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
                // 알림 섹션 표시/숨김 토글
                Toggle("", isOn: $showAlarms)
                    .labelsHidden()
                    .toggleStyle(CustomToggleStyle())
            }
            // 알림 섹션 표시 시: 프리셋 버튼 목록/추가, 선택/해제, 삭제
            if showAlarms {
                LazyVGrid(
                    columns: [GridItem(.adaptive(minimum:60), spacing: 4)],
                    spacing: 10
                ) {
                    // 알림 프리셋 버튼들(삭제모드일 때 기본값은 비활성)
                    ForEach(alarmStore.alamPresets.filter {!isDeleteMode || !alarmStore.defaultPresets.contains($0) }, id: \.self) { minute in
                        Button(action: {
                            if isDeleteMode {
                                // 삭제 모드: 기본 프리셋은 삭제 불가, 나머지는 삭제
                                if !alarmStore.defaultPresets.contains(minute) {
                                    Task { await alarmStore.deletePreset(minute) }
                                }
                            } else {
                                // 일반 모드: 선택/해제 토글
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
                    // 알림 프리셋 개수가 10개 미만이면, 추가 버튼 노출
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

// MARK: - 하단 "다음"/"수정"/"삭제" 버튼 및 툴바
extension RoutineRegisterView {
    @ViewBuilder
    private func addButton() -> some View {
        VStack {
            // 신규등록 모드: "다음" 버튼
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
            // 수정모드: "삭제"/"수정완료" 버튼
            else if case .edit = currentMode {
                HStack(spacing: 16) {
                    Button {
                        showDeleteAlert = true
                    } label: {
                        Text("삭제")
                            .frame(maxWidth: .infinity)
                    }
                    .plantSecondaryButton()
                    .alert("루틴을 삭제합니다.",
                           isPresented: $showDeleteAlert) {
                        Button("삭제", role: .destructive) {
                            deleteRoutine()
                        }
                        Button("취소", role: .cancel) {}
                    } message: {

                    }
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
    
    // 우측상단 툴바(상세보기일 때만 "편집" 버튼 표시)
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

    // 루틴 생성/수정 로직
    private func saveRoutine() async {
        switch currentMode {
        case .create:
            // 실제 저장로직은 store 또는 상위에서 구현
            print("새 루틴 등록 로직 실행")
            if let routine = store.routines.last {
                // 알림 프리셋 및 알림 예약 저장
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
            // 기존 루틴 정보 갱신
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

    // 루틴 삭제 처리 (알림/프리셋도 함께 제거)
    private func deleteRoutine() {
        switch currentMode {
        case .create:
            print("아직 생성되지 않은 루틴은 삭제할 수 없습니다.")
        case .edit(let routine):
            NotificationManager.shared.cancelNotifications(for: routine.id)
            routineAlarmStore.deleteOffsets(for: routine.id)
            store.deleteRoutine(routine)
            print(" 루틴 삭제 및 알림 제거 완료: \(routine.title)")
            dismiss()
            dismiss()
        case .details:
            break
        }
    }
}

// MARK: - 기타 보조 함수
extension RoutineRegisterView {
    // "기간제한 없음"일 때, 다음 알람 기준일 계산
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
    // 알림 프리셋 저장 및 예약 재설정
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
            // NotificationManager.shared.debugPendingNotifications()
        }
    }
    // 루틴 완료 처리 및 알림 삭제
    private func completeRoutineAndClearAlarms(_ routine: Routine) {
        NotificationManager.shared.cancelNotifications(for: routine.id)
        routineAlarmStore.deleteOffsets(for: routine.id)
        routine.isCompleted = true
        routine.modifiedAt = Date()
        do {
            try context.save()
            print(" 루틴 완료 + 알림 삭제 완료 (\(routine.title)")
        } catch {
            print(" 루틴 완료 저장 실패:", error)
        }
    }
}

// 전체적으로
// - 각 입력 필드와 모드별 화면/기능(등록, 수정, 삭제, 상세)을 분리해서 관리
// - 알림, 기간, 목표 등 다양한 상태를 실시간으로 입력/저장/수정/삭제
// - SwiftUI의 ViewBuilder, @State, @Binding, @Environment 등 현대적 패턴을 폭넓게 사용해
//   초보자도 "상태와 뷰가 어떻게 연결되는지"를 쉽게 익힐 수 있는 예제입니다.
