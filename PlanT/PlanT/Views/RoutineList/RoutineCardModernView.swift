//
//  RoutineCardModernView.swift
//  PlanT
//
//  Created by 박성관 on 10/16/25.
//
import SwiftUI

struct RoutineCardModernView: View {
    @EnvironmentObject var store: RoutineStore

    let routine: Routine
    var progress: Double = 0
    
    private var totalCount: Int {
        store.totalCount(for: routine)
    }
    
    var body: some View {
        HStack {
            ZStack  {
                Circle()
                    .fill(Color("BrandSecondary"))
                    .frame(width: 90, height: 90)
                
                Image(routine.seedImage(for: progress, totalCount: totalCount))
                    .resizable()
                    .scaledToFit()
                    .frame(width: 90, height: 90)
            }
            Spacer(minLength: 12)
            VStack(alignment: .leading, spacing: 6) {
                HStack {
                    Text(routine.title)
                        .font(.headline)
                    Spacer()
                    Text("카테고리: \(routine.categoryTitleMapped)")
                        .font(.caption2)
                }

                HStack {
                    
                    Text("목표: \(routine.goal)")
                        .font(.subheadline)
                    Spacer()
                    Text("주 \(routine.frequencyPerWeekId.replacingOccurrences(of: "x", with: ""))회       \(routine.duration)")
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
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(Color.gray400,lineWidth: 1)
        )
        .onAppear {
            print("""
                 ROUTINE CARD 렌더링
                • Title: \(routine.title)
                • Goal: \(routine.goal)
                • Alarm 설정 여부: \(routine.alarm)
                • Seed 이미지: \(routine.seedImage(for: progress, totalCount: totalCount))
                """)
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
