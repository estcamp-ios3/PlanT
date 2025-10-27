//
//  RoutineTemplate.swift
//  PlanT
//
//  Created by 박성관 on 10/9/25.
//

import Foundation
import SwiftUI

// MARK: - 루틴 카테고리 모델
struct RoutineCategory: Identifiable {
    let id = UUID()
    let categoryId: String
    let categoryTitle: String
    let symbolName: String
    let routines: [Routine]
}

// MARK: - 카테고리별 기본 주기 설정
private struct FrequencyPreset {
    static let growth = ("5x", "주 5회")
    static let skill = ("4x", "주 4회")
    static let health = ("3x", "주 3회")
    static let mind = ("7x", "매일")
    static let social = ("2x", "주 2회")
    static let finance = ("1x", "주 1회")
}

// MARK: - 템플릿 정의
let routineTemplates: [RoutineCategory] = [

    // ✅ 1. 지적 / 성장
    RoutineCategory(
        categoryId: "category01",
        categoryTitle: "지적 / 성장",
        symbolName: "lightbulb.fill",
        routines: [
            Routine(title: "독서",
                    categoryId: "category01",
                    duration: "21일",
                    goal: "30분/일",
                    alarm: .every24Hours,
                    frequencyPerWeekId: FrequencyPreset.growth.0,
                    frequencyPerWeekTitle: FrequencyPreset.growth.1),
            Routine(title: "글쓰기",
                    categoryId: "category01",
                    duration: "21일",
                    goal: "20분/일",
                    alarm: .every24Hours,
                    frequencyPerWeekId: FrequencyPreset.growth.0,
                    frequencyPerWeekTitle: FrequencyPreset.growth.1),
            Routine(title: "외국어 학습",
                    categoryId: "category01",
                    duration: "21일",
                    goal: "30분/일",
                    alarm: .every24Hours,
                    frequencyPerWeekId: FrequencyPreset.growth.0,
                    frequencyPerWeekTitle: FrequencyPreset.growth.1),
            Routine(title: "자격증 공부",
                    categoryId: "category01",
                    duration: "21일",
                    goal: "40분/일",
                    alarm: .every24Hours,
                    frequencyPerWeekId: FrequencyPreset.growth.0,
                    frequencyPerWeekTitle: FrequencyPreset.growth.1),
            Routine(title: "온라인 강의 수강",
                    categoryId: "category01",
                    duration: "21일",
                    goal: "1시간/일",
                    alarm: .every24Hours,
                    frequencyPerWeekId: FrequencyPreset.growth.0,
                    frequencyPerWeekTitle: FrequencyPreset.growth.1)
        ]
    ),

    // ✅ 2. 전문 / 역량
    RoutineCategory(
        categoryId: "category02",
        categoryTitle: "전문 / 역량",
        symbolName: "laptopcomputer",
        routines: [
            Routine(title: "프로그래밍 학습",
                    categoryId: "category02",
                    duration: "21일",
                    goal: "1시간/일",
                    alarm: .every24Hours,
                    frequencyPerWeekId: FrequencyPreset.skill.0,
                    frequencyPerWeekTitle: FrequencyPreset.skill.1),
            Routine(title: "데이터 분석",
                    categoryId: "category02",
                    duration: "21일",
                    goal: "1시간/일",
                    alarm: .every48Hours,
                    frequencyPerWeekId: FrequencyPreset.skill.0,
                    frequencyPerWeekTitle: FrequencyPreset.skill.1),
            Routine(title: "앱 개발",
                    categoryId: "category02",
                    duration: "21일",
                    goal: "2시간/일",
                    alarm: .every24Hours,
                    frequencyPerWeekId: FrequencyPreset.skill.0,
                    frequencyPerWeekTitle: FrequencyPreset.skill.1),
            Routine(title: "리더십 훈련",
                    categoryId: "category02",
                    duration: "21일",
                    goal: "30분/일",
                    alarm: .every24Hours,
                    frequencyPerWeekId: FrequencyPreset.skill.0,
                    frequencyPerWeekTitle: FrequencyPreset.skill.1),
            Routine(title: "디자인.영상편집",
                    categoryId: "category02",
                    duration: "21일",
                    goal: "1시간/일",
                    alarm: .every24Hours,
                    frequencyPerWeekId: FrequencyPreset.skill.0,
                    frequencyPerWeekTitle: FrequencyPreset.skill.1)
        ]
    ),

    // ✅ 3. 신체 / 건강
    RoutineCategory(
        categoryId: "category03",
        categoryTitle: "신체 / 건강",
        symbolName: "heart.fill",
        routines: [
            Routine(title: "헬스",
                    categoryId: "category03",
                    duration: "21일",
                    goal: "1시간/주",
                    alarm: .every24Hours,
                    frequencyPerWeekId: FrequencyPreset.health.0,
                    frequencyPerWeekTitle: FrequencyPreset.health.1),
            Routine(title: "요가",
                    categoryId: "category03",
                    duration: "21일",
                    goal: "1시간/주",
                    alarm: .every24Hours,
                    frequencyPerWeekId: FrequencyPreset.health.0,
                    frequencyPerWeekTitle: FrequencyPreset.health.1),
            Routine(title: "러닝",
                    categoryId: "category03",
                    duration: "21일",
                    goal: "1시간/주",
                    alarm: .every24Hours,
                    frequencyPerWeekId: FrequencyPreset.health.0,
                    frequencyPerWeekTitle: FrequencyPreset.health.1),
            Routine(title: "물마시기",
                    categoryId: "category03",
                    duration: "21일",
                    goal: "1시간/주",
                    alarm: .every24Hours,
                    frequencyPerWeekId: FrequencyPreset.health.0,
                    frequencyPerWeekTitle: FrequencyPreset.health.1),
            Routine(title: "명상",
                    categoryId: "category03",
                    duration: "21일",
                    goal: "1시간/주",
                    alarm: .every24Hours,
                    frequencyPerWeekId: FrequencyPreset.health.0,
                    frequencyPerWeekTitle: FrequencyPreset.health.1)
        ]
    ),

    // ✅ 4. 정서 / 마음
    RoutineCategory(
        categoryId: "category04",
        categoryTitle: "정서 / 마음",
        symbolName: "hands.sparkles.fill",
        routines: [
            Routine(title: "심리학 공부",
                    categoryId: "category04",
                    duration: "21일",
                    goal: "30분/일",
                    alarm: .every24Hours,
                    frequencyPerWeekId: FrequencyPreset.mind.0,
                    frequencyPerWeekTitle: FrequencyPreset.mind.1),
            Routine(title: "저널링",
                    categoryId: "category04",
                    duration: "21일",
                    goal: "15분/일",
                    alarm: .every24Hours,
                    frequencyPerWeekId: FrequencyPreset.mind.0,
                    frequencyPerWeekTitle: FrequencyPreset.mind.1),
            Routine(title: "마인드풀니스",
                    categoryId: "category04",
                    duration: "21일",
                    goal: "10분/일",
                    alarm: .every24Hours,
                    frequencyPerWeekId: FrequencyPreset.mind.0,
                    frequencyPerWeekTitle: FrequencyPreset.mind.1),
            Routine(title: "감정 조절",
                    categoryId: "category04",
                    duration: "21일",
                    goal: "10분/일",
                    alarm: .every24Hours,
                    frequencyPerWeekId: FrequencyPreset.mind.0,
                    frequencyPerWeekTitle: FrequencyPreset.mind.1),
            Routine(title: "감사 실천",
                    categoryId: "category04",
                    duration: "21일",
                    goal: "3번/일",
                    alarm: .every24Hours,
                    frequencyPerWeekId: FrequencyPreset.mind.0,
                    frequencyPerWeekTitle: FrequencyPreset.mind.1)
        ]
    ),

    // ✅ 5. 대인관계 / 커뮤니케이션
    RoutineCategory(
        categoryId: "category05",
        categoryTitle: "대인관계 / 커뮤니케이션",
        symbolName: "person.2.fill",
        routines: [
            Routine(title: "스피치 훈련",
                    categoryId: "category05",
                    duration: "35일",
                    goal: "20분/일",
                    alarm: .every24Hours,
                    frequencyPerWeekId: FrequencyPreset.social.0,
                    frequencyPerWeekTitle: FrequencyPreset.social.1),
            Routine(title: "대화 연습",
                    categoryId: "category05",
                    duration: "35일",
                    goal: "15분/일",
                    alarm: .every24Hours,
                    frequencyPerWeekId: FrequencyPreset.social.0,
                    frequencyPerWeekTitle: FrequencyPreset.social.1),
            Routine(title: "협상 연습",
                    categoryId: "category05",
                    duration: "35일",
                    goal: "30분/일",
                    alarm: .every24Hours,
                    frequencyPerWeekId: FrequencyPreset.social.0,
                    frequencyPerWeekTitle: FrequencyPreset.social.1),
            Routine(title: "네트워킹",
                    categoryId: "category05",
                    duration: "35일",
                    goal: "1시간/주",
                    alarm: .every24Hours,
                    frequencyPerWeekId: FrequencyPreset.social.0,
                    frequencyPerWeekTitle: FrequencyPreset.social.1),
            Routine(title: "봉사 활동",
                    categoryId: "category05",
                    duration: "35일",
                    goal: "1시간/주",
                    alarm: .every24Hours,
                    frequencyPerWeekId: FrequencyPreset.social.0,
                    frequencyPerWeekTitle: FrequencyPreset.social.1)
        ]
    ),

    // ✅ 6. 재정 / 삶의 관리
    RoutineCategory(
        categoryId: "category06",
        categoryTitle: "재정 / 삶의 관리",
        symbolName: "chart.bar.fill",
        routines: [
            Routine(title: "가계부 작성",
                    categoryId: "category06",
                    duration: "21일",
                    goal: "15분/주",
                    alarm: .every24Hours,
                    frequencyPerWeekId: FrequencyPreset.finance.0,
                    frequencyPerWeekTitle: FrequencyPreset.finance.1),
            Routine(title: "투자 공부",
                    categoryId: "category06",
                    duration: "21일",
                    goal: "30분/주",
                    alarm: .every24Hours,
                    frequencyPerWeekId: FrequencyPreset.finance.0,
                    frequencyPerWeekTitle: FrequencyPreset.finance.1),
            Routine(title: "시간 관리",
                    categoryId: "category06",
                    duration: "21일",
                    goal: "15분/주",
                    alarm: .every24Hours,
                    frequencyPerWeekId: FrequencyPreset.finance.0,
                    frequencyPerWeekTitle: FrequencyPreset.finance.1),
            Routine(title: "정리정돈",
                    categoryId: "category06",
                    duration: "21일",
                    goal: "20분/주",
                    alarm: .every24Hours,
                    frequencyPerWeekId: FrequencyPreset.finance.0,
                    frequencyPerWeekTitle: FrequencyPreset.finance.1),
            Routine(title: "비전보드 만들기",
                    categoryId: "category06",
                    duration: "21일",
                    goal: "1시간/주",
                    alarm: .every24Hours,
                    frequencyPerWeekId: FrequencyPreset.finance.0,
                    frequencyPerWeekTitle: FrequencyPreset.finance.1)
        ]
    )
]

