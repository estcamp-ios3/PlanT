//
//  CategoryGridStepView.swift
//  PlanT
//
//  Created by catharina J on 9/30/25.
//

import SwiftUI


struct CategoryGridStepView: View {
    @ObservedObject var vm: RoutineSurveyViewModel
    let step: SurveyStep
//    let isSelected: (Option) -> Bool
//    let onToggle: (Option) -> Void
    
    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            Text(step.title)
                .font(.title).bold()
            if let m = step.message {
                Text(m).font(.subheadline).foregroundStyle(.secondary)
            }
            ScrollView{
                ForEach(step.options, id: \.id) { opt in
                    OptionGridItem(option: opt,
                                   selected: vm.isSelected(opt),
                                   action: { vm.toggle(opt) }
                    )
                }
                .frame(maxHeight: .infinity, alignment: .top)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}
