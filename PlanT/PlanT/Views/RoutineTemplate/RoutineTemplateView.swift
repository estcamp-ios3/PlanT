//
//  RoutineTemplateView.swift
//  PlanT
//
//  Created by 박성관 on 9/29/25.
//
import Foundation
import SwiftUI

// MARK: - 루틴 템플릿 선택 화면
// 여러 루틴 카테고리를 카드 리스트 형태로 표시하고,
// 루틴을 선택할 수 있는 화면
struct RoutineTemplateView: View {
    
    @Binding var path: NavigationPath
    let categories: [RoutineCategory] = routineTemplates     // 표시할 루틴 카테고리 목록
    @State private var selectedRoutineID: UUID? = nil // 현재 선택된 루틴 ID (없으면 nil)
    
    // 초기화 시점에 전달받은 categories가 없으면
    // DEBUG 빌드일 때는 sampleCategories를 기본값으로 사용
    // RELEASE 빌드일 때는 빈 배열 사용
    init(path: Binding<NavigationPath>) {
        self._path = path
    }
    
    var body: some View {
        ScrollView {
            VStack(spacing: 5) {
                
                // 카테고리 단위 섹션을 반복 렌더링
                ForEach(routineTemplates) { category in
                    RoutineCategorySectionView(
                        category: category,
                        selectedRoutineID: $selectedRoutineID
                    )
                }
                Spacer().frame(height: 80)
            }
            .padding()
        }
        // 내비게이션 타이틀
        .navigationTitle("루틴 템플릿 선택")
        .safeAreaInset(edge: .bottom) {
            // 루틴이 선택된 경우
            if let id = selectedRoutineID {
                // NavigationLink를 통해 다음 화면으로 이동 가능
                NavigationLink(value: id) {
                    Text("다음")
                }
                .plantPrimaryButton()
                .padding(.horizontal, 20)

                // 루틴이 선택되지 않은 경우
            } else {
                Button { /* action 없음 */ } label: {
                    Text("다음")
                }
                .plantPrimaryButton()
                .disabled(true)
                .padding(.horizontal, 20)
            }
        }
        .padding(.bottom, 12)
        .background(Color(.systemBackground))
        // NavigationLink와 함께 사용되는 navigationDestination
        // selectedRoutineID(UUID)가 전달되면 해당 ID를 바인딩으로 SeedStatusView 화면으로 이동
        .navigationDestination(for: UUID.self) { id in
            if let routine = routineTemplates.flatMap({ $0.routines }).first(where: { $0.id == id }),
               let category = routineTemplates.first(where: {$0.routines.contains(where: { $0.id == id }) }) {

                let draft = RoutineDraft(
                    categoryId: category.categoryId,
                    categoryTitle: category.categoryTitle,
                    routineTypeId: routine.title,
                    routineTypeTitle: routine.title,
                    frequencyPerWeekId: "3x",
                    frequencyPerWeekTitle: "주 3회",
                    durationId: routine.detail.duration,
                    durationTitle: routine.detail.duration,
                    periodIsNoLimit: true,
                    reminderOn: routine.detail.alarm == .every24Hours,
                    goal: routine.detail.goal,
                    isFavorite: false

                )

                SeedStatusView(state: .planted(routine), draft: draft, path: $path)
            } else {
                let fallbackDraft = RoutineDraft(
                    categoryId: "-",
                    categoryTitle: "-",
                    routineTypeId: "-",
                    routineTypeTitle: "-",
                    frequencyPerWeekId: "-",
                    frequencyPerWeekTitle: "-",
                    durationId: "-",
                    durationTitle: "-",
                    periodIsNoLimit: true,
                    reminderOn: false,
                    goal: "-",
                    isFavorite: false

                )
                SeedStatusView(state: .notPlanted, draft: fallbackDraft, path: $path)
            }
        }
    }
}

