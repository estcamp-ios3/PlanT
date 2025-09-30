//
//  GenericStepView.swift
//  PlanT
//
//  Created by catharina J on 9/30/25.
//

import SwiftUI

struct GenericStepView: View {
    @ObservedObject var vm: RoutineSurveyViewModel
    let step: SurveyStep
//    let isSelected: (Option) -> Bool
//    let onToggle: (Option) -> Void
    
    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            Spacer()
     
            Text(step.title).font(.title).bold()
            if let m = step.message {
                Text(m).font(.subheadline).foregroundStyle(.secondary)
            }
            Spacer()
            Spacer()

            ScrollView {
                switch step.kind {
                case .single, .multiple, .confirm:
                    VStack(spacing: 10) {
                        ForEach(step.options) { opt in
                            OptionRow(option: opt,
                                      selected: vm.isSelected(opt),
                                      // isRadio: step.maxSelection == 1,
                                      action: { vm.toggle(opt) }
                            )
                        }
                    }
                case .summary:
                    Text(vm.summaryText)
                        .font(.callout)
                        .padding()
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .background(Color(.secondarySystemBackground), in: RoundedRectangle(cornerRadius: 12))
                default: EmptyView()
                }
            }
        }
    }
}

