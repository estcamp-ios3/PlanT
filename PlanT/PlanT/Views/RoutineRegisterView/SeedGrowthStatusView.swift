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
            if progress >= 100 {
                return 5
            } else if progress >= 75 {
                return 4
            } else if progress >= 50 {
                return 3
            } else if progress >= 25 {
                return 2
            } else {
                return 1
            }
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Text("작물 상태")
                    .font(.headline)
                    .themedTextColor()

                Spacer()
                Text("\(displayName) \(currentStage)단계")
                    .font(.subheadline)
                    .themedTextColor()

            }
            Image(routine.seedImage(for: progress, totalCount: totalCount))
                .resizable()
                .scaledToFit()
                .frame(height: 350)
                .frame(maxWidth: .infinity, alignment: .center)
            
            HStack {
                Text("\(completedCount)/\(totalCount)(회) 완료")
                    .font(.subheadline)
                    .themedTextColor()

                Spacer()
                Text("\(Int(progress))%")
                    .font(.subheadline)
                    .themedTextColor()

            }
            ProgressView(value: progress / 100)
                .progressViewStyle(.linear)
                .tint(Color("BrandPrimary"))
                .frame(height: 20)
                .clipShape(Capsule())
                .padding(.top, 6)
                .animation(.easeInOut(duration: 1.0), value: localProgress)
            
            if canCompleste {
                Button(action: {
                    store.increaseProgress(for:routine)
                    if let updatedRoutine = store.routines.first(where: { $0.id == routine.id }) {
                        self.routine = updatedRoutine
                        withAnimation(.easeInOut(duration: 1.0)) {
                            localProgress = store.progress(for: routine)
                        }
                    }
                })
                {
                    Text(completedCount >= totalCount ? "루틴 완료" : "루틴 1회 완료")
                        .frame(maxWidth: .infinity)
                }
                .plantPrimaryButton()
                .disabled(completedCount >= totalCount)
                
            }
        }
        .padding(.horizontal, vertical4)

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
