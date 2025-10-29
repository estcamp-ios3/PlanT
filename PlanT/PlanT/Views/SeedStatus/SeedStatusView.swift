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
    @EnvironmentObject var authStore: AuthStore
    @EnvironmentObject var store: RoutineStore
    @EnvironmentObject var routineAlarmStore: RoutineAlarmStore

    
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
            Text("현재 \(authStore.nickName ?? "회원")님이 키우고 있는 \n 작물의 수는 \(plantedCount) 개 입니다. ")
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
                let durationText: String
                let totalDays: Int
            var startDate = Date()
            var endDate = Date()

            switch draft.sourceType {
            case .template:
                
                //  템플릿 기반: draft.totalDays 우선 사용
                let days = draft.totalDays ?? draft.durationTitle.extractDays()
                totalDays = days
                durationText = "\(days)일"
                
                //  템플릿에서만 날짜 자동 계산
                        startDate = Date()
                        endDate = Calendar.current.date(byAdding: .day, value: days, to: startDate)!
                        print(" [템플릿기반] 자동 계산된 날짜 → 시작: \(startDate), 종료: \(endDate)")
            case .survey:
                //  설문 기반: 날짜 계산
                let start = draft.startDate ?? Date()
                let end = draft.endDate ?? Date()
                let days = Calendar.current.dateComponents([.day], from: start, to: end).day ?? 0
                totalDays = max(days, 1)
                durationText = "\(totalDays)일"
            }

        
            
                //  루틴 생성
                let routine = Routine(
                    title: draft.routineTypeTitle.isEmpty ? "새 루틴" : draft.routineTypeTitle,
                    categoryId: draft.categoryId,
                    seedName: seed.imagePrefix,
                    duration: durationText,
                    goal: draft.goal,
                    alarm: draft.reminderOn ? .every24Hours : .every48Hours,
                    frequencyPerWeekId: draft.frequencyPerWeekId,
                    frequencyPerWeekTitle: draft.frequencyPerWeekTitle,
                    note: nil,
                    isCompleted: false,
                    createdAt: Date(),
                    modifiedAt: Date()
                )
            
      

            //  Store에 추가 (SwiftData + Supabase)
            let created = store.addRoutine(
                from: seed,
                basedOn: routine,
                categoryId: draft.categoryId,
                draft: draft,
                reminderOffsets: draft.reminderOffsets
            )

            //  2. 각 루틴의 알림 프리셋 저장
            routineAlarmStore.saveOffsets(
                for: created.id,
                offsets: Array(draft.reminderOffsets).sorted()
            )

            //  로컬 알림 등록 확인
            NotificationManager.shared.scheduleTomorrow9AMNotification(for: routine)

            NotificationManager.shared.scheduleNotification(
                for: routine.id,
                title: routine.title,
                baseDate: draft.startDate ?? Date(),
                offsets: Array(draft.reminderOffsets)
            )

            //  대기(로딩 스크린 표시용)
            try? await Task.sleep(nanoseconds: 5_000_000_000)

            //  완료 후 UI 갱신
            await MainActor.run {
                isLoding = false
                path = NavigationPath()
                showAddAlarmSheet = false
            }
        }
    }
}
