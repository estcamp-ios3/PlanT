//
//  MypageMainView.swift
//  PlanT
//
//  Created by catharina J on 9/29/25.
//

import SwiftUI

struct MypageMainView: View {
    @EnvironmentObject var authStore: AuthStore
    @EnvironmentObject var routineStore: RoutineStore
    
    var body: some View {
        ScrollView {
            VStack(spacing: vertical3) {
                MypageUserCardView(authStore: authStore)
                MypageItemView()
                
                // ✅ 섹션 타이틀 추가
                Text("성장중인 작물")
                    .font(.title3.bold())
                    .foregroundColor(.primary)
                    .frame(maxWidth: .infinity, alignment: .leading)
                
                // ✅ 옆으로 스와이프 가능한 카드 뷰
                TabView {
                    ForEach(routineStore.routines) { routine in
                        MypagePlantsCardView(
                            authStore: authStore,
                            routine: routine,
                            routineStore: routineStore
                        )
                        .padding(.horizontal, vertical1)
                        .padding(.top, -55)
                        
                    }
                }
                .tabViewStyle(PageTabViewStyle(indexDisplayMode: .automatic))
                .frame(height: 500) // 카드 높이에 맞춰 조절
            }
            .padding(.horizontal)
        }
    }
}

// 프리뷰용(삭제예정)

import SwiftData

@MainActor
private func makeMypageMainPreview() -> some View {
    // ✅ AuthStore
    let authStore = AuthStore()
    authStore.mate = "MrPurr"

    // ✅ 메모리 전용 SwiftData 컨테이너 + 컨텍스트
    let schema = Schema([Routine.self])
    let config = ModelConfiguration(isStoredInMemoryOnly: true)
    let container = try! ModelContainer(for: schema, configurations: [config])
    let context = container.mainContext

    // ✅ 샘플 루틴 (duration: String, alarm: AlarmCycle)
    let routines: [Routine] = [
        Routine(
            title: "아침 스트레칭",
            categoryId: "wellness",
            seedName: "seed_Sunflower03",
            duration: "30",
            goal: "매일 30분 스트레칭",
            alarm: .every24Hours,
            frequencyPerWeekId: "x3",
            frequencyPerWeekTitle: "주 3회",
            note: "몸 깨우기 🌞",
            isCompleted: false,
            createdAt: .now,
            modifiedAt: .now
        ),
        Routine(
            title: "저녁 러닝",
            categoryId: "exercise",
            seedName: "seed_Sunflower02",
            duration: "40",
            goal: "주 4회 러닝",
            alarm: .every48Hours,
            frequencyPerWeekId: "x4",
            frequencyPerWeekTitle: "주 4회",
            note: "5km 목표 🏃",
            isCompleted: false,
            createdAt: .now,
            modifiedAt: .now
        )
    ]

    routines.forEach { context.insert($0) }
    try? context.save()

    // ✅ 같은 context로 RoutineStore 생성
    let routineStore = RoutineStore(context: context)

    // ✅ 최종 뷰 반환
    return NavigationStack {
        MypageMainView()
            .environmentObject(authStore)
            .environmentObject(routineStore)
    }
    .modelContainer(container)
}

#Preview {
    makeMypageMainPreview() // 👈 ViewBuilder 안에는 뷰 표현식만!
}
