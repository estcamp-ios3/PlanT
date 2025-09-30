//
//  RoutineCategorySectionView.swift
//  PlanT
//
//  Created by 박성관 on 9/29/25.
//
import SwiftUI

struct RoutineCategorySectionView: View {
    let category: RoutineCategory
    @Binding var selectedRoutineID: UUID?

    var body: some View {
        Spacer(minLength: 10) // 위쪽 빈칸

        Section(header: HStack {
            
            Text("\(category.emoji) \(category.title)")
                .font(.title3)
                .bold()
                .padding(.leading, 4)
            Spacer()
        }) {
            ForEach(category.routines) { routine in
                RoutineCardView(
                    routine: routine,
                    category: category,
                isSelected: Binding(
                    get: {selectedRoutineID == routine.id },
                    set: { newValue in
                        selectedRoutineID = newValue ? routine.id : nil
                    }
                )
            )
                .onTapGesture {
                    if selectedRoutineID == routine.id {
                        selectedRoutineID = nil
                    } else {
                        selectedRoutineID = routine.id
                    }
                }
            }
        }
        .padding(.vertical, 4)
    }
}

#Preview {
    PreviewWrapper()
}

private struct PreviewWrapper: View {
    @State private var previewSelectedID: UUID? = nil
    
    var body: some View {
        RoutineCategorySectionView(
            category: sampleCategories[0],
            selectedRoutineID: $previewSelectedID
        )
    }
}
