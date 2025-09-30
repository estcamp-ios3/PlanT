//
//  SeedRegisterView.swift
//  PlanT
//
//  Created by 박성관 on 9/29/25.
//


import SwiftUI

struct SeedRegisterView: View {
    
    @Environment(\.dismiss) private var dismiss
    
    let selectedSeed: Seed
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 24) {
                // 상단 안내 문구
                Spacer(minLength: 30) // 위쪽 빈칸
                
                VStack(spacing: 8) {
                    
                    // 닉네임/씨앗 이름 강조
                    (
                        Text("\(selectedSeed.name)")
                            .foregroundColor(.orange)
                            .font(.system(size: 20, weight: .bold))
                        + Text(" 씨앗을 선택하셨습니다.\n루틴을 등록할까요?")
                            .foregroundColor(.black)
                            .font(.system(size: 25, weight: .semibold))
                    )
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 16)
                }
                .padding(.top, 40)
                
                Spacer()
                
                // 씨앗 이미지
                Image(selectedSeed.imageName)
                    .resizable()
                    .scaledToFit()
                    .frame(width: 300, height: 300)
                    .padding(.bottom, 16)
                
                Spacer()
                
                // 버튼 영역
                VStack(spacing: 12) {
                    Button(action: {
                        dismiss()
                        print("씨앗 다시 선택하기")
                    }) {
                        Text("씨앗 다시 선택하기")
                            
                    }
                    .plantSecondaryButton()

                    // 뒤에 뷰 연결만들어 지면 수정하기
                    NavigationLink(destination: RoutineListView()) {
                        Text("등록하기")
                    }
                    .plantPrimaryButton()
                }
                .padding(.horizontal, 20)
                .padding(.bottom, 40)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(Color.white)
        }
    }
}

#Preview {
    SeedRegisterView(
        selectedSeed: Seed(name: "해바라기", imageName: "seed_Sunflower01")
    )
}
