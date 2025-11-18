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
    

    @StateObject private var viewModel = RoutineSurveyViewModel() // 카테고리 등 설문 데이터 관리
    @StateObject private var vm: RoutineRegisterViewModel
    

    @State private var dateMode: DateMode = .endDate         // 날짜

    @State private var goToseedStatus = false                // 씨앗

    @Binding var path: NavigationPath                        // 네비게이션 경로 (부모로부터 바인딩)
    @Binding var showAddAlarmSheet: Bool                     // 알람 추가 시트 노출 여부(부모로부터 바인딩)
    @State private var isDeleteMode: Bool = false            // 알람 삭제 모드 활성화 여부
  
    @State private var isEnabled: Bool = true                // 날짜 입력 활성화 여부
    @State private var showDateHeader: Bool = true           // 날짜 입력 헤더 표시 여부
    @State private var hasEnd: Bool = true                   // 종료일 사용 여부
    @State private var showTitleLimitAlert = false
    @State private var showGoalLimitAlert = false
    @State private var alertMessage: String = ""
    @State private var showAlarmLimitAlert: Bool = false
    @State private var alarmAlertMessage: String = ""
    
    
    // 날짜 입력 방식 구분
    enum DateMode { case endDate, allDay }
    
    // init에서 모드, 카테고리, 네비게이션 등 초기값 세팅
    init(mode: RoutineRegisterMode,
         categoryTitle: String? = nil,
         path: Binding<NavigationPath>,
         showAddAlarmSheet: Binding<Bool>,
         context: ModelContext
    ) {
    
        self._path = path
        self._showAddAlarmSheet = showAddAlarmSheet
        
        let routineAlarmStore = RoutineAlarmStore(context: context)
        let store = RoutineStore(context: context, routineAlarmStore: routineAlarmStore)
        let alarmStore = AlarmStore.shared
        
        let viewModel = RoutineRegisterViewModel(
             mode: mode,
             store: store,
             alarmStore: alarmStore,
             routineAlarmStore: routineAlarmStore,
             context: context
         )

         if let categoryTitle = categoryTitle  {
             viewModel.selectedCategory = categoryTitle
         }
        _vm = StateObject(wrappedValue: viewModel)
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
                    
                    AlarmSectionView(viewModel: vm.alarmVM)
                        .frame(height: 150)
                        .sheet(isPresented: $vm.alarmVM.isAddSheetPresented) {
                            AddAlarmSheetContentView(showAddAlarmSheet: $vm.alarmVM.isAddSheetPresented)
                                .environmentObject(alarmStore)
                                .presentationDetents([.fraction(0.3), .medium])
                        }
                    Divider()
                }
                .padding(.horizontal, vertical4)
                
                .disabled(vm.isDetailsMode)   // 상세보기 모드면 전체 입력 비활성화
                
                // 상세/수정 모드에서는 씨앗 성장상태 뷰 하단에 노출
                if let routine = vm.routineFromMode {
                    SeedGrowthStatusView(routine: routine, canCompleste: vm.isDetailsMode)
                        .environmentObject(store)
                }
            }
            .onAppear {
                print(" 현재 모드: \(vm.currentMode), 제목: \(vm.routineTitle)")

                // 데이터 로드
                store.loadRoutines()
                
                // 로드된 루틴 개수 확인
                print(" 현재 저장된 루틴 개수:", store.routines.count)
                
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
                    vm.setupMode(draft: draft)
                    // 화면 진입 시 데이터 세팅
                }
                
            }
            .navigationTitle(vm.modeTitle)    // 네비바 타이틀
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


// MARK: - 씨앗 생성화면으로 전달할 임시 데이터(Draft)
extension RoutineRegisterView {
    private var draft: RoutineDraft {
        RoutineDraft(
            categoryId: vm.selectedCategoryId,
            categoryTitle: vm.selectedCategory,
            routineTypeId: vm.routineTitle,
            routineTypeTitle: vm.routineTitle,
            frequencyPerWeekId: "\(vm.goalDays)x",
            frequencyPerWeekTitle: "주 \(vm.goalDays)회",
            durationId: "\(vm.goalDays)min",
            durationTitle: "\(vm.goalDays)일",
            periodIsNoLimit: !vm.useDate,
            startDate: vm.startDate,
            endDate: vm.endDate,
            reminderOn: !vm.alarmVM.selectedAlarms.isEmpty,
            goal: "\(vm.goalHours)분/일",
            notes: nil,
            iconName: nil,
            isFavorite: false,
            reminderOffsets: vm.alarmVM.selectedAlarms,
            totalDays: Int(vm.goalTask) ?? 0,
            routinePeriodDays: Int(vm.goalTask) ?? 0,
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
                switch vm.currentMode {
                case .details, .edit:
                    // 상세/수정 모드에서는 카테고리는 텍스트로만 표시
                    Text(vm.selectedCategory)
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
                        ForEach(vm.categoryOptions, id: \.id) { option in
                                Button { vm.selectCategory(option) } label: {
                                    Text(option.title)
                                }
                            }
                        
                    } label: {
                        HStack {
                            Text(vm.selectedCategory)
                                .fontWeight(vm.selectedCategory == "선택하세요" ? .regular : .bold)
                                .foregroundColor(vm.selectedCategory == "선택하세요" ? .gray : .black)
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
            if case .details = vm.currentMode {
                // 상세보기에서는 제목도 비활성화 텍스트로 표시
                Text(vm.routineTitle)
                    .padding(.vertical, 12)
                    .padding(.horizontal, 12)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .background(Color("Gray100"))
                    .cornerRadius(30)
            } else {
                // 신규/수정 모드에서는 제목을 텍스트필드로 입력
                TextField("루틴 제목을 입력하세요", text: $vm.routineTitle)
                    .onChange(of: vm.routineTitle) { oldValue, newValue in
                        if newValue.count > 15 {
                            vm.routineTitle = String(newValue.prefix(15))
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
            useDate: $vm.useDate,
            isAllDay: $vm.isAllDay,
            hasEnd: $hasEnd,
            startDate: $vm.startDate,
            endDate: $vm.endDate
        )
        // 기간제한 없음 선택 시 추가 안내 메시지
        if !vm.useDate {
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
                
                if vm.isCreateOrEdit {
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
            if case .create = vm.currentMode {
                VStack(spacing: 12) {
                    HStack {
                        Text("하루 목표 시간")
                            .font(.subheadline)
                            .frame(width: 100, alignment: .leading)
                            .themedTextColor()
                        
                        TextField("30", text: $vm.goalHours)
                            .keyboardType(.numberPad)
                            .frame(width: 50)
                            .multilineTextAlignment(.trailing)
                            .textFieldStyle(.roundedBorder)
                            .themedTextColor()
                            .onChange(of: vm.goalHours) { oldValue, newValue in
                                //  숫자 이외 문자 입력 시 처리
                                if newValue.rangeOfCharacter(from: CharacterSet.decimalDigits.inverted) != nil {
                                    vm.goalHours = oldValue
                                    alertMessage = "숫자만 입력할 수 있습니다."
                                    showGoalLimitAlert = true
                                    return
                                }
                                
                                //  숫자 범위 제한
                                if let value = Int(newValue), value > 480 {
                                    vm.goalHours = "480"
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
                        
                        
                        TextField("5", text: $vm.goalDays)
                            .keyboardType(.numberPad)
                            .frame(width: 50)
                            .multilineTextAlignment(.trailing)
                            .textFieldStyle(.roundedBorder)
                            .themedTextColor()
                            .onChange(of: vm.goalDays) { oldValue, newValue in
                                if newValue.rangeOfCharacter(from: CharacterSet.decimalDigits.inverted) != nil {
                                    vm.goalDays = oldValue
                                    alertMessage = "숫자만 입력할 수 있습니다."
                                    showGoalLimitAlert = true
                                    return
                                }
                                if let value = Int(newValue), value > 7 {
                                    vm.goalDays = "7"
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
            if case .details = vm.currentMode {
                HStack {
                    Text("\(vm.routineFromMode?.goal ?? "-")")
                        .themedTextColor()
                    
                    Text("주 \(vm.routineFromMode?.frequencyPerWeekId.replacingOccurrences(of: "x", with: "") ?? "0")회 \(vm.routineFromMode?.duration ?? "-")")
                        .themedTextColor()
                    
                    Spacer()
                }
                .font(.subheadline)
                .padding(10)
                .background(Color("Gray100"))
                .cornerRadius(30)
            }
            // 수정 모드: 목표 입력필드(수정 가능)
            if case .edit = vm.currentMode {
                HStack {
                    TextField("30", text: $vm.goalHours)
                        .frame(width: 50)
                        .keyboardType(.numberPad)
                        .multilineTextAlignment(.trailing)
                        .textFieldStyle(.roundedBorder)
                        .themedTextColor()
                        .onChange(of: vm.goalHours) { oldValue, newValue in
                            if newValue.rangeOfCharacter(from: CharacterSet.decimalDigits.inverted) != nil {
                                vm.goalHours = oldValue
                                alertMessage = "숫자만 입력할 수 있습니다."
                                showGoalLimitAlert = true
                                return
                            }
                            
                            //  숫자 범위 제한
                            if let value = Int(newValue), value > 480 {
                                vm.goalHours = "480"
                                alertMessage = "하루 목표 시간은 최대 480분까지만 입력할 수 있습니다."
                                showGoalLimitAlert = true
                            }
                        }
                    Text("분/일")
                        .themedTextColor()
                    
                    TextField("5", text: $vm.goalDays)
                        .keyboardType(.numberPad)
                        .frame(width: 40)
                        .multilineTextAlignment(.trailing)
                        .textFieldStyle(.roundedBorder)
                        .themedTextColor()
                        .onChange(of: vm.goalDays) { oldValue, newValue in
                            if newValue.rangeOfCharacter(from: CharacterSet.decimalDigits.inverted) != nil {
                                vm.goalDays = oldValue
                                alertMessage = "숫자만 입력할 수 있습니다."
                                showGoalLimitAlert = true
                                return
                            }
                            if let value = Int(newValue), value > 7 {
                                vm.goalDays = "7"
                                alertMessage = "주 실행 빈도는 최대 7회까지만 입력할 수 있습니다."
                                showGoalLimitAlert = true
                            }
                        }
                    Text("회/주")
                        .themedTextColor()
                    
                    
                    TextField("21", text: $vm.goalTask)
                        .keyboardType(.numberPad)
                        .frame(width: 50)
                        .multilineTextAlignment(.trailing)
                        .textFieldStyle(.roundedBorder)
                        .themedTextColor()
                        .onChange(of: vm.goalTask) { oldValue, newValue in
                            if newValue.rangeOfCharacter(from: CharacterSet.decimalDigits.inverted) != nil {
                                vm.goalTask = oldValue
                                alertMessage = "숫자만 입력할 수 있습니다."
                                showGoalLimitAlert = true
                                return
                            }
                            if let value = Int(newValue), value > 365 {
                                vm.goalTask = "365"
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
            if case .create = vm.currentMode {
                
                Button(action: {
                    Task {
                        
                        goToseedStatus = true
                        
                    }
                }) {
                    Text("다음")
                        .frame(maxWidth: .infinity)
                }
                .plantPrimaryButton()
                .disabled(!vm.isFormValid)
                .opacity(vm.isFormValid ? 1.0 : 0.5)
                .padding(.horizontal, 20)
            }
            // 수정모드: "삭제"/"수정완료" 버튼
            else if case .edit = vm.currentMode {
                HStack(spacing: 16) {
                    Button {
                        if !vm.alarmVM.isDeleteMode {
                            vm.showDeleteAlert = true
                        }
                    } label: {
                        Text("삭제")
                            .frame(maxWidth: .infinity)
                    }
                    .plantSecondaryButton()
                    .disabled(vm.alarmVM.isDeleteMode)
                    .alert("루틴을 삭제합니다.",
                           isPresented: $vm.showDeleteAlert) {
                        Button("삭제", role: .destructive) {
                            vm.deleteRoutine()
                            dismiss()
                        }
                        Button("취소", role: .cancel) {}
                    } message: {
                        
                    }
                    Button(action: {
                        Task { await vm.saveRoutine(isAllDay: vm.isAllDay) }
                    }) {
                        Text("수정 완료")
                            .frame(maxWidth: .infinity)
                    }
                    .plantPrimaryButton()
                    .disabled(vm.alarmVM.isDeleteMode || !vm.isFormValid)
                    .opacity(vm.isFormValid ? 1.0 : 0.5)
                }
                .padding(.horizontal, 20)
            }
        }
        .padding(.vertical, 12)
    }
    
    // 우측상단 툴바(상세보기일 때만 "편집" 버튼 표시)
    @ToolbarContentBuilder
    private func toolbarContent() -> some ToolbarContent {
        switch vm.currentMode {
        case .details(let routine):
            ToolbarItem(placement: .navigationBarTrailing) {
                Button("편집") {
                    vm.currentMode = .edit(routine)
                }
            }
        default:
            ToolbarItem(placement: .navigationBarTrailing) {
                EmptyView()
            }
        }
    }
}




