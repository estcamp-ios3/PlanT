//
//  RoutineRegisterViewModel.swift
//  PlanT
//
//  Created by 박성관 on 11/12/25.
//

import Foundation
import SwiftUI
import SwiftData
import Combine

@MainActor
final class RoutineRegisterViewModel: ObservableObject {
    // MARK: - 외부 의존성
    @Published var store: RoutineStore
    @Published var alarmStore: AlarmStore
    @Published var routineAlarmStore: RoutineAlarmStore
    @Published var context: ModelContext
    
    // MARK: - 입력값 상태
    @Published var routineTitle: String = ""
    @Published var selectedCategory: String = "선택하세요"
    @Published var selectedCategoryId: String = ""
    @Published var useDate: Bool = true
    @Published var dateMode: RoutineRegisterView.DateMode = .endDate
    @Published var startDate: Date = Date()
    @Published var endDate: Date = Date()
    @Published var goalDays: String = ""
    @Published var goalHours: String = ""
    @Published var goalTask: String = ""
    @Published var showAlarms: Bool = true
    @Published var showDeleteAlert: Bool = false
    
    // MARK: - 상태 제어
    @Published var currentMode: RoutineRegisterMode
    @Published var goToSeedStatus: Bool = false
    @Published var showGoalLimitAlert: Bool = false
    @Published var alertMessage: String = ""
    
    // MARK: - 알람 VM
    @Published var alarmVM: AlarmSectionViewModel
    
    init(mode: RoutineRegisterMode,
         store: RoutineStore,
         alarmStore: AlarmStore,
         routineAlarmStore: RoutineAlarmStore,
         context: ModelContext
    ) {
        self.currentMode = mode
        self.store = store
        self.alarmStore = alarmStore
        self.routineAlarmStore = routineAlarmStore
        self.context = context
        self.alarmVM = AlarmSectionViewModel(alarmStore: alarmStore)
    }
}


extension RoutineRegisterViewModel {
    
    // MARK: - 화면 상단 타이틀 (모드별)
        var modeTitle: String {
            switch currentMode {
            case .create:
                return "루틴 직접 등록하기"
            case .details:
                return "루틴 자세히 보기"
            case .edit:
                return "루틴 수정하기"
            }
            
                }
        
    
        // 폼이 제출 가능한지 체크 (필수 입력 완료 여부)
        var isFormValid: Bool {
            selectedCategory != "카테고리 선택 ⌵" &&
            !routineTitle.trimmingCharacters(in: .whitespaces).isEmpty
        }
    
    // 현재 상세보기 모드인지(입력 비활성화용)
var isDetailsMode: Bool {
        if case .details = currentMode { true } else { false }
    }
    // 현재 편집/상세 모드일 때의 루틴 인스턴스 반환
    
    var routineFromMode: Routine? {
        if case .details(let routine) = currentMode { return routine }
        if case .edit(let routine) = currentMode { return routine }
        return nil
    }
    
    // 신규등록, 수정 모드 여부
    var isCreateOrEdit: Bool {
        if case .create = currentMode { return true }
        if case .edit = currentMode { return true }
        return false
    }
    
    
    
    // 모드에 따라 입력값 초기화/적용
    func setupMode(draft: RoutineDraft? = nil) {
        switch currentMode {
        case .create:
            selectedCategory = "카테고리 선택 "
            useDate = true
            alarmVM.selectedAlarms = [15]
            
//            if let start = draft.startDate {
//                startDate = start
//            }
//            if let end = draft.endDate {
//                endDate = end
//            }
            
            if let draft {
                          startDate = draft.startDate ?? Date()
                          endDate = draft.endDate ?? Date()
                      }
            
        case .details(let routine),
                .edit(let routine):
            selectedCategoryId = routine.categoryId
                    selectedCategory = routine.categoryTitleMapped
                    routineTitle = routine.title
            // 기존 루틴 정보 반영
            let savedOffsets = routineAlarmStore.fetchOffsets(for: routine.id)
            alarmVM.selectedAlarms = Set(savedOffsets)
            startDate = routine.startDate ?? Date()
            endDate = routine.endDate ?? Date()
            
            // 목표/기간/주기 값 세팅
            if routine.goal.contains("분") {
                goalHours = routine.goal.replacingOccurrences(of: "분/일", with: "")
            }
            goalDays = routine.frequencyPerWeekId.replacingOccurrences(of: "x", with: "")
            goalTask = routine.duration.replacingOccurrences(of: "일", with: "")
            
            startDate = routine.startDate ?? Date()
            endDate = routine.endDate ?? Date()
            useDate = !(routine.startDate == nil && routine.endDate == nil)
        }
    }
    
    // 루틴 생성/수정 로직
    
    func saveRoutine(isAllDay: Bool) async {
        switch currentMode {
        case .create:
            let calendar = Calendar.current
            let daysDiff = calendar.dateComponents([.day], from: startDate, to: endDate).day ?? 0
            let totalDays = max(daysDiff, 1) // 최소 1일 보장
            
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
           
            context.insert(newRoutine)
            do {
                try context.save()
                store.loadRoutines()
                store.refreshTrigger = UUID()
                routineAlarmStore.saveOffsets(for: newRoutine.id, offsets: Array(alarmVM.selectedAlarms))
                NotificationManager.shared.scheduleNotification(
                    for: newRoutine.id,
                    title: newRoutine.title,
                    baseDate: startDate,   //  알림 기준일도 startDate로 설정
                    offsets: Array(alarmVM.selectedAlarms)
                )
 
            } catch {
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
                await MainActor.run {
                    currentMode = .details(routine)
                }
                
            } catch {
            }
        default:
            break
        }
    }
    // 루틴 삭제 처리 (알림/프리셋도 함께 제거)
    func deleteRoutine() {
        switch currentMode {
        case .create:
            print("아직 생성되지 않은 루틴은 삭제할 수 없습니다.")
        case .edit(let routine):
            NotificationManager.shared.cancelNotifications(for: routine.id)
            routineAlarmStore.deleteOffsets(for: routine.id)
            store.deleteRoutine(routine)
       
        case .details:
            break
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
            let base = routine.startDate ??
            Date()
//            nextBaseDate()
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
    
    // MARK: - 기타 보조 함수
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
    
}
