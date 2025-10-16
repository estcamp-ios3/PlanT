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
    @State private var showSeedSelection = false // 씨앗 선택 시트 표시 여부
    @State private var selectedSeed: Seed? = nil // 현재 선택된 씨앗 (nil이면 아직 선택되지 않은 상태)
    @State private var goToRoutineList = false   // 루틴 리스트 화면으로 내비게이션 여부
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
                    // 기존: store.routines.insert(routine, at: 0) → 삭제
                    if case .planted(let routine) = state {
                        store.addRoutine(from: seed, basedOn: routine, categoryId: draft.categoryId)
                        path = NavigationPath()
                    } else {
                        // .notPlanted 상태에서는 draft와 seed로 Routine 생성 & 추가
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
                        store.addRoutine(from: seed, basedOn: routine, categoryId: draft.categoryId )
                        path = NavigationPath()
                    }
                }
                .plantPrimaryButton()
                .padding(.horizontal, 20)
                
                
            } else {
                // 씨앗 미선택 상태 ----------------------
                
                // 안내 텍스트
                Text("아직 심은 씨앗이 없어요!\n새로운 씨앗을 심어볼까요?")
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
            }
        }
        // 내비게이션: goToRoutineList가 true가 되면 RoutineListView로 전환
        .navigationDestination(isPresented: $goToRoutineList) {
            RoutineListView(path: $path)
        }
        // 씨앗 선택 시트: showSeedSelection이 true일 때 SeedSelectionView 표시
        .sheet(isPresented: $showSeedSelection) {
            SeedSelectionView(selectedSeed: $selectedSeed)
        }
    }
}
