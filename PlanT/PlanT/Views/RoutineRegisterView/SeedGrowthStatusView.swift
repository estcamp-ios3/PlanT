//
//  SeedGrowthStatusView.swift
//  PlanT
//
//  Created by 박성관 on 10/17/25.
//

import SwiftUI

struct SeedGrowthStatusView: View {
    @EnvironmentObject var store: RoutineStore
    @State private var localProgress: Double = 0
    @State private var refresh = UUID()
    @State var routine: Routine
    let canCompleste: Bool
    
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
            Image(routine.seedImage(for: progress, totalCount: totalCount))
                .resizable()
                .scaledToFit()
                .frame(height: 350)
                .frame(maxWidth: .infinity, alignment: .center)
            
            HStack {
                Text("\(completedCount)/\(totalCount)(회) 완료")
                    .font(.subheadline)
                Spacer()
                Text("\(Int(progress))%")
                    .font(.subheadline)
            }
            ProgressView(value: progress / 100)
                .progressViewStyle(.linear)
                .tint(Color("BrandPrimary"))
                .frame(height: 10)
                .clipShape(Capsule())
                .padding(.top, 6)

            if canCompleste {
                Button(" 루틴 1회 완료") {
                    store.increaseProgress(for:routine)
                    if let updatedRoutine = store.routines.first(where: { $0.id == routine.id }) {
                        self.routine = updatedRoutine
                        localProgress = store.progress(for: routine)
                    }
                }
                .plantPrimaryButton()
                .disabled(completedCount >= totalCount)

            }
        }
        .onReceive(store.$refreshTrigger) { _ in
            refresh = UUID()
        }
        
        .onAppear {
            localProgress = store.progress(for: routine)
        }
    }
    private var displayName: String {
        if imagePrefix.contains("Sunflower") { return "해바라기"}
        if imagePrefix.contains("Peach") {return "복숭아"}
        if imagePrefix.contains("Apple") { return "사과"}
        return "작물"
    }
}
