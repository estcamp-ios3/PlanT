//
//  RoutineTemplate.swift
//  PlanT
//
//  Created by 박성관 on 10/9/25.
//

<<<<<<< HEAD
=======
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
        categoryId:  "category01",
        categoryTitle: "대인관계/ 커뮤니케이션",
        emoji: "👥",
        routines: [
            Routine(
                title: "스피치 훈련",
                detail: RoutineDetail(duration: "5주", goal: "20분/일", alarm: .every24Hours), categoryId: "category01"
            ),
            Routine(
                title: "대화 연습",
                detail: RoutineDetail(duration: "5주", goal: "15분/일", alarm: .every24Hours), categoryId: "category01"
            ),
            Routine(
                title: "협상 연습",
                detail: RoutineDetail(duration: "5주", goal: "30분/일", alarm: .every24Hours), categoryId: "category01"
            ),
            Routine(
                title: "네트워킹",
                detail: RoutineDetail(duration: "5주", goal: "1시간/주", alarm: .every24Hours), categoryId: "category01"
            ),
            Routine(
                title: "봉사 활동",
                detail: RoutineDetail(duration: "5주", goal: "1시간/주", alarm: .every24Hours), categoryId: "category01"
            ),
        ]
    ),
    
    RoutineCategory(
        categoryId:  "category02",
        categoryTitle: "지적/ 성장",
        emoji: "🌱",
        routines: [
            Routine(
                title: "독서",
                detail: RoutineDetail(duration: "21일", goal: "30분/일", alarm: .every24Hours), categoryId: "category02"
            ),
            Routine(
                title: "글쓰기",
                detail: RoutineDetail(duration: "21일", goal: "20분/일", alarm: .every24Hours), categoryId: "category02"
            ),
            Routine(
                title: "외국어 학습",
                detail: RoutineDetail(duration: "21일", goal: "30분/일", alarm: .every24Hours), categoryId: "category02"
            ),
            Routine(
                title: "자격증 공부",
                detail: RoutineDetail(duration: "21일", goal: "40분/일", alarm: .every24Hours), categoryId: "category02"
            ),
            Routine(
                title: "온라인 강의 수강",
                detail: RoutineDetail(duration: "21일", goal: "1시간/일", alarm: .every24Hours), categoryId: "category02"
            ),
        ]
    ),
    RoutineCategory(
        categoryId:  "category03",
        categoryTitle: "정서/ 마음",
        emoji: "🧘",
        routines: [
            Routine(
                title: "심리학 공부",
                detail: RoutineDetail(duration: "3주", goal: "30분/일", alarm: .every24Hours), categoryId: "category03"
            ),
            Routine(
                title: "저널링",
                detail: RoutineDetail(duration: "3주", goal: "15분/일", alarm: .every24Hours), categoryId: "category03"
            ),
            Routine(
                title: "마인드풀니스",
                detail: RoutineDetail(duration: "3주", goal: "10분/일", alarm: .every24Hours), categoryId: "category03"
            ),
            Routine(
                title: "감정 조절",
                detail: RoutineDetail(duration: "3주", goal: "10분/일", alarm: .every24Hours), categoryId: "category03"
            ),
            Routine(
                title: "감사 실천",
                detail: RoutineDetail(duration: "3주", goal: "3번/일", alarm: .every24Hours), categoryId: "category03"
            ),
        ]
    ),
    RoutineCategory(
        categoryId:  "category04",
        categoryTitle: "전문/ 역량",
        emoji: "💻",
        routines: [
            Routine(
                title: "프로그래밍 학습",
                detail: RoutineDetail(duration: "3주", goal: "1시간/일", alarm: .every24Hours), categoryId: "category04"
            ),
            Routine(
                title: "데이터 분석",
                detail: RoutineDetail(duration: "3주", goal: "1시간/일", alarm: .every48Hours), categoryId: "category04"
            ),
            Routine(
                title: "앱 개발",
                detail: RoutineDetail(duration: "3주", goal: "2시간/일", alarm: .every24Hours), categoryId: "category04"
            ),
            Routine(
                title: "리더십 훈련",
                detail: RoutineDetail(duration: "3주", goal: "30분/일", alarm: .every24Hours), categoryId: "category04"
            ),
            Routine(
                title: "디자인.영상편집",
                detail: RoutineDetail(duration: "3주", goal: "1시간/일", alarm: .every24Hours), categoryId: "category04"
            ),
        ]
    ),
    RoutineCategory(
        categoryId:  "category05",
        categoryTitle: "재정/ 삶의 관리",
        emoji: "📊",
        routines: [
            Routine(
                title: "가계부 작성",
                detail: RoutineDetail(duration: "3주", goal: "15분/주", alarm: .every24Hours), categoryId: "category05"
            ),
            Routine(
                title: "투자 공부",
                detail: RoutineDetail(duration: "3주", goal: "30분/주", alarm: .every24Hours), categoryId: "category05"
            ),
            Routine(
                title: "시간 관리",
                detail: RoutineDetail(duration: "3주", goal: "15분/주", alarm: .every24Hours), categoryId: "category05"
            ),
            Routine(
                title: "정리정돈",
                detail: RoutineDetail(duration: "3주", goal: "20분/주", alarm: .every24Hours), categoryId: "category05"
            ),
            Routine(
                title: "비전보드 만들기",
                detail: RoutineDetail(duration: "3주", goal: "1시간/주", alarm: .every24Hours), categoryId: "category05"
            ),
        ]
    ),
    RoutineCategory(
        categoryId:  "category06",
        categoryTitle: "신체/건강",
        emoji: "💪",
        routines: [
            Routine(
                title: "헬스",
                detail: RoutineDetail(duration: "3주", goal: "1시간/주", alarm: .every24Hours), categoryId: "category06"
            ),
            Routine(
                title: "요가",
                detail: RoutineDetail(duration: "3주", goal: "1시간/주", alarm: .every24Hours), categoryId: "category06"
            ),
            Routine(
                title: "러닝",
                detail: RoutineDetail(duration: "3주", goal: "1시간/주", alarm: .every24Hours), categoryId: "category06"
            ),
            Routine(
                title: "물마시기",
                detail: RoutineDetail(duration: "3주", goal: "1시간/주", alarm: .every24Hours), categoryId: "category06"
            ),
            Routine(
                title: "명상",
                detail: RoutineDetail(duration: "3주", goal: "1시간/주", alarm: .every24Hours), categoryId: "category06"
            ),
        ]
    )
]
>>>>>>> dev.mirror
