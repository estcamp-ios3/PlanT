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
