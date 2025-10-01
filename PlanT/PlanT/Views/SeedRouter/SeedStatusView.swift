//
//  SeedStatusView.swift
//  PlanT
//
//  Created by 박성관 on 9/29/25.
//

import SwiftUI

struct SeedStatusView: View {
    let state: SeedStatus
    @State private var showSeedSelection = false // 씨앗 선택 시트 표시 여부
    @State private var selectedSeed: Seed? = nil // 현재 선택된 씨앗 (nil이면 아직 선택되지 않은 상태)
    @State private var goToRoutineList = false   // 루틴 리스트 화면으로 내비게이션 여부
    
    var body: some View {
        VStack(spacing: 24) {
            Spacer(minLength: 100)
            
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
                Image(seed.imageName)
                    .resizable()
                    .scaledToFit()
                    .frame(width: 300, height: 300)
                    .padding(.bottom, 12)
                
                Spacer()
                
                // 씨앗 다시 선택하기 버튼 → 선택 시트 재호출
                Button("씨앗 다시 선택하기") {
                    showSeedSelection = true
                }
                .plantSecondaryButton()
                .padding(.horizontal, 20)
                
                // 등록하기 버튼 → 루틴 리스트 화면으로 이동
                Button("등록하기") {
                    goToRoutineList = true
                }
                .plantPrimaryButton()
                .padding(.horizontal, 20)
                
                Spacer(minLength: 40)
                
            } else {
                // 씨앗 미선택 상태 ----------------------
                
                // 안내 텍스트
                Text("아직 심겨진 씨앗이 없어요!\n새로운 씨앗을 심어볼까요?")
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
            
            Spacer(minLength: 50)
        }
        // 내비게이션: goToRoutineList가 true가 되면 RoutineListView로 전환
        .navigationDestination(isPresented: $goToRoutineList) {
            RoutineListView()
        }
        // 씨앗 선택 시트: showSeedSelection이 true일 때 SeedSelectionView 표시
        .sheet(isPresented: $showSeedSelection) {
            SeedSelectionView(selectedSeed: $selectedSeed)
        }
    }
}

// MARK: - 프리뷰
#Preview("미심기 상태") {
    SeedStatusView(state: .notPlanted) // selectedSeed가 nil → 미선택 UI
}

#Preview("심긴 상태") {
    // sampleCategories[0].routines[0] is a valid Routine
    SeedStatusView(state: .planted(sampleCategories[0].routines[0]))
    // 주의: 현재 구현에서는 state를 직접 반영하지 않으므로 selectedSeed 초기값은 nil.
}
