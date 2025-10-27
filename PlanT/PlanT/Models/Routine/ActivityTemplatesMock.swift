//
//  ActivityTemplatesMock.swift
//  PlanT
//
//  Created by catharina J on 10/13/25.
//

import Foundation

enum CategorySlug: String { case knowledge, career, body, mind, social, finance }

enum ActivityTemplatesMock {
    static let byCategory: [CategorySlug: [Option]] = [
        .knowledge: [
            .init(id: "reading", title: "독서", icon: "book.closed"),
            .init(id: "writing", title: "글쓰기", icon: "pencil"),
            .init(id: "language_study", title: "외국어 학습", icon: "character.book.closed"),
            .init(id: "certificate", title: "자격증 공부", icon: "checkmark.square"),
            .init(id: "mooc", title: "온라인 강의", icon: "video"),
        ],
        .career: [
            .init(id: "programming", title: "프로그래밍 학습", icon: "chevron.left.slash.chevron.right"),
            .init(id: "data_analysis", title: "데이터 분석", icon: "chart.bar.doc.horizontal"),
            .init(id: "app_dev", title: "앱 개발", icon: "iphone"),
            .init(id: "presentation", title: "발표력 훈련", icon: "mic"),
            .init(id: "leadership", title: "리더십 훈련", icon: "person.2.wave.2"),
            .init(id: "creative_design", title: "디자인·영상편집", icon: "paintpalette"),
        ],
        .body: [
            .init(id: "gym", title: "헬스", icon: "dumbbell"),
            .init(id: "yoga", title: "요가", icon: "figure.cooldown"),
            .init(id: "running", title: "러닝", icon: "figure.run"),
            .init(id: "drink_water", title: "물 마시기", icon: "drop.fill"),
            .init(id: "water", title: "수분 보충/관리", icon: "fork.knife"),
            .init(id: "meditation", title: "명상", icon: "leaf"), // lotus 대체
        ],
        .mind: [
            .init(id: "psychology_study", title: "심리학 공부", icon: "book.closed"),
            .init(id: "journaling", title: "저널링", icon: "note.text"), // notebook 대체
            .init(id: "mindfulness", title: "마인드풀니스", icon: "circle.dashed"),
            .init(id: "emotion_control", title: "감정 조절", icon: "heart.text.square"),
            .init(id: "gratitude", title: "감사 실천", icon: "heart"),
        ],
        .social: [
            .init(id: "speech_training", title: "스피치 훈련", icon: "megaphone"),
            .init(id: "conversation_skill", title: "대화 연습", icon: "bubble.left.and.bubble.right"),
            .init(id: "negotiation", title: "협상 연습", icon: "hands.clap"),
            .init(id: "networking", title: "네트워킹", icon: "person.3.sequence"),
            .init(id: "volunteering", title: "봉사 활동", icon: "hands.sparkles"),
        ],
        .finance: []
    ]
}
