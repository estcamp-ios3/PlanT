//
//  RoutineTemplate.swift
//  PlanT
//
//  Created by 박성관 on 10/9/25.
//
import Foundation
import SwiftUI

// MARK: - 루틴 카테고리 모델
// 루틴들을 카테고리별로 그룹화
struct RoutineCategory: Identifiable {
    let id = UUID()               // 카테고리 고유 식별자
    let categoryId: String
    let categoryTitle: String
    let emoji: String             // 카테고리 이모지 아이콘
    let routines: [Routine]       // 카테고리에 포함된 루틴 리스트
}


let routineTemplates: [RoutineCategory] = [
    RoutineCategory(
        categoryId:  "category02",
        categoryTitle: "지적/성장",
        emoji: "🌱",
        routines: [
            Routine(
                title: "독서",
                detail: RoutineDetail(duration: "3일", goal: "5page/일", alarm: .every24Hours), categoryId: "category02"
            ),
            Routine(
                title: "새로운 언어 학습",
                detail: RoutineDetail(duration: "3일", goal: "10단어/일", alarm: .every24Hours), categoryId: "category02"
            )
        ]
    ),
    RoutineCategory(
        categoryId:  "category04",
        categoryTitle: "전문/역량",
        emoji: "💻",
        routines: [
            Routine(
                title: "프로그래밍",
                detail: RoutineDetail(duration: "4주", goal: "6시간/일", alarm: .every24Hours), categoryId: "category04"
            ),
            Routine(
                title: "디자인/영상 편집",
                detail: RoutineDetail(duration: "1주", goal: "4시간/일", alarm: .every48Hours), categoryId: "category04"
            )
        ]
    ),
    RoutineCategory(
        categoryId:  "category06",
        categoryTitle: "신체/건강",
        emoji: "💪",
        routines: [
            Routine(
                title: "물 마시기",
                detail: RoutineDetail(duration: "매일", goal: "1.5L", alarm: .every24Hours), categoryId: "category06"
            )
        ]
    )
]
