////
////  RoutineTemplateView.swift
////  PlanT
////
////  Created by 박성관 on 9/29/25.
////
//import Foundation
//import SwiftUI
//
//// MARK: - Utilities
//private extension String {
//    /// Extracts all digits in the string and converts to Int64. Returns 0 if no digits found.
//    func numericInt64() -> Int64 {
//        let digits = self.compactMap { $0.isNumber ? $0 : nil }
//        guard !digits.isEmpty, let value = Int64(String(digits)) else { return 0 }
//        return value
//    }
//}
//
//
//
//// MARK: - 루틴 카테고리 모델
//// 루틴들을 카테고리별로 그룹화
//struct RoutineCategory: Identifiable {
//    let id = UUID()               // 카테고리 고유 식별자
//    let categoryId: String
//    let categoryTitle: String
//    let emoji: String             // 카테고리 이모지 아이콘
//    let routines: [Routine]       // 카테고리에 포함된 루틴 리스트
//}
//
//let sampleCategories: [RoutineCategory] = [
//    RoutineCategory(
//        categoryId:  "category02",
//        categoryTitle: "지적/성장",
//        emoji: "🌱",
//        routines: [
//            Routine(
//                title: "독서",
//                detail: RoutineDetail(duration: "3일", goal: "5page/일", alarm: .every24Hours)
//            ),
//            Routine(
//                title: "새로운 언어 학습",
//                detail: RoutineDetail(duration: "3일", goal: "10단어/일", alarm: .every24Hours)
//            )
//        ]
//    ),
//    RoutineCategory(
//        categoryId:  "category04",
//        categoryTitle: "전문/역량",
//        emoji: "💻",
//        routines: [
//            Routine(
//                title: "프로그래밍",
//                detail: RoutineDetail(duration: "4주", goal: "6시간/일", alarm: .every24Hours)
//            ),
//            Routine(
//                title: "디자인/영상 편집",
//                detail: RoutineDetail(duration: "1주", goal: "4시간/일", alarm: .every48Hours)
//            )
//        ]
//    ),
//    RoutineCategory(
//        categoryId:  "category06",
//        categoryTitle: "지적/성장",
//        emoji: "💪",
//        routines: [
//            Routine(
//                title: "물 마시기",
//                detail: RoutineDetail(duration: "루틴여부: Yes", goal: "", alarm: .every24Hours)
//            )
//        ]
//    )
//]
//
//// MARK: - 루틴 템플릿 선택 화면
//// 여러 루틴 카테고리를 카드 리스트 형태로 표시하고,
//// 루틴을 선택할 수 있는 화면
//struct RoutineTemplateView: View {
//    
//    @Binding var path: NavigationPath
//    let categories: [RoutineCategory] = sampleCategories     // 표시할 루틴 카테고리 목록
//    @State private var selectedRoutineID: UUID? = nil // 현재 선택된 루틴 ID (없으면 nil)
//    
//    // 초기화 시점에 전달받은 categories가 없으면
//    // DEBUG 빌드일 때는 sampleCategories를 기본값으로 사용
//    // RELEASE 빌드일 때는 빈 배열 사용
//    init(path: Binding<NavigationPath>) {
//        self._path = path
//    }
//    
//    var body: some View {
//        ScrollView {
//            VStack(spacing: 5) {
//                
//                // 카테고리 단위 섹션을 반복 렌더링
//                ForEach(sampleCategories) { category in
//                    RoutineCategorySectionView(
//                        category: category,
//                        selectedRoutineID: $selectedRoutineID
//                    )
//                }
//                
//                // 루틴이 선택된 경우
//                if let id = selectedRoutineID {
//                    // NavigationLink를 통해 다음 화면으로 이동 가능
//                    NavigationLink(value: id) {
//                        Text("다음")
//                    }
//                    .plantPrimaryButton()
//                    .padding(.top, 20)
//                    
//                    // 루틴이 선택되지 않은 경우
//                } else {
//                    Button { /* action 없음 */ } label: {
//                        Text("다음")
//                    }
//                    .plantPrimaryButton()
//                    .padding(.top, 20)
//                    .disabled(true)
//                }
//            }
//            .padding()
//        }
//        // 내비게이션 타이틀
//        .navigationTitle("루틴 템플릿 선택")
//        
//        // NavigationLink와 함께 사용되는 navigationDestination
//        // selectedRoutineID(UUID)가 전달되면 해당 ID를 바인딩으로 SeedStatusView 화면으로 이동
//        .navigationDestination(for: UUID.self) { id in
//            if let routine = sampleCategories.flatMap({ $0.routines }).first(where: { $0.id == id }),
//               let category = sampleCategories.first(where: {$0.routines.contains(where: { $0.id == id }) }) {
//
//                let draft = RoutineDraft(
//                    categoryId: category.categoryId.numericInt64(),
//                    categoryTitle: category.categoryTitle,
//                    routineTypeId: routine.title,
//                    routineTypeTitle: routine.title,
//                    frequencyPerWeekId: "3x",
//                    frequencyPerWeekTitle: "주 3회",
//                    durationId: routine.detail.duration,
//                    durationTitle: routine.detail.duration,
//                    periodIsNoLimit: true,
//                    reminderOn: routine.detail.alarm == .every24Hours,
//                    goal: routine.detail.goal,
//                    isFavorite: false
//                )
//
//                SeedStatusView(state: .planted(routine), draft: draft, path: $path)
//            } else {
//// //                let fallbackDraft = RoutineDraft(
//// //                    categoryId: "category.categoryId.numericInt64()",
//// //                    categoryTitle: "-",
//// //                    routineTypeId: "-",
//// //                    routineTypeTitle: "-",
//// //                    frequencyPerWeekId: "-",
//// //                    frequencyPerWeekTitle: "-",
//// //                    durationId: "-",
//// //                    durationTitle: "-",
//// //                    periodIsNoLimit: true,
//// //                    reminderOn: false,
//// //                    goal: "-",
//// //                    isFavorite: false
//// //                )
//// //                SeedStatusView(state: .notPlanted, draft: fallbackDraft, path: $path)
//            }
//        }
//    }
//}
//
