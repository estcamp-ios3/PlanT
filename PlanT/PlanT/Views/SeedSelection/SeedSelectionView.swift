//
//  SeedSelectionView.swift
//  PlanT
//
//  Created by 박성관 on 9/29/25.
//

import SwiftUI

struct SeedSelectionView: View {
    @Environment(\.dismiss) private var dismiss
    @Binding var selectedSeed: Seed?
    @AppStorage("hasSeenSeedIntro") private var hasSeenSeedIntro: Bool = false
    @State private var showIntro = false
    @State private var showHelp = false

    private var allSeedsForGrid: [Seed?] {
        var list = allSeeds.map { Optional($0) }
        while list.count < 9 { list.append(nil) }
        return list
    }

    var body: some View {
        ZStack {
            ScrollView {
                VStack(spacing: 16) {
                    Capsule()
                        .frame(width: 40, height: 3)
                        .foregroundColor(.gray.opacity(0.3))
                        .padding(.top, 10)
                    
                    Text("씨앗을 선택해 주세요")
                        .font(.title)
                        .padding(.top, 8)
                    
                    // MARK: - Seed grid
                    LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 3), spacing: 16) {
                        ForEach(allSeedsForGrid.indices, id: \.self) { index in
                            let seed = allSeedsForGrid[index]
                            
                            ZStack {
                                RoundedRectangle(cornerRadius: 10)
                                    .stroke(Color.gray.opacity(0.3), lineWidth: 1)
                                    .background(Color.white)
                                    .frame(height: 150)
                                
                                if let seed = seed {
                                    VStack(spacing: 4) {
                                        Spacer().frame(height: 4)
                                        ZStack {
                                            Image("\(seed.imagePrefix)01")
                                                .resizable()
                                                .scaledToFit()
                                                .frame(width: 110, height: 110)
                                            
                                            if selectedSeed == seed {
                                                Image(systemName: "checkmark.circle.fill")
                                                    .resizable()
                                                    .foregroundColor(.blue)
                                                    .frame(width: 24, height: 24)
                                                    .offset(x: -25, y: -25)
                                            }
                                        }
                                        Text(seed.name)
                                            .font(.title2)
                                            .padding(.bottom, vertical2)
                                    }
                                    .onTapGesture {
                                        selectedSeed = seed
                                        hasSeenSeedIntro = true
                                        withAnimation { showIntro = false }
                                    }
                                }
                            }
                        }
                    }
                    .padding(.horizontal)
                    .overlay(alignment: .bottomTrailing) {
                        Button {
                            withAnimation(.easeInOut(duration: 0.5)) {
                                showIntro.toggle()
                            }
                        } label: {
                            Image(systemName: "questionmark.circle.fill")
                                .font(.system(size: 30, weight: .bold))
                                .foregroundColor(.brandPrimary)
                                .shadow(radius: 4, x: 0, y: 2)
                        }
                        .padding(.trailing, 12)
                        .padding(.bottom, -36)
                    }
                    
                    Spacer()
                    
                    // MARK: - Select button
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
                        Button {} label: {
                            Text("'선택씨앗' 선택완료")
                        }
                        .plantPrimaryButton()
                        .padding(.horizontal, 20)
                        .padding(.bottom, 16)
                        .disabled(true)
                    }
                }
                .cornerRadius(30)
            }

            // ❌ Close button always visible (top-right)
            VStack {
                HStack {
                    Spacer()
                    Button {
                        dismiss()
                    } label: {
                        Image(systemName: "xmark.circle.fill")
                            .font(.system(size: 30, weight: .bold))
                            .foregroundColor(.red)
                            .shadow(radius: 4, x: 0, y: 2)
                    }
                    .padding(.trailing, 12)
                    .padding(.top, vertical4)
                }
                Spacer()
            }

            if showIntro {
                ZStack {
                    Color.black.opacity(0.001)
                        .ignoresSafeArea()
                        .onTapGesture {
                            withAnimation(.easeInOut(duration: 0.3)) {
                                showIntro = false
                            }
                        }
                    
                    VStack {
                        Spacer()
                        VStack(spacing: 8) {
                            Text("식물마다 자라나는 열매가 다르고,")
                            Text("성장하는 모습이 다릅니다.")
                            Text("나만의 식물을 기르며 예쁜 과수원을 만들어보세요.")
                        }
                        .multilineTextAlignment(.center)
                        .font(.headline)
                        .foregroundColor(Color("BrandPrimary"))
                        .padding(24)
                        .background(Color("BG_F2F2F2").opacity(0.95))
                        .cornerRadius(20)
                        .shadow(radius: 8)
                        .padding(.horizontal, 30)
                        .padding(.bottom, 60)
                    }
                    .transition(.opacity)
                    .onAppear {
                        DispatchQueue.main.asyncAfter(deadline: .now() + 4) {
                            withAnimation(.easeInOut(duration: 0.8)) {
                                if !hasSeenSeedIntro {
                                    showIntro = true
                                    hasSeenSeedIntro = true
                                }
                            }
                        }
                    }
                }
            }
        }
    }
}
