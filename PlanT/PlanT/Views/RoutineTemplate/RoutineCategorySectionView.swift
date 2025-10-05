//
//  RoutineCategorySectionView.swift
//  PlanT
//
//  Created by 박성관 on 9/29/25.
//
import SwiftUI

/// 특정 루틴 카테고리와 해당 루틴들을 Section 형태로 표시하는 뷰
struct RoutineCategorySectionView: View {
    let category: RoutineCategory          // 현재 표시할 루틴 카테고리
    @Binding var selectedRoutineID: UUID?  // 선택된 루틴의 ID. 상위 뷰와 상태 공유
    
    var body: some View {
        Spacer(minLength: 10)

        // SwiftUI Section: 헤더와 콘텐츠로 구성
        Section(
            // Section 헤더: 카테고리 이모지 + 카테고리 제목
            header: HStack {
                Text("\(category.emoji) \(category.title)") // 카테고리 표시
                    .font(.title3)
                    .bold()
                    .padding(.leading, 4)
                Spacer()
            }
        ) {
            // Section 본문: 루틴 목록 반복 출력
            ForEach(category.routines) { routine in
                RoutineCardView(
                    routine: routine,     // 개별 루틴 데이터
                    category: category,   // 해당 루틴의 카테고리
                    
                    // RoutineCardView의 isSelected(@Binding Bool)와
                    // selectedRoutineID(UUID?)를 연결하기 위해 Binding 변환
                    isSelected: Binding(
                        // getter: 현재 선택된 ID와 루틴 ID 비교
                        get: { selectedRoutineID == routine.id },
                        // setter: true면 현재 루틴 ID 저장, false면 nil로 해제
                        set: { newValue in
                            selectedRoutineID = newValue ? routine.id : nil
                        }
                    ),
                    
                    // RoutineCardView의 onSelect 콜백
                    // 동일 루틴을 다시 선택하면 해제, 다른 루틴을 선택하면 ID 갱신
                    onSelect: {
                        if selectedRoutineID == routine.id {
                            selectedRoutineID = nil
                        } else {
                            selectedRoutineID = routine.id
                        }
                    }
                )
            }
        }
        .padding(.vertical, 4)
    }
}
