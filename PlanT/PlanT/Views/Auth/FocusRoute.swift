//
//  FocusRoute.swift
//  PlanT
//
//  Created by 이지훈 on 10/2/25.
//

// 어디에 넣어야 할지 몰라서 일단 임시로 여기에 넣어둠

import SwiftUI

extension View {
    /// TextField / SecureField 포커스 연결 + Return 동작 체인 헬퍼
    /// - Parameters:
    ///   - focus: @FocusState 바인딩
    ///   - field: 현재 필드 식별자
    ///   - submit: 키보드 리턴 키 모양(.next, .done, .go 등)
    ///   - next: 다음으로 이동할 필드 (nil이면 키보드 닫힘)
    func focusRoute<F: Hashable>(
        _ focus: FocusState<F?>.Binding,
        equals field: F,
        submit: SubmitLabel = .next,
        next: F?
    ) -> some View {
        self
            .focused(focus, equals: field)
            .submitLabel(submit)
            .onSubmit { focus.wrappedValue = next }
    }
}
