//
//  SeedSelectionView.swift
//  PlanT
//
//  Created by 박성관 on 9/29/25.
//

import SwiftUI

struct Seed: Equatable {
    let name: String
    let imageName: String
}

struct SeedSelectionView: View {
    @Environment(\.dismiss) private var dismiss
    @Binding var selectedSeed: Seed?
    
    let allSeeds: [Seed?] = [
        Seed(name: "사과", imageName: "seed_Apple01"),
        Seed(name: "목송아", imageName: "seed_Peach01"),
        Seed(name: "해바라기", imageName: "seed_Sunflower01"),
        nil, nil, nil,
        nil, nil, nil,
    ]
    
    var body: some View {
        ZStack(alignment: .topTrailing) {
            ScrollView {
                VStack(spacing: 16) {
                    Capsule()
                        .frame(width: 40, height: 3)
                        .foregroundColor(.gray.opacity(0.3))
                        .padding(.top, 12)
                    
                    Text("씨앗을 선택해 주세요")
                        .font(.title)
                        .padding(.top, 8)
                    
                    LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 3), spacing: 16) {
                        ForEach(allSeeds.indices, id: \.self) { index in
                            let seed = allSeeds[index]
                            
                            ZStack {
                                RoundedRectangle(cornerRadius: 10)
                                    .stroke(Color.gray.opacity(0.3), lineWidth: 1)
                                    .background(Color.white)
                                    .frame(height: 150)
                                
                                if let seed = seed {
                                    VStack(spacing: 4) {
                                        Spacer().frame(height: 4)
                                        
                                        ZStack {
                                            Image(seed.imageName)
                                                .resizable()
                                                .scaledToFit()
                                                .frame(width: 120, height: 120)
                                            
                                            if selectedSeed == seed {
                                                Image(systemName: "checkmark.circle.fill")
                                                    .resizable()
                                                    .foregroundColor(.blue)
                                                    .frame(width: 24, height: 24)
                                                    .offset(x: -25, y: -25)
                                            }
                                        }
                                        Text(seed.name)
                                            .font(.caption)
                                    }
                                    .onTapGesture {
                                        selectedSeed = seed
                                    }
                                }
                            }
                        }
                    }
                    .padding(.horizontal)
                    
                    Spacer()
                    if let seed = selectedSeed {
                        
                        Button {
                            dismiss()
                            
                        } label: {
                            Text("'\(seed.name)' 선택완료")
                            
                        }
                        .plantPrimaryButton()
                        .padding(.horizontal, 20)
                        .padding(.bottom, 16)
                        
                    } else {
                        Button {
                        } label: {
                            Text("'선택씨앗' 선택완료")
                        }
                        .plantPrimaryButton()
                        .padding(.horizontal, 20)
                        .padding(.bottom, 16)
                        .disabled(true)
                    }
                }
            }
            
            Button{
                dismiss()
            } label: {
                Text("닫기")
                    .font(.title)
                    .foregroundColor(.gray)
                    .padding()
            }
            .zIndex(1)
        }
    }
}


