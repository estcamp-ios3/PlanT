//
//  MyPageUserCardViewModel.swift
//  PlanT
//
//  Created by 이지훈 on 9/30/25.
//

import Foundation
import Combine

@MainActor
final class MypageUserCardViewModel: ObservableObject {
    @Published var model: MypageUserCardModel
    @Published var isShowingSetting = false  // 화면 전환 ViewModel에서 관리

    private let authStore: AuthStore
    private var cancellables = Set<AnyCancellable>()

    init(authStore: AuthStore) {
        self.authStore = authStore

        self.model = MypageUserCardModel(
            mateName: authStore.mate ?? "MrPurr",
            nickName: "닉네임: \(authStore.nickName ?? "불러오는 중...")",
            growingCount: 12,
            harvestedCount: 1032,
            points: 1200
        )

        bindAuthStore()
    }

    private func bindAuthStore() {
        authStore.$nickName
            .combineLatest(authStore.$mate)
            .sink { [weak self] nick, mate in
                guard let self = self else { return }
                self.model.mateName = mate ?? "MrPurr"
                self.model.nickName = "닉네임: \(nick ?? "불러오는 중...")"
            }
            .store(in: &cancellables)
    }

    func tapSettings() {
        isShowingSetting = true
    }
}
