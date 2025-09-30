//
//  Untitled.swift
//  PlanT
//
//  Created by 박성관 on 9/29/25.
//

import SwiftUI

struct SeedStatusView: View {
    let state: SeedStatus
    @State private var showSeedSelection = false
    @State private var selectedSeed: Seed? = nil
    @State private var goToRoutineList = false
    
    var body: some View {
        VStack(spacing: 24) {
            // 상태에 따라 텍스트 변경
            Spacer(minLength: 100) // 위쪽 빈칸
            
            if let seed = selectedSeed {
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
                .lineLimit(nil)
                .fixedSize(horizontal: false, vertical: true)
                
                Spacer()
                
                Image(seed.imageName)
                    .resizable()
                    .scaledToFit()
                    .frame(width: 300, height: 300) // 원하는 크기로 조정
                    .padding(.bottom, 12)
                
                Spacer()
                
                Button("씨앗 다시 선택하기") {
                    showSeedSelection = true
                }
                .plantSecondaryButton()
                .padding(.horizontal, 20)
                
                Button("등록하기") {
                    goToRoutineList = true
                }
                .plantPrimaryButton()
                .padding(.horizontal, 20)
                
                Spacer(minLength: 40)   // 버튼 그룹 밑에 빈칸
                
            } else {
                Text("아직 심겨진 씨앗이 없어요!\n새로운 씨앗을 심어볼까요?")
                    .font(.title)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 16)
                    .lineLimit(nil)
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
            }
            Spacer(minLength: 50)
        }
        .navigationDestination(isPresented: $goToRoutineList) {
            RoutineListView()
        }
        .sheet(isPresented: $showSeedSelection, onDismiss: {
        }) {
            SeedSelectionView(selectedSeed: $selectedSeed)
        }
    }
}

#Preview("미심기 상태") {
    SeedStatusView(state: .notPlanted)
}

#Preview("심긴 상태") {
    // sampleCategories[0].routines[0] is a valid Routine
    SeedStatusView(state: .planted(sampleCategories[0].routines[0]))
}
