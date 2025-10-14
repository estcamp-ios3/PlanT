//
//  RoutineCardView.swift
//  PlanT
//
//  Created by 박성관 on 9/29/25.
//

import SwiftUI   // SwiftUI 라이브러리를 불러와서 화면(UI)을 만들 수 있게 함

enum TapBehavior {
    case selectOnly
    case navigate
}

// MARK: - 루틴 카드 뷰 (하나의 루틴을 카드 형태로 보여주는 화면 조각)
struct RoutineCardView: View {
    let routine: Routine                // 루틴 데이터 (제목, 기간, 알림 같은 정보)
    let category: RoutineCategory       // 루틴이 속한 카테고리 정보
    @Binding var isSelected: Bool       // 카드가 선택되었는지 여부 (부모 뷰에서 값 연결)
    var selectable: Bool = true
    var onSelect: (() -> Void)? = nil
    var tapBehavior: TapBehavior = .selectOnly
    let selected: Bool
    
    
    var body: some View {
        // 전체 카드 UI
        Button {
            switch tapBehavior {
            case .selectOnly, .navigate:
                onSelect?()
            }
        } label: {
            VStack(alignment: .leading, spacing: 4) {
                
                // 루틴 제목 표시 (가장 위에 큰 글씨)
                Text(routine.title)
                    .font(.headline)
                
                // 제목 밑에 나오는 상세 정보 (카테고리, 목표, 기간, 알림설정)
                HStack {
                    
                    // 왼쪽 영역: 카테고리 + 목표
                    VStack(alignment: .leading, spacing: 4) {
                        Text("카테고리: \(category.categoryTitle)")
                        
                        // 목표가 비어있지 않으면 보여줌
                        if !routine.detail.goal.isEmpty {
                            Text("목표: \(routine.detail.goal)")
                        }
                    }
                    
                    Spacer()
                    
                    // 오른쪽 영역: 기간 + 알림설정
                    VStack(alignment: .leading, spacing: 4) {
                        Text("기간: \(routine.detail.duration)") // 루틴 기간
                        
                        Text("알림설정: \(routine.detail.alarm.rawValue)") // 알림 설정 값
                    }
                }
            }
        }
        .buttonStyle(OptionGridItemStyle(selected: isSelected))
    }
}

