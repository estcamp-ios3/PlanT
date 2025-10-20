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
    @StateObject var viewModel = RoutineSurveyViewModel()
    @State private var showInLineDatePicker: Bool = false
    @State private var isAllday = false
    @State private var hasEnd = true
    @State private var startDate = Date()
    @State private var endDate = Date()
    
    @Binding var path: NavigationPath
    @Binding var showAddAlarmSheet: Bool

    @StateObject private var vm = RoutineSurveyViewModel()
    @Environment(\.dismiss) private var dismiss

    enum Route: Hashable {
        case seedStatus(draft: RoutineDraft)
    }
    
    var body: some View {
        VStack() {
            Group {
                switch vm.currentStep.kind {
                case .categoryGrid:
                    CategoryGridStepView(
                        vm: vm,
                        step: vm.currentStep,
                    )
                default:
                    GenericStepView(
                        vm: vm,
                        step: vm.currentStep,
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
                    if vm.isLast {
                        path.append(Route.seedStatus(draft: vm.draft))
                    } else {
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
            if vm.periodSelection?.first == "yes" {
                showInLineDatePicker = true
            } else {
                showInLineDatePicker = false
            }
        }
        .navigationDestination(for: Route.self) { route in
            switch route {
            case .seedStatus(let draft):
                SeedStatusView(state: .notPlanted, draft: draft, path: $path, showAddAlarmSheet: $showAddAlarmSheet)
            }
        }
    }
    
}

