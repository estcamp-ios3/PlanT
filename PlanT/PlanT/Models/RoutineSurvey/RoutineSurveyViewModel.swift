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
    
    // 1) 단계 정의 (디자인 문서 기반)
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

    // 2) 진행 상태
    @Published private(set) var currentIndex: Int = 0
    @Published private var selections: [String: Set<String>] = [:] // stepID -> optionIDs

    var currentStep: SurveyStep { steps[currentIndex] }

    // 3) 선택/검증/이동
    func isSelected(_ option: Option) -> Bool {
        selections[currentStep.id, default: []].contains(option.id)
    }

    func toggle(_ option: Option) {
        var set = selections[currentStep.id, default: []]
        
        if set.contains(option.id) {
            set.remove(option.id)
        } else {
            // 단일 선택이면 기존 모두 해제
            if currentStep.maxSelection == 1 { set.removeAll() }
            // 최대 선택 수 제한
            if let max = currentStep.maxSelection, set.count >= max { return }
            set.insert(option.id)
        }
        objectWillChange.send()
        selections[currentStep.id] = set
        
    }

    var canGoNext: Bool {
        switch currentStep.kind {
        case .summary: return true
        default:
            let count = selections[currentStep.id, default: []].count
            return count >= currentStep.minSelection
        }
    }

    var isFirst: Bool { currentIndex == 0 }
    var isLast:  Bool { currentIndex == steps.count - 1 }

    func next() {
        guard canGoNext else { return }
        if !isLast { currentIndex += 1 }
    }
    func back() {
        if !isFirst { currentIndex -= 1 }
    }

    // 4) 요약 텍스트 생성
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

