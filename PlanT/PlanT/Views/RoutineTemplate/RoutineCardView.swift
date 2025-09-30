//
//  RoutinCardView.swift
//  PlanT
//
//  Created by 박성관 on 9/29/25.
//

import SwiftUI

struct RoutineCardView: View {
    let routine: Routine
    let category: RoutineCategory
    @Binding var isSelected: Bool

    var body: some View {
        
        VStack(alignment: .leading, spacing: 4) {
            Text(routine.title)
                .font(.headline)
            
            HStack {
                VStack(alignment: .leading) {
                    
                    Text("카테고리: \(category.title)")
                    
                    if !routine.detail.goal.isEmpty {
                        Text("목표: \(routine.detail.goal)")
                            .font(.subheadline)
                    }
                }
                Spacer()
                    VStack(alignment: .leading) {
                        Text("기간: \(routine.detail.duration)")
                        
                        Text("알림설정: \(routine.detail.alarm.rawValue)")
                    }
                Spacer()
            }
        }
        .padding()
        .background(Color.white)
        .cornerRadius(10)
        .overlay(
            RoundedRectangle(cornerRadius: 10)
                .stroke(isSelected ? Color.orange : Color.gray, lineWidth:1)
        )
        .shadow(radius: 1)
    }
}


#Preview {
    RoutineCardView(
        routine: sampleCategories[0].routines[0],
        category: sampleCategories[0],
        isSelected: .constant(false)
    )
}

