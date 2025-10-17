//
//  MypagePlantsCardView.swift
//  PlanT
//
//  Created by 이지훈 on 9/30/25.
//

import SwiftUI

struct MypagePlantsCardView: View {
    @StateObject private var viewModel: MypagePlantsCardViewModel
    
    // 기존 @EnvironmentObject 사용 대신, 의존성 주입
    init(authStore: AuthStore) {
        _viewModel = StateObject(wrappedValue: MypagePlantsCardViewModel(authStore: authStore))
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: vertical3) {
            
            // 카드 외부 상단 제목
            Text(viewModel.sectionTitle)
                .font(.title3.bold())
                .foregroundColor(.primary)
                .frame(maxWidth: .infinity, alignment: .leading)
            
            // 카드 본문
            VStack(alignment: .leading, spacing: vertical2) {
                Text(viewModel.title)
                    .font(.system(size: 22, weight: .bold))
                    .foregroundColor(.primary)
                
                Text(viewModel.subtitle)
                    .font(.system(size: vertical4, weight: .regular))
                    .foregroundColor(.secondary)
                    .frame(maxWidth: .infinity, alignment: .leading)
                
                // 식물 이미지
                Image(viewModel.plantImageName)
                    .resizable()
                    .scaledToFit()
                    .frame(maxWidth: .infinity)
                    .frame(height: 240)
                
                // 진행률 라벨 + %
                HStack {
                    Text("진행률")
                        .font(.system(size: vertical4, weight: .semibold))
                        .foregroundColor(.primary)
                    Spacer()
                    Text(viewModel.progressPercentText)
                        .font(.system(size: vertical4, weight: .semibold))
                        .foregroundColor(.secondary)
                }
                
                // 커스텀 프로그레스바
                PlantProgressBar(progress: viewModel.progress)
                
                // 메이트 코멘트
                HStack(alignment: .top, spacing: vertical2) {
                    Image(viewModel.mateImageName)
                        .resizable()
                        .scaledToFit()
                        .frame(width: 40, height: 40)
                    
                    Text(viewModel.mateComment)
                        .font(.system(size: vertical4, weight: .semibold))
                        .foregroundColor(.gray)
                        .lineLimit(2)
                        .fixedSize(horizontal: false, vertical: true)
                }
                .padding(.top, vertical1)
            }
            .padding(20)
            .background(
                RoundedRectangle(cornerRadius: 28, style: .continuous)
                    .fill(Color(UIColor.systemBackground))
            )
            .overlay(
                RoundedRectangle(cornerRadius: 28, style: .continuous)
                    .stroke(Color.black.opacity(0.08), lineWidth: 1)
            )
        }
    }
}

#Preview {
    let auth = AuthStore()
    auth.mate = "MrPurr"
    return NavigationStack {
        ScrollView {
            MypagePlantsCardView(authStore: auth)
        }
    }
}
