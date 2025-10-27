//
//  SeedStatusView.swift
//  PlanT
//
//  Created by 박성관 on 9/29/25.
//

import SwiftUI

enum SeedStatus {
    case notPlanted
    case planted(Int)
}

struct SeedStatusView: View {
    let state: SeedStatus
    let draft: RoutineDraft
    @Binding var path: NavigationPath
    @Binding var showAddAlarmSheet: Bool
    
    @State private var showSeedSelection = false
    @State private var selectedSeed: Seed? = nil
    @State private var goToRoutineList = false
    @State private var isLoding: Bool = false
    @State private var currentStatus: SeedStatus = .notPlanted
    
    @EnvironmentObject var store: RoutineStore
    
    var body: some View {
        VStack {
            Spacer(minLength: 40)
            switch currentStatus {
            case .notPlanted:
                if let seed = selectedSeed {
                    selectedSeedView(seed: seed)
                } else {
                    notPlantedView
                }
            case .planted(let count):
                plantedView(plantedCount: count)
            }
            Spacer(minLength: 20)
        }
        .navigationDestination(isPresented: $goToRoutineList) {
            RoutineListView(path: $path, showAddAlarmSheet: $showAddAlarmSheet)
        }
        .sheet(isPresented: $showSeedSelection, onDismiss: {
            if selectedSeed != nil {
                withAnimation {
                    currentStatus = .notPlanted
                    updateSeedStatus()
                }
            }
        }) {
            SeedSelectionView(selectedSeed: $selectedSeed)
        }
        .overlay {
            if isLoding {
                Color.white.ignoresSafeArea()
                ZStack {
                    LoadingScreenView()
                }
                .transition(.opacity)
                .animation(.easeInOut, value: isLoding)
            }
        }
        .onAppear {
            isLoding = false
            if selectedSeed != nil {
                currentStatus = .notPlanted
            } else {
                updateSeedStatus()
            }
        }
    }
    
    // MARK: - 상태 업데이트
    private func updateSeedStatus() {
        if selectedSeed != nil {
            currentStatus = .notPlanted
            return
        }
        let plantedRoutines = store.routines.filter { !$0.isCompleted }
        if plantedRoutines.isEmpty {
            currentStatus = .notPlanted
        } else {
            currentStatus = .planted(plantedRoutines.count)
        }
    }
}

// MARK: - 뷰 구성 요소들
private extension SeedStatusView {
    var notPlantedView: some View {
        VStack {
            Text("루틴과 함께 성장할 \n 씨앗을 심어주세요. \n \n 성장하는 식물을 통해 \n 더 나은 하루를 만들어보세요.")
                .font(.title)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 16)
                .fixedSize(horizontal: false, vertical: true)
            
            Spacer()
            
            Image("Soil")
                .resizable()
                .scaledToFit()
                .frame(width:300, height: 300)
                .padding(.bottom,12)
            
            Spacer()
            
            Button("씨앗 선택하기") {
                showSeedSelection = true
            }
            .plantPrimaryButton()
            .padding(.horizontal, 20)
            .padding(.bottom, vertical3)
        }
    }
    
    func plantedView(plantedCount: Int) -> some View {
        VStack {
            Text("현재 님이 키우고 있는 \n 작물의 수는 \(plantedCount) 개 입니다. ")
                .font(.title)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 16)
                .padding(.bottom, 8)
            
            Spacer()
            
            Image("SoilSprout")
                .resizable()
                .scaledToFit()
                .frame(width: 250, height: 250)
            
            Spacer()
            
            Button("씨앗 선택하기") {
                showSeedSelection = true
            }
            .plantPrimaryButton()
            .padding(.horizontal, 20)
            .padding(.bottom, vertical3)
        }
    }
    
    func selectedSeedView(seed: Seed) -> some View {
        VStack {
            (
                Text("\(seed.name)")
                    .foregroundColor(.orange)
                    .font(.title)
                + Text(" 씨앗을 선택하셨습니다.\n루틴을 등록할까요?")
                    .foregroundColor(.black)
                    .font(.title)
            )
            .multilineTextAlignment(.center)
            .padding(.horizontal, 16)
            .fixedSize(horizontal: false, vertical: true)
            
            Spacer()
            
            Image("\(seed.imagePrefix)01")
                .resizable()
                .scaledToFit()
                .frame(width: 250, height: 250)
            
            Spacer()
            
            Button("씨앗 다시 선택하기") {
                showSeedSelection = true
            }
            .plantSecondaryButton()
            .padding(.horizontal, 20)
            
            Button("루틴 등록하기") {
                addRoutine(for: seed)
            }
            .plantPrimaryButton()
            .padding(.horizontal, 20)
            .padding(.bottom, vertical3)
        }
    }
    
    func addRoutine(for seed: Seed) {
        isLoding = true
        Task {
            let routine = Routine(
                title: draft.routineTypeTitle.isEmpty ? "새 루틴" : draft.routineTypeTitle,
                categoryId: draft.categoryId,
                seedName: seed.imagePrefix,
                duration: draft.durationTitle,
                goal: draft.goal,
                alarm: draft.reminderOn ? .every24Hours : .every48Hours,
                frequencyPerWeekId: draft.frequencyPerWeekId,
                frequencyPerWeekTitle: draft.frequencyPerWeekTitle,
                note: nil,
                isCompleted: false,
                createdAt: Date(),
                modifiedAt: Date()
            )
//            let ai = AlanAIService.shared
//            let aiComment = await ai.generateEncouragement(for: [
//                .init(id: routine.id,
//                      title: routine.title,
//                      total: 1,
//                      done: 0)
//            ])
//            print(" AI 우선 호출 완료:", aiComment)
            
            store.addRoutine(
                from: seed,
                basedOn: routine,
                categoryId: draft.categoryId,
                draft: draft,
                reminderOffsets: draft.reminderOffsets
            )
            
            NotificationManager.shared.scheduleTomorrow9AMNotification(for: routine)
            NotificationManager.shared.scheduleNotification(
                for: routine.id,
                title: routine.title,
                baseDate: draft.startDate ?? Date(),
                offsets: Array(draft.reminderOffsets)
            )
            
            try? await Task.sleep(nanoseconds: 5_000_000_000)
            
            await MainActor.run {
                isLoding  = false
                path = NavigationPath()
                showAddAlarmSheet = false
            }
        }
    }
}
