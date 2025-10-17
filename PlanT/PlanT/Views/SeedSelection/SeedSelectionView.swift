//
//  SeedSelectionView.swift
//  PlanT
//
//  Created by 박성관 on 9/29/25.
//

import SwiftUI

// 씨앗 데이터 모델 (이름 + 이미지 이름)
struct Seed: Equatable {
    let name: String
    let imagePrefix: String
}
/// - 모든 씨앗을 그리드(Grid)로 보여주고,
/// - 선택 시 선택 상태를 바인딩(@Binding)으로 부모에 전달,
struct SeedSelectionView: View {
    @Environment(\.dismiss) private var dismiss  // 현재 뷰를 닫는 환경 변수
    @Binding var selectedSeed: Seed?            // 외부와 공유하는 선택된 씨앗
    
    // 전체 씨앗 리스트 (Seed? 배열로 구성하여 빈 칸 표현 가능)
    let allSeeds: [Seed?] = [
        Seed(name: "사과", imagePrefix: "seed_Apple"),
        Seed(name: "복숭아", imagePrefix: "seed_Peach"),
        Seed(name: "해바라기", imagePrefix: "seed_Sunflower"),
        nil, nil, nil,
        nil, nil, nil,
    ]
    
    var body: some View {
        ZStack(alignment: .topTrailing) {
            ScrollView {
                VStack(spacing: 16) {
                    // 상단 드래그 캡슐 모양 (시트 형태 느낌)
                    Capsule()
                        .frame(width: 40, height: 3)
                        .foregroundColor(.gray.opacity(0.3))
                        .padding(.top, 10)
                    
                    // 제목
                    Text("씨앗을 선택해 주세요")
                        .font(.title)
                        .padding(.top, 8)
                    
                    // 3열 그리드 레이아웃
                    LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 3), spacing: 16) {
                        ForEach(allSeeds.indices, id: \.self) { index in
                            let seed = allSeeds[index]
                            
                            ZStack {
                                // 씨앗 카드 기본 틀
                                RoundedRectangle(cornerRadius: 10)
                                    .stroke(Color.gray.opacity(0.3), lineWidth: 1)
                                    .background(Color.white)
                                    .frame(height: 150)
                                
                                // 실제 씨앗 데이터가 있을 때만 표시
                                if let seed = seed {
                                    VStack(spacing: 4) {
                                        Spacer().frame(height: 4)
                                        ZStack {
                                            // 씨앗 이미지
                                            Image("\(seed.imagePrefix)01")
                                                .resizable()
                                                .scaledToFit()
                                                .frame(width: 110, height: 110)
                                            
                                            // 현재 선택된 씨앗이면 체크마크 표시
                                            if selectedSeed == seed {
                                                Image(systemName: "checkmark.circle.fill")
                                                    .resizable()
                                                    .foregroundColor(.blue)
                                                    .frame(width: 24, height: 24)
                                                    .offset(x: -25, y: -25) // 좌측 상단에 배치
                                            }
                                        }
                                        // 씨앗 이름
                                        Text(seed.name)
                                            .font(.title2)
                                    }
                                    // 카드 탭 시 해당 씨앗을 선택
                                    .onTapGesture {
                                        selectedSeed = Seed(name: seed.name, imagePrefix: seed.imagePrefix)
                                    }
                                }
                            }
                        }
                    }
                    .padding(.horizontal)
                    
                    Spacer()
                    
                    // 선택 완료 버튼
                    if let seed = selectedSeed {
                        Button {
                            dismiss() // 현재 뷰 닫기
                        } label: {
                            Text("'\(seed.name)' 선택완료")
                        }
                        .plantPrimaryButton()
                        .padding(.horizontal, 20)
                        .padding(.bottom, 16)
                    } else {
                        // 씨앗 미선택 시 비활성화된 버튼
                        Button {} label: {
                            Text("'선택씨앗' 선택완료")
                        }
                        .plantPrimaryButton()
                        .padding(.horizontal, 20)
                        .padding(.bottom, 16)
                        .disabled(true)
                    }
                }
            }
            
            // 오른쪽 상단 닫기 버튼
            Button {
                dismiss()
            } label: {
                Text("닫기")
                    .font(.title)
                    .foregroundColor(.gray)
                    .padding()
            }
            .zIndex(1) // 스크롤 뷰 위에 항상 보이도록 zIndex 지정
        }
    }
}
