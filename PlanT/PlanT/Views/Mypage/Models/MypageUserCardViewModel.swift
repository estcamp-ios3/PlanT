//
//  MypageUserCardViewModel.swift
//  PlanT
//
//  Created by 이지훈 on 9/30/25.
//

import Foundation
import Combine

@MainActor
final class MypageUserCardViewModel: ObservableObject {
    @Published var model: MypageUserCardModel
    private var cancellables = Set<AnyCancellable>()

    private let authStore: AuthStore
    var onTapSettings: (() -> Void)?

    init(authStore: AuthStore, onTapSettings: (() -> Void)? = nil) {
        self.authStore = authStore
        self.onTapSettings = onTapSettings

        // 초기값
        self.model = MypageUserCardModel(
            mateName: authStore.mate ?? "MrPurr",
            nickName: "닉네임: \(authStore.nickName ?? "불러오는 중...")",
            growingCount: 12,
            harvestedCount: 1032,
            points: 1200
        )

        bindAuthStore()
    }

    /// AuthStore의 상태 변화 감지
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
}
