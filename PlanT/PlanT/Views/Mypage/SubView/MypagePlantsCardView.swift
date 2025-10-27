//
//  MypagePlantsCardView.swift
//  PlanT
//
//  Created by 이지훈 on 9/30/25.
//

import SwiftUI

struct MypagePlantsCardView: View {
    @StateObject private var viewModel: MypagePlantsCardViewModel

    init(authStore: AuthStore, routine: Routine, routineStore: RoutineStore) {
        _viewModel = StateObject(
            wrappedValue: MypagePlantsCardViewModel(
                authStore: authStore,
                routine: routine,
                routineStore: routineStore
            )
        )
    }

    var body: some View {
        VStack(alignment: .leading, spacing: vertical3) {
            VStack(alignment: .leading, spacing: vertical2) {
                Text(viewModel.title)
                    .font(.system(size: 22, weight: .bold))
                    .foregroundColor(.primary)

                Text(viewModel.subtitle)
                    .font(.system(size: vertical4, weight: .regular))
                    .foregroundColor(.secondary)
                    .frame(maxWidth: .infinity, alignment: .leading)

                Image(viewModel.plantImageName)
                    .resizable()
                    .scaledToFit()
                    .frame(maxWidth: .infinity)
                    .frame(height: 240)

                HStack {
                    Text("진행률")
                        .font(.system(size: vertical4, weight: .semibold))
                        .foregroundColor(.primary)
                    Spacer()
                    Text(viewModel.progressPercentText)
                        .font(.system(size: vertical4, weight: .semibold))
                        .foregroundColor(.secondary)
                }

                PlantProgressBar(progress: viewModel.progress)

                HStack(alignment: .top, spacing: vertical2) {
                    Image(viewModel.mateImageName)
                        .resizable()
                        .scaledToFit()
                        .frame(width: 40, height: 40)
                        .padding(.top, vertical1)

                    VStack(alignment: .leading, spacing: 0) {
                        Spacer(minLength: 0)
                        Text(viewModel.mateComment)
                            .font(.system(size: vertical4, weight: .semibold))
                            .foregroundColor(.gray)
                            .lineLimit(2)
                            .multilineTextAlignment(.leading)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .fixedSize(horizontal: false, vertical: true)
                        Spacer(minLength: 0)
                    }
                    .frame(maxWidth: .infinity,
                           minHeight: vertical4 * 2.8,
                           alignment: .leading)
                }
                .padding(.top, vertical1)
            }
            .padding(vertical5)
            .background(
                RoundedRectangle(cornerRadius: cornerRadius3, style: .continuous)
                    .fill(Color(UIColor.systemBackground))
            )
            .overlay(
                RoundedRectangle(cornerRadius: cornerRadius3, style: .continuous)
                    .stroke(Color.black.opacity(0.5), lineWidth: 1)
            )
        }
    }
}

// MARK: - 루틴 없을 때 띄울 빈카드
struct MypageEmptyPlantsCardView: View {
    let mateImageName: String

    var body: some View {
        VStack(alignment: .leading, spacing: vertical2) {
            Text("아직 성장중인 작물이 없어요")
                .font(.system(size: 22, weight: .bold))
                .foregroundColor(.primary)

            Text("루틴을 등록하고 당신만의 작물을 키워보세요!")
                .font(.system(size: vertical4, weight: .regular))
                .foregroundColor(.secondary)
                .frame(maxWidth: .infinity, alignment: .leading)

            Image("Soil") // 비어있을 때 보여줄 이미지(프로젝트 내 자산에 맞게 변경 가능)
                .resizable()
                .scaledToFit()
                .frame(maxWidth: .infinity)
                .frame(height: 240)

            HStack {
                Text("진행률")
                    .font(.system(size: vertical4, weight: .semibold))
                    .foregroundColor(.primary)
                Spacer()
                Text("0%")
                    .font(.system(size: vertical4, weight: .semibold))
                    .foregroundColor(.secondary)
            }

            PlantProgressBar(progress: 0)

            HStack(alignment: .top, spacing: vertical2) {
                Image(mateImageName)
                    .resizable()
                    .scaledToFit()
                    .frame(width: 40, height: 40)
                    .padding(.top, 4)

                VStack(alignment: .leading, spacing: 0) {
                    Spacer(minLength: 0)
                    Text("새 루틴을 시작해볼까요?")
                        .font(.system(size: vertical4, weight: .semibold))
                        .foregroundColor(.gray)
                        .lineLimit(2)
                        .multilineTextAlignment(.leading)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .fixedSize(horizontal: false, vertical: true)
                    Spacer(minLength: 0)
                }
                .frame(maxWidth: .infinity,
                       minHeight: vertical4 * 2.8,
                       alignment: .leading)
            }
            .padding(.top, vertical1)
        }
        .padding(20)
        .background(
            RoundedRectangle(cornerRadius: cornerRadius3, style: .continuous)
                .fill(Color(UIColor.systemBackground))
        )
        .overlay(
            RoundedRectangle(cornerRadius: cornerRadius3, style: .continuous)
                .stroke(Color.black.opacity(0.5), lineWidth: 1)
        )
    }
}
