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
    @Published var progress: Double = 0.0            // 0.0 ~ 1.0
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

        updateViewModelData()

        authStore.$mate
            .map { $0 ?? "MrPurr" }
            .removeDuplicates()
            .receive(on: RunLoop.main)
            .assign(to: \.mateImageName, on: self)
            .store(in: &cancellables)

        // 루틴 업데이트 감지 후 자동 갱신
        routineStore.$refreshTrigger
            .sink { [weak self] _ in
                guard let self = self else { return }
                self.refreshFromStore()
            }
            .store(in: &cancellables)
    }

    // MARK: - ViewModel Data Update
    private func updateViewModelData() {
        self.title = routine.title
        self.subtitle = !routine.goal.isEmpty ? routine.goal : (routine.note ?? "")

        let progressPercent = routineStore.progress(for: routine)
        self.progress = progressPercent / 100.0 // 0~100 → 0~1

        self.plantImageName = routine.seedImage(for: progressPercent)
    }

    // MARK: - Store Refresh Handling
    private func refreshFromStore() {
        // 최신 루틴 상태 찾기
        if let updatedRoutine = routineStore.routines.first(where: { $0.id == routine.id }) {
            self.routine = updatedRoutine
            updateViewModelData()
        }
    }

    // MARK: - Computed
    var progressPercentText: String {
        "\(Int(progress * 100))%"
    }
}
