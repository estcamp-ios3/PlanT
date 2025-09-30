//
//  MypagePlantsCardView.swift
//  PlanT
//
//  Created by 이지훈 on 9/30/25.
//

//
//  MypagePlantsCardView.swift
//  PlanT
//
//  Created by 이지훈 on 9/30/25.
//

import SwiftUI

struct MypagePlantsCardView: View {
    // MARK: Config (샘플 바인딩 가능)
    private var title: String = "러닝 루틴(할 일 제목)"
    private var subtitle: String = "설정한 목표: 확신의 P가 한땀한땀 쌓아나가는 목표"
    private var progress: Double = 0.6 // 0.0 ~ 1.0
    private var plantImageName: String = "seed_Sunflower03"
    private var mateImageName: String = "MrPurr"
    private var mateComent: String = "거의 다왔어요! 앞으로 2회만 더 힘내라골골!"

    var body: some View {
            VStack(alignment: .leading, spacing: 8) {
                    Text(title)
                        .font(.system(size: 22, weight: .bold))
                        .foregroundColor(.primary)

                    Text(subtitle)
                        .font(.system(size: 15, weight: .regular))
                        .foregroundColor(.secondary)
                .frame(maxWidth: .infinity, alignment: .leading)

                // 식물 이미지
                Image(plantImageName)
                    .resizable()
                    .scaledToFit()
                    .frame(maxWidth: .infinity)
                    .frame(height: 240)

                // 진행률 라벨 + % 표시
                HStack {
                    Text("진행률")
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundColor(.primary)
                    Spacer()
                    Text("\(Int(progress * 100))%")
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundColor(.secondary)
                }

                // 커스텀 프로그레스바
                PlantProgressBar(progress: progress)

                // 메이트/코멘트
                HStack(alignment: .top, spacing: 8) {
                    Image(mateImageName)
                        .resizable()
                        .scaledToFit()
                        .frame(width: 40, height: 40)

                    Text(mateComent)
                        .font(.system(size: 16, weight: .semibold))
                        .padding(.top, 8) // 케릭터와 높이 맞추기용
                        .foregroundColor(.gray)
                        .lineLimit(2)
                        .frame(maxHeight: .infinity, alignment: .center) // 2줄 되니까 위치가 틀어짐..
                }
                .padding(.top, 4)
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

#Preview {
    NavigationStack {
        ScrollView { // 미리보기 스크롤 여유
            MypagePlantsCardView()
        }
    }
}
