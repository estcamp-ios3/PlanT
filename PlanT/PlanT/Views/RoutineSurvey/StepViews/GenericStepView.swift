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
    func normalizedSlug(from categoryKey: String) -> String? {
        switch categoryKey {
        case "category01": return "knowledge"
        case "category02": return "career"
        case "category03": return "body"
        case "category04": return "mind"
        case "category05": return "social"
        case "category06": return "finance"
        default: return nil
        }
    }
    
    var body: some View {
        // Compute displayOptions outside of the ViewBuilder to avoid returning Void in a ViewBuilder context
        let displayOptions: [Option] = {
            if step.id == "health_type",
               let categoryStep = vm.steps.first(where: { $0.id == "category" }),
               let selectedCatKey = categoryStep.options.first(where: { vm.isSelected($0) })?.id,
               let slug = normalizedSlug(from: selectedCatKey),
               let cat = CategorySlug(rawValue: slug),
               let opts = ActivityTemplatesMock.byCategory[cat] {
                return opts
            } else {
                return step.options
            }
        }()

        return VStack(alignment: .leading, spacing: 20) {
            Spacer()

            Text(step.title).font(.title).bold()
           
            if let m = step.message {
                Text(m).font(.subheadline).foregroundStyle(.secondary)
            } else if step.id == "health_type", let cat = vm.selectedCategoryTitle {
                Text("\(cat)(을)를 선택하셨어요!")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }
            
            Spacer()
            Spacer()

            ScrollView {
                switch step.kind {
                case .single, .multiple, .confirm:
                    VStack(spacing: 10) {
                        ForEach(displayOptions) { opt in
                            OptionRow(option: opt,
                                      selected: vm.isSelected(opt),
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
