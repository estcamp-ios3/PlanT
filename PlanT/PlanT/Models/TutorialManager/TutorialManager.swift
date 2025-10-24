//
//  TutorialManager.swift
//  PlanT
//
//  Created by 박성관 on 10/23/25.
//

import SwiftUI
import Combine

/// 튜토리얼 한 단계
struct PlanTTutorialStep: Identifiable {
    let id: String          // 대상 앵커 id
    let message: String     // 설명 문구
    let showNextButton: Bool  // “다음” 버튼 표시 여부
    let verticalOffset: CGFloat
    let horizontalOffset: CGFloat
    
    init(id: String,
         message: String,
         showNextButton: Bool,
         verticalOffset: CGFloat = 0,
         horizontalOffset: CGFloat = 0) {
        self.id = id
        self.message = message
        self.showNextButton = showNextButton
        self.verticalOffset = verticalOffset
        self.horizontalOffset = horizontalOffset
    }
}

/// 튜토리얼 전체 상태 관리
final class TutorialManager: ObservableObject {
    @Published var isActive = false
    @Published var currentIndex = 0
    var steps: [PlanTTutorialStep] = []
    
    private let tutorialKey = "hasShownTutorial"

    // ✅ 튜토리얼 완료 여부 확인
    var hasShownTutorial: Bool {
        UserDefaults.standard.bool(forKey: tutorialKey)
    }

    // ✅ 완료 표시 저장
    func markTutorialAsShown() {
        UserDefaults.standard.set(true, forKey: tutorialKey)
    }

    // ✅ 튜토리얼 시작
    func start(steps: [PlanTTutorialStep]) {
        self.steps = steps
        currentIndex = 0
        isActive = true
    }

    // ✅ 다음 단계로 이동
    func next() {
        guard isActive else { return }
        if currentIndex + 1 < steps.count {
            currentIndex += 1
        } else {
            finish()
        }
    }

    // ✅ 튜토리얼 종료 및 기록
    func finish() {
        isActive = false
        markTutorialAsShown()
    }

    var currentStep: PlanTTutorialStep? {
        guard isActive, steps.indices.contains(currentIndex) else { return nil }
        return steps[currentIndex]
    }
}

/// 앵커 수집용 PreferenceKey
struct TutorialAnchorKey: PreferenceKey {
    static var defaultValue: [String: CGRect] = [:]
    static func reduce(value: inout [String: CGRect], nextValue: () -> [String: CGRect]) {
        value.merge(nextValue(), uniquingKeysWith: { $1 })
    }
}

/// 특정 뷰를 튜토리얼 앵커로 등록
extension View {
    func tutorialAnchor(_ id: String) -> some View {
        self.background(
            GeometryReader { geo in
                Color.clear
                    .preference(
                        key: TutorialAnchorKey.self,
                        value: [id: geo.frame(in: .named("tutorialSpace"))]
                    )
            }
        )
    }
}
