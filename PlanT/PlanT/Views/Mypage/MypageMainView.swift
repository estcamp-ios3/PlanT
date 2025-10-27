//
//  MypageMainView.swift
//  PlanT
//
//  Created by catharina J on 9/29/25.
//

import SwiftUI
import SwiftData // 미리보기용 데이터연결용(삭제예정)

struct MypageMainView: View {
    @EnvironmentObject var authStore: AuthStore
    @EnvironmentObject var routineStore: RoutineStore
    @State private var currentRoutineID: UUID?
    @State private var showSettings = false

    var body: some View {
        ScrollView {
            VStack(spacing: vertical3) {
                MypageUserCardView(authStore: authStore)
                MypageItemView()

                Text("성장중인 작물")
                    .font(.title3.bold())
                    .foregroundColor(.primary)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.top, vertical2)
                    .padding(.horizontal, 30)
            }
            .padding(.horizontal, vertical4)
            GeometryReader { geo in
                // 레이아웃 파라미터
                let sideInset: CGFloat = 0 // ScrollView 내부 좌우 패딩(아이템 HStack 앞뒤)
                let peek: CGFloat = 65 // 카드 가로 폭
                let cardWidth = geo.size.width - (sideInset * 2) - peek
                let horizontalMargin = max(0, (geo.size.width - cardWidth) / 2)
                
                if routineStore.routines.isEmpty { // 분기처리
                    // ✅ 루틴이 없을 때: 빈 카드 1개
                    MypageEmptyPlantsCardView(mateImageName: authStore.mate ?? "MrPurr")
                        .frame(width: cardWidth, height: 460)
                        .clipShape(RoundedRectangle(cornerRadius: cornerRadius3, style: .continuous))
                        .shadow(color: .black.opacity(0.08), radius: 8, y: 4)
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                } else {
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: vertical1) {
                            ForEach(routineStore.routines) { routine in
                                MypagePlantsCardView(
                                    authStore: authStore,
                                    routine: routine,
                                    routineStore: routineStore
                                )
                                .frame(width: cardWidth, height: 460)
                                
                                .clipShape(RoundedRectangle(cornerRadius: cornerRadius3, style: .continuous))
                                .shadow(color: .black.opacity(0.08), radius: vertical2, y: vertical1)
                                .id(routine.id) // 스냅 타깃 고유 ID
                                
                                .scrollTransition(.animated.threshold(.visible(0.6))) { content, phase in
                                    content
                                        .scaleEffect(phase.isIdentity ? 1.0 : 0.96)
                                        .opacity(phase.isIdentity ? 1.0 : 0.95)
                                }
                            }
                        }
                        .padding(.top, vertical2)
                        .scrollTargetLayout()
                    }
                    .frame(height: 500)
                    .contentMargins(.horizontal, horizontalMargin, for: .scrollContent)
                    .scrollPosition(id: $currentRoutineID, anchor: .center)
                    .scrollTargetBehavior(.viewAligned)
                    .animation(Animation.interactiveSpring(response: 0.35, dampingFraction: 0.8), value: currentRoutineID)
                    .onAppear {
                        if currentRoutineID == nil {
                            currentRoutineID = routineStore.routines.first?.id
                        }
                    }
                }
            }
            .frame(height: 500) // GeometryReader 고정 높이
            .padding(.top, -30)
        }
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button("설정") { showSettings = true }
                    .font(.system(size: vertical3, weight: .bold))
                    .foregroundColor(.gray900)
            }
        }
        .navigationDestination(isPresented: $showSettings) {
            SettingView()
        }
    }
}

// MARK: - Preview (메모리 컨테이너로 샘플 데이터) 미리보기용 데이터로 삭제예정
@MainActor
private func makeMypageMainPreview() -> some View {
    // AuthStore
    let authStore = AuthStore()
    authStore.mate = "MrPurr"

    // 메모리 전용 SwiftData 컨테이너 + 컨텍스트
    let schema = Schema([Routine.self])
    let config = ModelConfiguration(isStoredInMemoryOnly: true)
    let container = try! ModelContainer(for: schema, configurations: [config])
    let context = container.mainContext

    // 샘플 루틴
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
        ),
        Routine(
            title: "독서",
            categoryId: "study",
            seedName: "seed_Apple03",
            duration: "20",
            goal: "하루 20분 독서",
            alarm: .every24Hours,
            frequencyPerWeekId: "x5",
            frequencyPerWeekTitle: "주 5회",
            note: "슬금슬금 📚",
            isCompleted: false,
            createdAt: .now,
            modifiedAt: .now
        )
    ]

    routines.forEach { context.insert($0) }
    try? context.save()

    // 같은 context로 RoutineStore 생성
    let routineStore = RoutineStore(context: context)

    // 최종 뷰 반환
    return NavigationStack {
        MypageMainView()
            .environmentObject(authStore)
            .environmentObject(routineStore)
    }
    .modelContainer(container)
}

#Preview {
    makeMypageMainPreview()
}
