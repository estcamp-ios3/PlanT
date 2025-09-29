//
//  Untitled.swift
//  PlanT
//
//  Created by 박성관 on 9/29/25.
//

import SwiftUI

struct SeedStatusView: View {
    let state: SeedStatus
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 24) {
                // 상태에 따라 텍스트 변경
                Spacer(minLength: 100) // 위쪽 빈칸
                
                Text(statusMessage)
                    .font(.system(size: 30, weight: .semibold))
                    .multilineTextAlignment(.center)
                    .foregroundColor(.black)
                    .padding(.horizontal, 16)
                Spacer()
                // 가운데 흙/씨앗 이미지
                Image(imageName)
                    .resizable()
                    .scaledToFit()
                    .frame(width: 300, height: 300) // 원하는 크기로 조정
                    .padding(.bottom, 12)
                
                // 아래 버튼
                NavigationLink(destination: SeedSelectionView()) {
                    Text("씨앗선택하기")
                }
                .plantPrimaryButton()
                .padding(.horizontal, 20)
                Spacer(minLength: 50) // 아래쪽 빈칸
                
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(Color.white)
        }
    }
    
    private var statusMessage: String {
        switch state {
        case .planted(_):
            return "현재 (닉네임)님이 키우고 있는\n작물은 (몇) 개 입니다"
        case .notPlanted:
            return "아직 심겨진 씨앗이 없어요!\n새로운 씨앗을 심어볼까요?"
        }
    }
    
    private var imageName: String {
        switch state {
        case .planted:
            return "SoilSprout" // ex: 심긴 이미지 이름
        case .notPlanted:
            return "Soil" // ex: 안 심긴 상태 이미지
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
