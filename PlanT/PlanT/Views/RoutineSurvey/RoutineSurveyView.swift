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
    @State private var showExitAlert = false
    @EnvironmentObject var routineAlarmStore : RoutineAlarmStore
    @Binding var path: NavigationPath
    @Binding var showAddAlarmSheet: Bool

    @Environment(\.dismiss) private var dismiss

    enum Route: Hashable {
        case seedStatus(draft: RoutineDraft)
    }
    
    var body: some View {
        VStack(spacing: vertical2) {
            ScrollView {
                VStack(alignment: .leading, spacing: vertical2) {
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
                            startDate: $vm.surveyStartDate,
                            endDate: $vm.surveyEndDate
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
                
                .padding(vertical4)
                .frame(maxWidth: .infinity)
                .animation(.snappy, value: vm.currentIndex)
                .ignoresSafeArea(.keyboard, edges: .bottom)
                
            }
                    HStack {
                        if !vm.isFirst {
                            Button { vm.back() }
                            label: {
                                Text("이전")
                            }
                            .plantSecondaryButton()
                        }
                        
                        Button {
                            if vm.isLast {
                                
                                let draft = vm.draft
                                print("""
                                        🟢 [RoutineSurveyView] SeedStatusView로 이동
                                        • draft.startDate: \(draft.startDate ?? Date())
                                        • draft.endDate: \(draft.endDate ?? Date())
                                        • draft.reminderOffsets: \(draft.reminderOffsets)
                                        """)
                                DispatchQueue.main.async {
                                    path.append(Route.seedStatus(draft: vm.draft))
                                }
                                
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
                    
                    
                
                .onChange(of: vm.periodSelection) {
                    updateInlineViews()
                }
                .onChange(of: vm.currentIndex) {
                    updateInlineViews()
                }
                .onChange(of: vm["set_reminder"]) {
                    updateInlineViews()
                }
                .onChange(of: selectedAlarm) { oldvalue, newValue in
                    vm.reminderOffsets = newValue
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
                    .padding(.horizontal, 16)
                    .padding(.bottom, 12)
        }
        
    }
    private func updateInlineViews() {
        showInLineDatePicker = (vm.currentStep.id == "set_period") && (vm.periodSelection?.first == "yes")
        
        showInLineAlarmPicker = (vm.currentStep.id == "set_reminder") && (vm["set_reminder"]?.first == "yes")
    }
       
}

