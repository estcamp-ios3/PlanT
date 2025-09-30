//
//  MypageUserCardViewModel.swift
//  PlanT
//
//  Created by 이지훈 on 9/30/25.
//

import Foundation
import Combine

final class MypageUserCardViewModel: ObservableObject {
    @Published var model: MypageUserCardModel
    var onTapSettings: (() -> Void)?

    init(model: MypageUserCardModel, onTapSettings: (() -> Void)? = nil) {
        self.model = model
        self.onTapSettings = onTapSettings
    }
}
