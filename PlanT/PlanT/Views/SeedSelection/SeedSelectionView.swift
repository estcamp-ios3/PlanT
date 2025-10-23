//
//  SeedSelectionView.swift
//  PlanT
//
//  Created by 박성관 on 9/29/25.
//

import SwiftUI

/// - 모든 씨앗을 그리드(Grid)로 보여주고,
/// - 선택 시 선택 상태를 바인딩(@Binding)으로 부모에 전달,
struct SeedSelectionView: View {
    @Environment(\.dismiss) private var dismiss  // 현재 뷰를 닫는 환경 변수
    @Binding var selectedSeed: Seed?            // 외부와 공유하는 선택된 씨앗
    
    // allSeeds는 SeedType.swift에 정의된 글로벌 상수임
    private var allSeedsForGrid: [Seed?] {
        var list = allSeeds.map { Optional($0) }
        while list.count < 9 { list.append(nil) }
        return list
    }
    
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
                        ForEach(allSeedsForGrid.indices, id: \.self) { index in
                            let seed = allSeedsForGrid[index]
                            
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
                                            .padding(.bottom, vertical2) 

                                    }
                                    // 카드 탭 시 해당 씨앗을 선택
                                    .onTapGesture {
                                        selectedSeed = seed
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
                Image(systemName: "xmark")
                    .font(.system(size: 30, weight: .bold))
                    .foregroundColor(.red)
                    .shadow(radius: 4, x: 0, y: 4)
            }
            .padding(.trailing, 8)
            .padding(.top, 8)

            .zIndex(1) // 스크롤 뷰 위에 항상 보이도록 zIndex 지정
        }
    }
}
