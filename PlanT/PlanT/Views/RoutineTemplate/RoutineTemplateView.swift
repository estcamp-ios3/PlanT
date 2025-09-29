//
//  RoutineTemplateView.swift
//  PlanT
//
//  Created by Gwanoove on 9/29/25.
//
import Foundation
import SwiftUI

enum AlarmCycle: String {
    case every24Hours = "24시간 마다"
    case every48Hours = "48시간 마다"
}

struct RoutineDetail {
    let duration: String
    let goal: String
    let alarm: AlarmCycle
}

struct Routine: Identifiable {
    let id = UUID()
    let title: String
    let detail: RoutineDetail
}

struct RoutineCategory: Identifiable {
    let id = UUID()
    let emoji: String
    let title: String
    let routines: [Routine]
}

let sampleCategories: [RoutineCategory] = [
    RoutineCategory(
        emoji: "🌱",
        title: "지적 성장",
        routines: [
            Routine(
                title: "독서",
                detail: RoutineDetail(duration: "3일", goal: "5page/일", alarm: .every24Hours)
            ),
            Routine(
                title: "새로운 언어 학습",
                detail: RoutineDetail(duration: "3일", goal: "10단어/일", alarm: .every24Hours)
            )
        ]
    ),
    RoutineCategory(
        emoji: "💻",
        title: "전문 역량",
        routines: [
            Routine(
                title: "프로그래밍",
                detail: RoutineDetail(duration: "4주", goal: "6시간/일", alarm: .every24Hours)
            ),
            Routine(
                title: "디자인/영상 편집",
                detail: RoutineDetail(duration: "1주", goal: "4시간/일", alarm: .every48Hours)
            )
        ]
    ),
    RoutineCategory(
        emoji: "💪",
        title: "신체·건강",
        routines: [
            Routine(
                title: "물 마시기",
                detail: RoutineDetail(duration: "루틴여부: Yes", goal: "", alarm: .every24Hours)
            )
        ]
    )
]



struct RoutineTemplateView: View {
    var body: some View {
        NavigationView {
            ScrollView {
                
                VStack(spacing: 5) {
                    ForEach(sampleCategories) { category in
                        RoutineCategorySectionView(category: category)
                    }

                    Button(action: {
                        print("다음 버튼 눌림")
                    }) {
                        Text("다음")
                            .font(.headline)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.green)
                            .foregroundColor(.white)
                            .cornerRadius(12)
                    }
                    .padding(.top, 20)
                }
                .padding()
            }
            .navigationTitle("루틴 템플릿 선택")
        }
    }
}


#Preview {
    RoutineTemplateView()
}

