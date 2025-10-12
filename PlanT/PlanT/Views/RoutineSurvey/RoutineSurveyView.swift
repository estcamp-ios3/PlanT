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
    @Binding var path: NavigationPath
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
            .animation(.snappy, value: vm.currentIndex)
            
            // 풋터
            HStack{
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
                }
                label: {
                    Text(vm.isLast ? "생성" : "다음")
                }
                .plantPrimaryButton()
                .disabled(!vm.canGoNext)
            }
        }
        .padding(16)
        .frame(maxWidth: .infinity)
        .animation(.snappy, value: vm.currentIndex)
        .navigationDestination(for: Route.self) { route in
            switch route {
            case .seedStatus(let draft):
                SeedStatusView(state: .notPlanted, draft: draft, path: $path)
            }
        }
    }
    
}



#Preview {
    // Note: The preview must provide a NavigationPath binding
    NavigationStack {
        RoutineSurveyView(path: .constant(NavigationPath()))
    }
}

