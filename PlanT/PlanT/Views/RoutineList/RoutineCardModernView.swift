//
//  RoutineCardModernView.swift
//  PlanT
//
//  Created by 박성관 on 10/16/25.
//
import SwiftUI

struct RoutineCardModernView: View {
    
    let routine: Routine
    var progress: Double = 0
    
    var body: some View {
        HStack(spacing: 16) {
            ZStack {
                Circle()
                    .fill(Color("BrandSecondary"))
                    .frame(width: 70, height: 70)
                
                Image(routine.seedImage(for: progress))
//                Image("seed_Apple01")

                    .resizable()
                    .scaledToFit()
                    .frame(width: 45, height: 45)
            }
            VStack(alignment: .leading, spacing: 6) {
                
                Text(routine.title)
                    .font(.headline)
                
                Text(routine.categoryTitleMapped)
                    .font(.subheadline)
                HStack {
                    
                    Text("목표: \(routine.goal)")
                        .font(.subheadline)
                    
                    Text("주 \(routine.frequencyPerWeekId.replacingOccurrences(of: "x", with: ""))회 \(routine.duration)")
                        .font(.subheadline)
                }
                HStack {
                    Text("진행률")
                        .font(.caption)
                    
                    Spacer()
                    
                    Text("\(Int(progress))%")
                        .font(.caption)
                }
                
                ProgressView(value: progress / 100)
                    .progressViewStyle(.linear)
                    .tint(Color("BrandPrimary"))
                    .frame(height: 10)
                    .clipShape(Capsule())
                    .padding(.top, 6)
            }
            Spacer()
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color("white"))
                .shadow(color: .black.opacity(0.05), radius: 6, x:0, y: 3)
        )
        .onAppear {
            print("👉 seedName:", routine.seedName ?? "nil")
            print("👉 최종 이미지 호출:", routine.seedImage(for: progress))
        }
    }
}

extension Routine {
    var categoryTitleMapped: String {
        CategoryMockOptions.options.first(where: { $0.id == categoryId })?.title ?? "알 수 없음"
    }

    var categoryThumb: String {
        CategoryMockOptions.options.first(where: { $0.id == categoryId })?.thumb ?? "categories01"
    }
}
