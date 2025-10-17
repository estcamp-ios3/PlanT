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

    // MARK: - Published Properties
    @Published var title: String = ""
    @Published var subtitle: String = ""
    @Published var progress: Double = 0.0            // 0.0 ~ 1.0 (뷰에서 쓰는 비율)
    @Published var plantImageName: String = "seed_Sunflower03"
    @Published var mateComment: String = "거의 다왔어요! 앞으로 2회만 더 힘내라골골!"
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

        // 초기 세팅
        updateViewModelData()

        // 메이트 이미지 자동 동기화
        authStore.$mate
            .map { $0 ?? "MrPurr" }
            .removeDuplicates()
            .receive(on: RunLoop.main)
            .assign(to: \.mateImageName, on: self)
            .store(in: &cancellables)

        // 루틴 변경 트리거 감지 → 자동 갱신
        routineStore.$refreshTrigger
            .sink { [weak self] _ in
                guard let self = self else { return }
                self.refreshFromStore()
            }
            .store(in: &cancellables)
    }

    // MARK: - ViewModel Data Update
    private func updateViewModelData() {
        // 텍스트들
        title = routine.title
        subtitle = !routine.goal.isEmpty ? routine.goal : (routine.note ?? "")

        // 진행률(%) 및 비율(0~1)
        let progressPercent = routineStore.progress(for: routine)                  // 0~100
        progress = progressPercent / 100.0                                         // 0.0~1.0

        // ✅ 총 횟수 계산 후, 새 시그니처로 이미지 이름 생성
        let total = routineStore.totalCount(for: routine)                           // 예: x3 → 3
        plantImageName = routine.seedImage(for: progressPercent, totalCount: total)
    }

    // MARK: - Store Refresh Handling
    private func refreshFromStore() {
        // 최신 Routine로 교체 후, 다시 계산
        if let updated = routineStore.routines.first(where: { $0.id == routine.id }) {
            routine = updated
            updateViewModelData()
        }
    }

    // MARK: - Computed
    var progressPercentText: String {
        "\(Int(progress * 100))%"
    }
}
