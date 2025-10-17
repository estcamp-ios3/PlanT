//
//  SeedGrowthStatusView.swift
//  PlanT
//
//  Created by 박성관 on 10/17/25.
//

import SwiftUI

struct SeedGrowthStatusView: View {
    @EnvironmentObject var store: RoutineStore
    let routine: Routine
    
    private var totalCount: Int {
        store.totalCount(for: routine)
    }
    private var completedCount: Int {
        store.completedCount(for: routine)
    }
    private var progress: Double {
        store.progress(for: routine)
    }
    
    private var imagePrefix: String {
        routine.seedName ?? ""
    }
    private var currentStage: Int {
        let stage = Int(progress / 100 * 4) + 1
        return max(1, min(5, stage))
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Text("작물 상태")
                    .font(.headline)
                Spacer()
                Text("\(displayName) \(currentStage)단계")
                    .font(.subheadline)
            }
            Image(routine.seedImage(for: progress))
                .resizable()
                .scaledToFit()
                .frame(height: 350)
            
            HStack {
                Text("\(completedCount)/\(totalCount) 회 완료")
                    .font(.subheadline)
                Spacer()
                Text("\(Int(progress))%")
                    .font(.subheadline)
            }
            ProgressView(value: progress / 100)
                .progressViewStyle(.linear)
                .tint(Color("Brandprimary"))
                .frame(height: 10)
                .clipShape(Capsule())
        }
        .onAppear {
                   print("✅ [SeedGrowthStatusView] 이미지 테스트 ----")
                   print("👉 seedName(raw):", routine.seedName ?? "nil")
                   print("👉 imagePrefix:", imagePrefix)
                   print("👉 progress:", progress)
                   print("👉 currentStage:", currentStage)
                   print("👉 최종 이미지 호출:", "\(imagePrefix)\(String(format: "%02d", currentStage))")
               }
    }
    private var displayName: String {
        if imagePrefix.contains("Sunflower") { return "해바라기"}
        if imagePrefix.contains("Peach") {return "복숭아"}
        if imagePrefix.contains("Apple") { return "사과"}
            return "작물"
    }
}
