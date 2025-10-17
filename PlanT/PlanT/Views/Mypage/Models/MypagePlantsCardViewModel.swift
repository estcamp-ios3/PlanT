//
//  MypagePlantsCardViewModel.swift
//  PlanT
//
//  Created by 이지훈 on 10/17/25.
//

import Foundation
import Combine

final class MypagePlantsCardViewModel: ObservableObject {

    // 표시용 상태
    @Published var sectionTitle: String = "성장중인 작물"
    @Published var title: String = "러닝 루틴(할 일 제목)"
    @Published var subtitle: String = "설정한 목표: 확신의 P가 한땀한땀 쌓아나가는 목표"
    @Published var progress: Double = 0.6                  // 0.0 ~ 1.0
    @Published var plantImageName: String = "seed_Sunflower03"
    @Published var mateComment: String = "거의 다왔어요! 앞으로 2회만 더 힘내라골골!"

    // AuthStore로부터 유도되는 값
    @Published private(set) var mateImageName: String = "MrPurr"

    private let authStore: AuthStore
    private var cancellables = Set<AnyCancellable>()

    init(authStore: AuthStore) {
        self.authStore = authStore

        // AuthStore가 ObservableObject이고 @Published var mate: String? 라고 가정
        authStore.$mate
            .map { $0 ?? "MrPurr" }
            .removeDuplicates()
            .receive(on: RunLoop.main)
            .assign(to: \.mateImageName, on: self)
            .store(in: &cancellables)
    }

    // 가공 값
    var progressPercentText: String {
        "\(Int(progress * 100))%"
    }
}
