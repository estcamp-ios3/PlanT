//
//  RoutineResearchView.swift
//  PlanT
//
//  Created by catharina J on 9/30/25.
//

import SwiftUI

extension Notification.Name {
    static let routineCreated = Notification.Name("RoutineCreatedNotification")
}

struct RoutineSurveyView: View {
    @StateObject private var vm = RoutineSurveyViewModel()
    @State private var refreshKey = UUID()
    @State private var showInLineDatePicker: Bool = false
    @State private var showInLineAlarmPicker: Bool = false
    @State private var isAllday = false
    @State private var hasEnd = true
    @State private var startDate = Date()
    @State private var endDate = Date()
    @State private var selectedAlarm: Set<Int> = [15]
    
    @EnvironmentObject var routineAlarmStore : RoutineAlarmStore
    @Binding var path: NavigationPath
    @Binding var showAddAlarmSheet: Bool

    @Environment(\.dismiss) private var dismiss

    enum Route: Hashable {
        case seedStatus(draft: RoutineDraft)
    }
    
    var body: some View {
        VStack {
            Group {
                switch vm.currentStep.kind {
                case .categoryGrid:
                    CategoryGridStepView(
                        vm: vm,
                        step: vm.currentStep
                    )
                default:
                    GenericStepView(
                        vm: vm,
                        step: vm.currentStep
                    )
                }
            }
            if showInLineDatePicker {
                RoutineDateView(
                    isEnabled: .constant(true),
                    showDateHeader: .constant(false),
                    useDate: .constant(true),
                    isAllDay: $isAllday,
                    hasEnd: $hasEnd,
                    startDate: $startDate,
                    endDate: $endDate
                )
            }
            if showInLineAlarmPicker {
                AlarmPresetPicker(
                    selectedAlarms: $selectedAlarm,
                    showAddAlarmSheet: $showAddAlarmSheet
                )
                    .environmentObject(routineAlarmStore)
            }
        }
        .padding(16)
        .frame(maxWidth: .infinity)
        .animation(.snappy, value: vm.currentIndex)
        .ignoresSafeArea(.keyboard, edges: .bottom)
        .safeAreaInset(edge: .bottom, spacing: 0) {
            HStack {
                if !vm.isFirst {
                    Button { vm.back() }
                    label: {
                        Text("이전")
                    }
                    .plantSecondaryButton()
                }
                
                Button {
                    print(" 선택된 알람: \(selectedAlarm)")
                    print(" 선택된 날짜: 시작 \(startDate), 종료 \(endDate)")
                    if vm.isLast {
                        path.append(Route.seedStatus(draft: vm.draft))
                    } else {
                        if vm.currentStep.id == "set_period" {
                            showInLineDatePicker = false
                        }
                        vm.next()
                    }
                } label: {
                    Text(vm.isLast ? "생성" : "다음")
                }
                .plantPrimaryButton()
                .disabled(!vm.canGoNext)
            }
            .padding(.horizontal, 16)
            .padding(.bottom, 12)
        }
        .onChange(of: vm.periodSelection) {
            updateInlineViews()
            print(" 저장됨 - 알람 오프셋: \(vm.reminderOffsets)")
        }
        .onChange(of: vm.currentIndex) {
            updateInlineViews()
            print(" 저장됨 - 시작일: \(vm.surveyStartDate)")
        }
        .onChange(of: vm["set_reminder"]) {
            updateInlineViews()
            print("저장됨 - 종료일: \(vm.surveyEndDate)")
            
        }
        .onChange(of: startDate) { _, newValue in
                 vm.surveyStartDate = newValue
             }
             .onChange(of: endDate) { _, newValue in
                 vm.surveyEndDate = newValue
             }
        .navigationDestination(for: Route.self) { route in
            switch route {
            case .seedStatus(let draft):
                SeedStatusView(state: .notPlanted, draft: draft, path: $path, showAddAlarmSheet: $showAddAlarmSheet)
            }
        }
        .id(refreshKey)
        .onAppear {
            refreshKey = UUID()
            if !vm.reminderOffsets.isEmpty {
                selectedAlarm = vm.reminderOffsets
            }
            startDate = vm.surveyStartDate
            endDate = vm.surveyEndDate
            
        }
    }
    private func updateInlineViews() {
        showInLineDatePicker = (vm.currentStep.id == "set_period") && (vm.periodSelection?.first == "yes")
        
        showInLineAlarmPicker = (vm.currentStep.id == "set_reminder") && (vm["set_reminder"]?.first == "yes")
    }
       
}
