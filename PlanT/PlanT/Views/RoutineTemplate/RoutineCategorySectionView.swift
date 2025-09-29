//
//  RoutineCategorySectionView.swift
//  PlanT
//
//  Created by 박성관 on 9/29/25.
//
import SwiftUI

struct RoutineCategorySectionView: View {
    let category: RoutineCategory

    var body: some View {
        Section(header: HStack {
            Text("\(category.emoji) \(category.title)")
                .font(.title3)
                .bold()
                .padding(.leading, 4)
            Spacer()
        }) {
            ForEach(category.routines) { routine in
                RoutineCardView(routine: routine, category: category)
            }
        }
        .padding(.vertical)
    }
}
#Preview {
    RoutineCategorySectionView(category: sampleCategories[0])
}
