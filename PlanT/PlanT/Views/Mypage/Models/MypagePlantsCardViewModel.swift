//
//  MypagePlantsCardViewModel.swift
//  PlanT
//
//  Created by 이지훈 on 10/17/25.
//

import Foundation
import Combine

final class MypagePlantsCardViewModel: ObservableObject {

    @Published var title: String = ""
    @Published var subtitle: String = ""
    @Published var progress: Double = 0.0
    @Published var plantImageName: String = "seed_Sunflower03"
    @Published var mateComment: String = "거의 다왔어요! 앞으로 2회만 더 힘내라골골!"
    @Published private(set) var mateImageName: String = "MrPurr"

    private let authStore: AuthStore

    init(authStore: AuthStore, routine: Routine, routineStore: RoutineStore) {
        self.authStore = authStore

        // 루틴 기반 표시값 세팅
        self.title = routine.title
        self.subtitle = !routine.goal.isEmpty ? routine.goal : (routine.note ?? "")
        self.plantImageName = routine.seedName ?? "seed_Sunflower03" // 기본 이미지로 대체
        self.progress = routineStore.progress(for: routine) / 100.0 // 0~100 → 0~1

        // mate 이미지 동기화
        authStore.$mate
            .map { $0 ?? "MrPurr" }
            .removeDuplicates()
            .receive(on: RunLoop.main)
            .assign(to: \.mateImageName, on: self)
            .store(in: &cancellables)
    }

    private var cancellables = Set<AnyCancellable>()

    var progressPercentText: String {
        "\(Int(progress * 100))%"
    }
}
