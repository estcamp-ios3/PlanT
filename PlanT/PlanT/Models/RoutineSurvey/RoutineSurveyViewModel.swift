//
//  RoutineSurveyViewModel.swift
//  PlanT
//
//  Created by catharina J on 9/30/25.
//

import Foundation
import Combine

@MainActor
final class RoutineSurveyViewModel: ObservableObject {
    
    var categoryTitles: [String] {
        guard let categoryStep = steps.first(where: { $0.id == "category" }) else {
            return []
        }
        return categoryStep.options.map { $0.title }
    }
    // 설문 단계 정의: 각 화면에서 보여줄 질문/옵션/선택 제한 등을 순서대로 나열합니다.
    @Published private(set) var steps: [SurveyStep] = [
        .init(id: "category", kind: .categoryGrid,
              title: "루틴 카테고리를 선택해 주세요",
              message: nil,
              options: [
                .init(id: "category01", title: "대인관계/커뮤니케이션", thumb: "categories_01"),
                .init(id: "category02", title: "지적/성장", thumb: "categories_02"),
                .init(id: "category03", title: "정서/마음", thumb: "categories_03"),
                .init(id: "category04", title: "전문 역량", thumb: "categories_04"),
                .init(id: "category05", title: "재정/삶의 관리", thumb: "categories_05"),
                .init(id: "category06", title: "신체/건강", thumb: "categories_06")
              ],
              minSelection: 1, maxSelection: 1),

        .init(id: "health_type", kind: .single,
              title: "어떤 루틴을 시작할까요?",
              message: "신체, 건강(들)을 선택하셨어요!",
              options: [
                .init(id: "walk",  title: "걷기"),
                .init(id: "yoga",  title: "요가"),
                .init(id: "gym",   title: "근력운동"),
                .init(id: "water", title: "물 마시기")
              ],
              minSelection: 1, maxSelection: 1),

        .init(id: "frequency_per_week", kind: .single,
              title: "1주에 몇 회 정도 진행할까요?",
              message: nil,
              options: (1...7).map { .init(id: "\($0)x", title: "주 \($0)회") },
              minSelection: 1, maxSelection: 1),

        .init(id: "duration", kind: .single,
              title: "한 번 할 때 몇 분 할까요?",
              message: nil,
              options: ["10분","20분","30분","40분"].map { .init(id: $0, title: $0) },
              minSelection: 1, maxSelection: 1),

        .init(id: "set_period", kind: .confirm,
              title: "기간 없이 진행할까요?",
              message: "나중에 언제든 변경할 수 있어요.",
              options: [.init(id: "yes", title: "예"), .init(id: "no", title: "아니요")],
              minSelection: 1, maxSelection: 1),

        .init(id: "set_reminder", kind: .confirm,
              title: "알림을 설정하시겠습니까?",
              message: nil,
              options: [.init(id: "yes", title: "예"), .init(id: "no", title: "아니요")],
              minSelection: 1, maxSelection: 1),

        .init(id: "summary", kind: .summary,
              title: "요약을 확인하고 생성할까요?",
              message: nil,
              options: [], minSelection: 0, maxSelection: nil)
    ]

    // 현재 진행 중인 단계의 인덱스 (0부터 시작)
    @Published private(set) var currentIndex: Int = 0
    // 사용자가 선택한 값들을 저장하는 딕셔너리 (stepID -> 선택된 optionID들의 집합)
    @Published private var selections: [String: Set<String>] = [:] // stepID -> optionIDs

    // 현재 단계에 해당하는 SurveyStep 반환 (UI에서 참조)
    var currentStep: SurveyStep { steps[currentIndex] }

    // 현재 단계에서 특정 옵션이 선택되어 있는지 여부
    func isSelected(_ option: Option) -> Bool {
        selections[currentStep.id, default: []].contains(option.id)
    }

    func toggle(_ option: Option) {
        var set = selections[currentStep.id, default: []]
        
        if set.contains(option.id) {
            // 이미 선택된 옵션이면 해제
            set.remove(option.id)
        } else {
            // 단일 선택 단계인 경우, 기존 선택을 모두 해제하고 새 선택만 유지
            if currentStep.maxSelection == 1 { set.removeAll() }
            // 최대 선택 수를 초과하지 않도록 방지
            if let max = currentStep.maxSelection, set.count >= max { return }
            // 새 옵션 추가
            set.insert(option.id)
        }
        // 수동으로 변경 알림 발생 (뷰 갱신 유도)
        objectWillChange.send()
        // 선택 결과 저장
        selections[currentStep.id] = set
        
    }

    // 다음 단계로 진행 가능한지 검증 (요약 단계는 항상 가능)
    var canGoNext: Bool {
        switch currentStep.kind {
        case .summary: return true
        default:
            let count = selections[currentStep.id, default: []].count
            return count >= currentStep.minSelection
        }
    }

    // 첫 단계/마지막 단계 여부 편의 프로퍼티
    var isFirst: Bool { currentIndex == 0 }
    var isLast:  Bool { currentIndex == steps.count - 1 }

    // 다음 단계로 이동 (검증 통과 시에만)
    func next() {
        guard canGoNext else { return }
        if !isLast { currentIndex += 1 }
    }
    // 이전 단계로 이동
    func back() {
        if !isFirst { currentIndex -= 1 }
    }

    // 사용자가 선택한 값을 요약 텍스트로 구성하여 표시
    var summaryText: String {
        func pick(_ id: String) -> String? { selections[id]?.first }
        let cat  = pick("category") ?? "-"
        let type = pick("health_type") ?? "-"
        let freq = pick("frequency_per_week") ?? "-"
        let dur  = pick("duration") ?? "-"
        let per  = pick("set_period") == "yes" ? "기간 없음" : "기간 설정"
        let rem  = pick("set_reminder") == "yes" ? "알림 ON" : "알림 OFF"
        return "카테고리: \(cat)\n루틴: \(type)\n빈도: \(freq)\n시간: \(dur)\n기간: \(per)\n알림: \(rem)"
    }
}

// MARK: - 설문 결과를 RoutineDraft(루틴 초안)로 변환하여 다음 화면에 전달
extension RoutineSurveyViewModel {
    // Draft built from current selections for navigation to SeedStatusView
    var draft: RoutineDraft {
        // 선택된 optionId를 가져오는 헬퍼 (없으면 "-")
        func pick(_ id: String) -> String { selections[id]?.first ?? "-" }
        // optionId를 사람이 읽기 쉬운 title로 바꾸는 헬퍼
        func title(for stepId: String, optionId: String) -> String {
            guard let step = steps.first(where: { $0.id == stepId }),
                  let opt = step.options.first(where: { $0.id == optionId }) else { return optionId }
            return opt.title
        }
        // 각 단계에서 선택된 값 추출
        let categoryId = pick("category")
        let routineTypeId = pick("health_type")
        let frequencyId = pick("frequency_per_week")
        let durationId = pick("duration")
        let periodYes = pick("set_period") == "yes"
        let reminderYes = pick("set_reminder") == "yes"

        // 초안(RoutineDraft) 구성: id와 title을 함께 보관해 다음 화면에서 유연하게 사용
        return RoutineDraft(
            categoryId: categoryId,
            categoryTitle: title(for: "category", optionId: categoryId),
            routineTypeId: routineTypeId,
            routineTypeTitle: title(for: "health_type", optionId: routineTypeId),
            frequencyPerWeekId: frequencyId,
            frequencyPerWeekTitle: title(for: "frequency_per_week", optionId: frequencyId),
            durationId: durationId,
            durationTitle: title(for: "duration", optionId: durationId),
            periodIsNoLimit: periodYes,
            reminderOn: reminderYes
        )
    }
}
