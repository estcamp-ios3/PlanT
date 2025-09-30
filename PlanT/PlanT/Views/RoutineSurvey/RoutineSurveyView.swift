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
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        VStack() {
            //                    // 헤더
            //                    Text("\(vm.currentIndex + 1) / \(vm.steps.count)")
            //                        .font(.footer).foregroundStyle(.secondary)
            //                        .padding(.horizontal, 16)
            //                        .padding(.top, 12)
            //
            // Body: step kind에 따라 전용/공통 렌더링
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
                        NotificationCenter.default.post(name: .routineCreated, object: nil)
                        // TODO: 실제 생성 로직이 있다면 여기서 처리
                        dismiss()  // 현재 화면 종료 → 첫 탭의 이전 화면으로 복귀
                    } else {
                        vm.next()
                    }
                }
                label: {
                    Text(vm.isLast ? "등록하기" : "다음")
                }
                .plantPrimaryButton()
                .disabled(!vm.canGoNext)
            }
        }
        .padding(16)
        .frame(maxWidth: .infinity)
        .animation(.snappy, value: vm.currentIndex)
    }
    
}



#Preview {
    RoutineSurveyView()
}
