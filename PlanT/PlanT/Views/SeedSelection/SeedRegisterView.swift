//
//  SeedRegisterView.swift
//  PlanT
//
//  Created by 박성관 on 9/29/25.
//


import SwiftUI

struct SeedRegisterView: View {
    let selectedSeed: Seed
    
    var body: some View {
        VStack(spacing: 24) {
            // 상단 안내 문구
            Spacer(minLength: 50) // 위쪽 빈칸

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
                    print("씨앗 다시 선택하기")
                }) {
                    Text("씨앗 다시 선택하기")
                        .font(.headline)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.gray.opacity(0.2))
                        .foregroundColor(.black)
                        .cornerRadius(12)
                }
                
                Button(action: {
                    print("루틴 등록하기")
                }) {
                    Text("등록하기")
                        .font(.headline)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.green)
                        .foregroundColor(.white)
                        .cornerRadius(12)
                }
            }
            .padding(.horizontal, 20)
            .padding(.bottom, 40)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color.white)
    }
}

#Preview {
    SeedRegisterView(
        selectedSeed: Seed(name: "해바라기", imageName: "seed_Sunflower01")
    )
}
