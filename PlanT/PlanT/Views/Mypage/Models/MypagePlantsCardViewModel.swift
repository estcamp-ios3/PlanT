//
//  MypagePlantsCardViewModel.swift
//  PlanT
//
//  Created by 이지훈 on 10/17/25.
//

import Foundation
import Combine
import SwiftUI

@MainActor
final class MypagePlantsCardViewModel: ObservableObject {

    // MARK: - Published
    @Published var title: String = ""
    @Published var subtitle: String = ""
    @Published var progress: Double = 0.0            // 0.0 ~ 1.0
    @Published var plantImageName: String = "seed_Sunflower03"
    @Published var mateComment: String = "새로운 목표를 이루도록 제가 응원해 드릴께요!"
    @Published private(set) var mateImageName: String = "MrPurr"

    // MARK: - Dependencies
    private let authStore: AuthStore
    private let routineStore: RoutineStore
    private var routine: Routine
    private var cancellables = Set<AnyCancellable>()

    // MARK: - Init
    init(authStore: AuthStore, routine: Routine, routineStore: RoutineStore) {
        self.authStore = authStore
        self.routineStore = routineStore
        self.routine = routine

        updateViewModelData()

        // 🔹 앱 시작 시 저장된 코멘트가 있으면 즉시 표시
        if let cached = routineStore.aiComments[routine.id], !cached.isEmpty {
            self.mateComment = cached
        }

        // 메이트 이미지 동기화
        authStore.$mate
            .map { $0 ?? "MrPurr" }
            .removeDuplicates()
            .receive(on: RunLoop.main)
            .assign(to: \.mateImageName, on: self)
            .store(in: &cancellables)

        // ✅ AI 코멘트 구독: 이 카드의 routine.id 코멘트만 반영
        routineStore.$aiComments
            .compactMap { [weak self] dict -> String? in
                guard let self else { return nil }
                return dict[self.routine.id]
            }
            .removeDuplicates()
            .receive(on: RunLoop.main)
            .assign(to: \.mateComment, on: self)
            .store(in: &cancellables)

        // 진행률 변화 트리거에 반응 → 타이틀/진행률/이미지 갱신
        routineStore.$refreshTrigger
            .sink { [weak self] _ in self?.refreshFromStore() }
            .store(in: &cancellables)
    }

    // MARK: - Update
    private func updateViewModelData() {
        title = routine.title
        subtitle = !routine.goal.isEmpty ? routine.goal : (routine.note ?? "")

        let percent = routineStore.progress(for: routine)  // 0~100
        progress = percent / 100.0

        let total = routineStore.totalCount(for: routine)
        plantImageName = routine.seedImage(for: percent, totalCount: total)
    }

    private func refreshFromStore() {
        if let updated = routineStore.routines.first(where: { $0.id == routine.id }) {
            routine = updated
            updateViewModelData()
        }
    }

    var progressPercentText: String { "\(Int(progress * 100))%" }
}
