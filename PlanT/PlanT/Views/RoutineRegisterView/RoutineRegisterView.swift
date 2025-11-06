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
    @State private var selectedCategoryId: String = ""

    @State private var selectedCategory = "선택하세요"         // 선택된 카테고리 이름
    @State private var useDate = true                        // 시작/종료일 사용 여부
    @State private var dateMode: DateMode = .endDate         // 날짜 입력 모드
    @State private var startDate = Date()                    // 루틴 시작일
    @State private var endDate = Date()                      // 루틴 종료일
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
    @State private var showTitleLimitAlert = false
    @State private var showGoalLimitAlert = false
    @State private var alertMessage: String = ""
    @State private var showAlarmLimitAlert: Bool = false
    @State private var alarmAlertMessage: String = ""
    @StateObject private var alarmVM: AlarmSectionViewModel

    
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
        
        let alarmStore = AlarmStore.shared
        _alarmVM = StateObject(wrappedValue: AlarmSectionViewModel(alarmStore: alarmStore))
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
                    
                    AlarmSectionView(viewModel: alarmVM)
                    .frame(height: 150)
                    .sheet(isPresented: $alarmVM.isAddSheetPresented) {
                        AddAlarmSheetContentView(showAddAlarmSheet: $alarmVM.isAddSheetPresented)
                            .environmentObject(alarmStore)
                            .presentationDetents([.fraction(0.3), .medium])
                    }
                    Divider()
                }
                            .padding(.horizontal, vertical4)

                .disabled(isDetailsMode)   // 상세보기 모드면 전체 입력 비활성화

                // 상세/수정 모드에서는 씨앗 성장상태 뷰 하단에 노출
                if let routine = routineFromMode {
                    SeedGrowthStatusView(routine: routine, canCompleste: isDetailsMode)
                        .environmentObject(store)
                }
            }
            .onAppear {
                print("🟢 [DEBUG] RoutineRegisterView onAppear 진입")

                  // 데이터 로드
                  store.loadRoutines()

                  // 로드된 루틴 개수 확인
                  print("📦 현재 저장된 루틴 개수:", store.routines.count)

                  // 루틴이 실제로 잘 불러와졌는지 상세 출력
                  for routine in store.routines {
                      print("""
                      ─────────────────────────────
                      • Title: \(routine.title)
                      • Category: \(routine.categoryId)
                      • Start: \(routine.startDate ?? Date())
                      • End:   \(routine.endDate ?? Date())
                      • SourceType: \(routine.sourceType)
                      """)
                  }
                DispatchQueue.main.async {
                    setupMode()
                      // 화면 진입 시 데이터 세팅
                }
               
            }
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
            selectedCategory = "카테고리 선택 "
            useDate = true
            alarmVM.selectedAlarms = [15]
            
            // ✅ 추가: 설문에서 전달된 draft의 날짜가 있다면 반영
                if let start = draft.startDate {
                    startDate = start
                }
                if let end = draft.endDate {
                    endDate = end
                }
            
        case .details(let routine),
                .edit(let routine):
            // 기존 루틴 정보 반영
            let savedOffsets = routineAlarmStore.fetchOffsets(for: routine.id)
            alarmVM.selectedAlarms = Set(savedOffsets)
                    alarmVM.selectedAlarms = Set(savedOffsets)
                    startDate = routine.startDate ?? Date()
                    endDate = routine.endDate ?? Date()
                    isAllDay = routine.isAllDay   

            routineTitle = routine.title
            if selectedCategory == "선택하세요" {
                selectedCategory = "알 수 없는 카테고리"
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
            categoryId: selectedCategoryId,
            categoryTitle: selectedCategory,
            routineTypeId: routineTitle,
            routineTypeTitle: routineTitle,
            frequencyPerWeekId: "\(goalDays)x",
            frequencyPerWeekTitle: "주 \(goalDays)회",
            durationId: "\(goalDays)min",
            durationTitle: "\(goalDays)일",
            periodIsNoLimit: !useDate,
            startDate: startDate,
            endDate: endDate,
            reminderOn: !alarmVM.selectedAlarms.isEmpty,
            goal: "\(goalHours)분/일",
            notes: nil,
            iconName: nil,
            isFavorite: false,
            reminderOffsets: alarmVM.selectedAlarms,
            totalDays: Int(goalTask) ?? 0,
            routinePeriodDays: Int(goalTask) ?? 0,
            sourceType: .create
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
                        .themedTextColor()

                default:
                    // 신규등록 모드에서는 카테고리 드롭다운 메뉴
                    Menu {
                        // ✅ 뷰모델의 카테고리 단계에서 직접 옵션 가져오기
                        if let categoryStep = viewModel.steps.first(where: { $0.id == "category" }) {
                            ForEach(categoryStep.options, id: \.id) { option in
                                Button {
                                    selectedCategoryId = option.id           // category01, category02 ...
                                    selectedCategory = option.title          // "지적/성장", "전문 역량" ...
                                } label: {
                                    Text(option.title)
                                }
                            }
                        }
                    } label: {
                        HStack {
                            Text(selectedCategory)
                                .fontWeight(selectedCategory == "선택하세요" ? .regular : .bold)
                                .foregroundColor(selectedCategory == "선택하세요" ? .gray : .black)
                            Image(systemName: "chevron.down")
                                .foregroundColor(.gray)
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
                    .background(Color("Gray100"))
                    .cornerRadius(30)
            } else {
                // 신규/수정 모드에서는 제목을 텍스트필드로 입력
                TextField("루틴 제목을 입력하세요", text: $routineTitle)
                    .onChange(of: routineTitle) { oldValue, newValue in
                        if newValue.count > 15 {
                            routineTitle = String(newValue.prefix(15))
                            showTitleLimitAlert = true
                        }
                    }
                    .padding(.vertical, 12)
                      .padding(.horizontal, 16)
                      .cornerRadius(30)
                      .overlay(
                          RoundedRectangle(cornerRadius: 30)
                              .stroke(Color.gray.opacity(0.4), lineWidth: 1)
                      )
                    .alert("루틴 제목은 15글자 이상은 사용할 수 없습니다.", isPresented: $showTitleLimitAlert) {
                        Button("확인", role: .cancel) { }
                    }
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
                    .themedTextColor()

                if isCreateOrEdit {
                    Spacer()
                    Button {
                        // 목표 추가기능(추후 구현가능)
                    } label: {
//                        Image(systemName: "plus")
//                            .font(.system(size: 18, weight: .bold))
//                            .foregroundColor(.black)
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
                            .themedTextColor()

                        TextField("30", text: $goalHours)
                            .keyboardType(.numberPad)
                            .frame(width: 50)
                            .multilineTextAlignment(.trailing)
                            .textFieldStyle(.roundedBorder)
                            .themedTextColor()
                            .onChange(of: goalHours) { oldValue, newValue in
                                //  숫자 이외 문자 입력 시 처리
                                if newValue.rangeOfCharacter(from: CharacterSet.decimalDigits.inverted) != nil {
                                    goalHours = oldValue
                                    alertMessage = "숫자만 입력할 수 있습니다."
                                    showGoalLimitAlert = true
                                    return
                                }
                                
                                //  숫자 범위 제한
                                if let value = Int(newValue), value > 480 {
                                    goalHours = "480"
                                    alertMessage = "하루 목표 시간은 최대 480분까지만 입력할 수 있습니다."
                                    showGoalLimitAlert = true
                                }
                            }

                        Text("분/일")
                            .font(.subheadline)
                            .themedTextColor()

                        Spacer()
                    }
                    HStack {
                        Text("주 실행 빈도")
                            .font(.subheadline)
                            .frame(width: 100, alignment: .leading)
                            .themedTextColor()
                        

                        TextField("5", text: $goalDays)
                            .keyboardType(.numberPad)
                            .frame(width: 50)
                            .multilineTextAlignment(.trailing)
                            .textFieldStyle(.roundedBorder)
                            .themedTextColor()
                            .onChange(of: goalDays) { oldValue, newValue in
                                if newValue.rangeOfCharacter(from: CharacterSet.decimalDigits.inverted) != nil {
                                    goalDays = oldValue
                                    alertMessage = "숫자만 입력할 수 있습니다."
                                    showGoalLimitAlert = true
                                    return
                                }
                                if let value = Int(newValue), value > 7 {
                                    goalDays = "7"
                                    alertMessage = "주 실행 빈도는 최대 7회까지만 입력할 수 있습니다."
                                    showGoalLimitAlert = true
                                }
                            }
                        Text("회/주")
                            .font(.subheadline)
                            .themedTextColor()

                        Spacer()
                    }
//                    HStack {
//                        Text("총 실행 기간")
//                            .font(.subheadline)
//                            .frame(width: 100, alignment: .leading)
                            .themedTextColor()

//                        TextField("21", text: $goalTask)
//                            .keyboardType(.numberPad)
//                            .frame(width: 50)
//                            .multilineTextAlignment(.trailing)
//                            .textFieldStyle(.roundedBorder)
//                            .themedTextColor()
//                            .onChange(of: goalTask) { oldValue, newValue in
//                                 if newValue.rangeOfCharacter(from: CharacterSet.decimalDigits.inverted) != nil {
//                                     goalTask = oldValue
//                                     alertMessage = "숫자만 입력할 수 있습니다."
//                                     showGoalLimitAlert = true
//                                     return
//                                 }
//                                 if let value = Int(newValue), value > 365 {
//                                     goalTask = "365"
//                                     alertMessage = "총 실행 기간은 최대 365일까지 입력할 수 있습니다."
//                                     showGoalLimitAlert = true
//                                 }
//                             }
//                        Text("일 동안")
//                            .font(.subheadline)
//                            .themedTextColor()

//                        Spacer()
//                    }
                }
                .padding(12)
                .background(Color("BrandSecondary"))
                .cornerRadius(30)
                .alert(alertMessage, isPresented: $showGoalLimitAlert) {
                    Button("확인", role: .cancel) { }
                }
            }
            // 상세보기 모드: 목표/주기/기간 요약만 읽기전용으로 노출
            if case .details = currentMode {
                HStack {
                    Text("\(routineFromMode?.goal ?? "-")")
                        .themedTextColor()

                    Text("주 \(routineFromMode?.frequencyPerWeekId.replacingOccurrences(of: "x", with: "") ?? "0")회 \(routineFromMode?.duration ?? "-")")
                        .themedTextColor()

                    Spacer()
                }
                .font(.subheadline)
                .padding(10)
                .background(Color("Gray100"))
                .cornerRadius(30)
            }
            // 수정 모드: 목표 입력필드(수정 가능)
            if case .edit = currentMode {
                HStack {
                    TextField("30", text: $goalHours)
                        .frame(width: 50)
                        .keyboardType(.numberPad)
                        .multilineTextAlignment(.trailing)
                        .textFieldStyle(.roundedBorder)
                        .themedTextColor()
                        .onChange(of: goalHours) { oldValue, newValue in
                            if newValue.rangeOfCharacter(from: CharacterSet.decimalDigits.inverted) != nil {
                                       goalHours = oldValue
                                       alertMessage = "숫자만 입력할 수 있습니다."
                                       showGoalLimitAlert = true
                                       return
                                   }

                                   //  숫자 범위 제한
                                   if let value = Int(newValue), value > 480 {
                                       goalHours = "480"
                                       alertMessage = "하루 목표 시간은 최대 480분까지만 입력할 수 있습니다."
                                       showGoalLimitAlert = true
                                   }
                        }
                    Text("분/일")
                        .themedTextColor()

                    TextField("5", text: $goalDays)
                        .keyboardType(.numberPad)
                        .frame(width: 40)
                        .multilineTextAlignment(.trailing)
                        .textFieldStyle(.roundedBorder)
                        .themedTextColor()
                        .onChange(of: goalDays) { oldValue, newValue in
                              if newValue.rangeOfCharacter(from: CharacterSet.decimalDigits.inverted) != nil {
                                  goalDays = oldValue
                                  alertMessage = "숫자만 입력할 수 있습니다."
                                  showGoalLimitAlert = true
                                  return
                              }
                              if let value = Int(newValue), value > 7 {
                                  goalDays = "7"
                                  alertMessage = "주 실행 빈도는 최대 7회까지만 입력할 수 있습니다."
                                  showGoalLimitAlert = true
                              }
                          }
                    Text("회/주")
                        .themedTextColor()

                    
                    TextField("21", text: $goalTask)
                        .keyboardType(.numberPad)
                        .frame(width: 50)
                        .multilineTextAlignment(.trailing)
                        .textFieldStyle(.roundedBorder)
                        .themedTextColor()
                        .onChange(of: goalTask) { oldValue, newValue in
                             if newValue.rangeOfCharacter(from: CharacterSet.decimalDigits.inverted) != nil {
                                 goalTask = oldValue
                                 alertMessage = "숫자만 입력할 수 있습니다."
                                 showGoalLimitAlert = true
                                 return
                             }
                             if let value = Int(newValue), value > 365 {
                                 goalTask = "365"
                                 alertMessage = "총 실행 기간은 최대 365일까지 입력할 수 있습니다."
                                 showGoalLimitAlert = true
                             }
                         }
                    Text("일 동안")
                        .themedTextColor()

                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .alert(alertMessage, isPresented: $showGoalLimitAlert) {
                    Button("확인", role: .cancel) { }
                }
            }
        }
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
                       
                            goToseedStatus = true
                        
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
            let calendar = Calendar.current
                let daysDiff = calendar.dateComponents([.day], from: startDate, to: endDate).day ?? 0
                let totalDays = max(daysDiff, 1) // 최소 1일 보장

                print("📅 기간 계산됨: \(totalDays)일")
            print(" [DEBUG] 루틴 생성 시작")
            print("startDate:", startDate)
            print("endDate:", endDate)
            let newRoutine = Routine(
                    title: routineTitle,
                    categoryId: selectedCategoryId,
                    seedName: "seed_Apple01",
                    duration: "\(totalDays)일",
                    goal: "\(goalHours)분/일",
                    alarm: .every24Hours,
                    frequencyPerWeekId: "x\(goalDays)",
                    frequencyPerWeekTitle: "주 \(goalDays)회",
                    note: "",
                    isCompleted: false,
                    createdAt: Date(),
                    modifiedAt: Date(),
                    startDate: startDate,
                    endDate: endDate,
                    sourceType: .create,
                    isAllDay: isAllDay

                    

                )
            print("🟢 [DEBUG] Routine 생성됨:")
             print("""
             • Title: \(newRoutine.title)
             • Start: \(newRoutine.startDate ?? Date())
             • End:   \(newRoutine.endDate ?? Date())
             """)
                context.insert(newRoutine)
                do {
                    try context.save()
                    print("✅ [DEBUG] SwiftData 저장 완료")

                    store.loadRoutines()
                    store.refreshTrigger = UUID()
                    routineAlarmStore.saveOffsets(for: newRoutine.id, offsets: Array(alarmVM.selectedAlarms))
                    NotificationManager.shared.scheduleNotification(
                        for: newRoutine.id,
                        title: newRoutine.title,
                        baseDate: startDate,   //  알림 기준일도 startDate로 설정
                        offsets: Array(alarmVM.selectedAlarms)
                    )
                    print("✅ [DEBUG] 알림 예약 완료 (baseDate: \(startDate))")
                              print("✅ 루틴 등록 완료: \(newRoutine.title)")
                } catch {
                    print("❌ 루틴 저장 실패:", error)
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
                await MainActor.run {
                    currentMode = .details(routine)
                }
                
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
        let offsets = Array(alarmVM.selectedAlarms).sorted()
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


