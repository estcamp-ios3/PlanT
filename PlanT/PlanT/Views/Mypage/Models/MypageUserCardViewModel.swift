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
    @Published var isShowingSetting = false

    private let authStore: AuthStore
    private var cancellables = Set<AnyCancellable>()

    init(authStore: AuthStore) {
        self.authStore = authStore

        // 초기 모델 상태 설정
        self.model = MypageUserCardModel(
            mateName: authStore.mate ?? "MrPurr",
            nickName: "닉네임: \(authStore.nickName ?? "불러오는 중...")",
            growingCount: 12,
            harvestedCount: 1032,
            points: 1200
        )

        bindAuthStore()
    }

    /// ✅ AuthStore의 상태를 구독해 model을 자동 갱신
    private func bindAuthStore() {
        authStore.$nickName
            .combineLatest(authStore.$mate)
            .map { nick, mate in
                var updatedModel = self.model
                updatedModel.mateName = mate ?? "MrPurr"
                updatedModel.nickName = "닉네임: \(nick ?? "불러오는 중...")"
                return updatedModel
            }
            .assign(to: &$model)
    }

    /// ✅ 설정 버튼 탭 시 화면 이동 트리거
    func tapSettings() {
        isShowingSetting = true
    }
}
