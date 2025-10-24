//
//  SeedStatusView.swift
//  PlanT
//
//  Created by 박성관 on 9/29/25.
//

import SwiftUI

enum SeedStatus {
    case notPlanted
    case planted(Routine) // 이미 심겨진 루틴 정보
}

struct SeedStatusView: View {
    let state: SeedStatus
    let draft: RoutineDraft
    @Binding var path: NavigationPath
    @Binding var showAddAlarmSheet: Bool
    
    @State private var showSeedSelection = false // 씨앗 선택 시트 표시 여부
    @State private var selectedSeed: Seed? = nil // 현재 선택된 씨앗 (nil이면 아직 선택되지 않은 상태)
    @State private var goToRoutineList = false   // 루틴 리스트 화면으로 내비게이션 여부
    @State private var isLoding: Bool = false
    @EnvironmentObject var store: RoutineStore
    var body: some View {
        VStack {
            Spacer(minLength: 40)
            
            // 분기 처리: 씨앗이 선택된 경우 vs 선택되지 않은 경우
            if let seed = selectedSeed {
                
                // 선택된 씨앗 이름 강조 + 안내 텍스트 결합
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
                
                // 선택된 씨앗 이미지 표시
                Image("\(seed.imagePrefix)01")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 250, height: 250)
                
                Spacer()
                
                // 씨앗 다시 선택하기 버튼 → 선택 시트 재호출
                Button("씨앗 다시 선택하기") {
                    showSeedSelection = true
                }
                .plantSecondaryButton()
                .padding(.horizontal, 20)
                
                // 등록하기 버튼 → 루틴 리스트 화면으로 이동
                Button("루틴 등록하기") {
                    isLoding = true
                    Task {
                    // 기존: store.routines.insert(routine, at: 0) → 삭제
                    if case .planted(_) = state {
                        print("식물 심긴상태 추가")
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

                        
                        store.addRoutine(
                            from: seed,
                            basedOn: routine,
                            categoryId: draft.categoryId,
                            draft: draft,
                            reminderOffsets: draft.reminderOffsets
                            
                        )
                        print("✅ 저장된 알람 오프셋 값:", Array(draft.reminderOffsets)) // 👈 이 줄 추가


                            NotificationManager.shared.scheduleTomorrow9AMNotification(for: routine)
                        print(" 알림 예약 시도 (내일 9시)")


                            NotificationManager.shared.scheduleNotification(
                                for: routine.id,
                                title: routine.title,
                                baseDate: draft.startDate ?? Date(),
                                offsets: Array(draft.reminderOffsets)
                            )
                        print(" 일반 알림 예약 시도")

                        
                        path = NavigationPath()
                    } else {
                        print("식물 안심겼을때 새 루틴 생성 시작")
                        
                        // .notPlanted 상태에서는 draft와 seed로 Routine 생성 & 추가
                        let routine = Routine(
                            title: draft.routineTypeTitle.isEmpty ? "새 루틴" : draft.routineTypeTitle,
                            categoryId: draft.categoryId,
                            seedName: seed.imagePrefix,
                            duration: "\(draft.routinePeriodDays)일",
                            goal: draft.goal,
                            alarm: draft.reminderOn ? .every24Hours : .every48Hours,
                            frequencyPerWeekId: draft.frequencyPerWeekId,
                            frequencyPerWeekTitle: draft.frequencyPerWeekTitle,
                            note: nil,
                            isCompleted: false,
                            createdAt: Date(),
                            modifiedAt: Date(),
                            
                        )
                        print("안 심긴 새 루틴 생성 완료: \(routine.title) / 완료상태: \(routine.isCompleted)")
                        
                        store.addRoutine(from: seed, basedOn: routine, categoryId: draft.categoryId, draft: draft, reminderOffsets: draft.reminderOffsets)
                        print("안 심긴 알림 예약 시도 (내일 9시)")
                        
                        NotificationManager.shared.scheduleTomorrow9AMNotification(for: routine)
                        print("안 심긴 일반 알림 예약 시도")
                        
                        NotificationManager.shared.scheduleNotification(
                            for: routine.id,
                            title: routine.title,
                            baseDate: draft.startDate ?? Date(),
                            offsets: Array(draft.reminderOffsets)
                        )
                    }
                        try? await Task.sleep(nanoseconds: 5_000_000_000)
                        await MainActor.run {
                            isLoding  = false
                        }
                        path = NavigationPath()
                    }
                }
                .plantPrimaryButton()
                .padding(.horizontal, 20)
                .padding(.bottom, vertical3)

                
            } else {
                // 씨앗 미선택 상태 ----------------------
                
                // 안내 텍스트
                Text("루틴과 함께 성장할 씨앗을 \n 심어주세요. \n \n 성장하는 식물을 통해 \n 더 나은 하루를 만들어보세요.")
                    .font(.title)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 16)
                    .fixedSize(horizontal: false, vertical: true)
                
                Spacer()
                
                // 기본 토양 이미지
                Image("Soil")
                    .resizable()
                    .scaledToFit()
                    .frame(width:300, height: 300)
                    .padding(.bottom,12)
                
                Spacer()
                
                // 씨앗 선택 버튼 → 선택 시트 표시
                Button("씨앗 선택하기") {
                    showSeedSelection = true
                }
                .plantPrimaryButton()
                .padding(.horizontal, 20)
                .padding(.bottom, vertical3)
            }
        }
        // 내비게이션: goToRoutineList가 true가 되면 RoutineListView로 전환
        .navigationDestination(isPresented: $goToRoutineList) {
            RoutineListView(path: $path, showAddAlarmSheet: $showAddAlarmSheet)
        }
        // 씨앗 선택 시트: showSeedSelection이 true일 때 SeedSelectionView 표시
        .sheet(isPresented: $showSeedSelection) {
            SeedSelectionView(selectedSeed: $selectedSeed)
        }
        .onAppear { isLoding = false }
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
    }
}

