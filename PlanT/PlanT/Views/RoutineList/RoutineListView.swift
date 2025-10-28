//
//  RoutineListView.swift
//  PlanT
//
//  Created by catharina J on 9/29/25.
//

import SwiftUI

struct RoutineListView: View {
    @Binding var path: NavigationPath
    @Binding var showAddAlarmSheet: Bool
    @State private var refreshToken = UUID()
    @State private var selectedRoutineIDs: Set<UUID> = []
    @EnvironmentObject var store: RoutineStore
    @EnvironmentObject var authStore: AuthStore
    @State private var isSelectedRoutine: Bool = false
    // 토스트 상태
    @State private var isToastVisible: Bool = false
    @State private var toastMessage: String = ""
    @State private var tutorialFrames: [String: CGRect] = [:]
    @StateObject private var tutorialManager = TutorialManager()
    
    enum Route: Hashable {
        case plantAssistant
        case recommendedTemplates
        case manualCreate
        case manualCreateDetails(Routine)
        case manualCreateEdit(Routine)
        case goToList
    }
    
    private func category(for routine: Routine) -> RoutineCategory {
        for category in routineTemplates {
            if category.categoryId == routine.categoryId {
                return category
            }
        }
        return routineTemplates.first!
    }
    
    // MARK: - Mate 토스트 트리거
    private func triggerMateToast(_ message: String, duration: TimeInterval = 4) {
        guard !message.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else { return }
        toastMessage = message
        
        // ✅ 빠른 fade-in
        withAnimation(.easeIn(duration: 0.15)) {
            isToastVisible = true
        }
        
        // ✅ 일정 시간 후 fade-out
        DispatchQueue.main.asyncAfter(deadline: .now() + duration) {
            withAnimation(.easeOut(duration: 0.4)) {
                isToastVisible = false
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                toastMessage = ""
            }
        }
    }
    
    var body: some View {
        ScrollView {
            VStack(spacing: vertical3) {
                if store.routines.isEmpty {
                    Text("여기에 루틴이 추가됩니다.")
                        .foregroundColor(.gray)
                        .padding()
                        .tutorialAnchor("emptyText")
                } else {
                    ForEach(store.routines) { routine in
                        RoutineCardModernView(
                            routine: routine,
                            progress: store.progress(for: routine)
                        )
                        .tutorialAnchor("routineCard")
                        .onTapGesture{
                            path.append(Route.manualCreateDetails(routine))
                        }
                        .contextMenu {
                            Button(role: .destructive) {
                                store.deleteRoutine(routine)
                            } label: {
                                Label("삭제하기", systemImage: "trash")
                            }
                        }
                    }
                }
            }
            .padding()
            .frame(maxWidth: .infinity)
        }
        .coordinateSpace(name: "tutorialSpace")
        .onPreferenceChange(TutorialAnchorKey.self) { tutorialFrames = $0 }
        
        // ✅ 왼쪽 아래: Mate + (선택적으로) 말풍선 토스트
        .overlay(alignment: .bottomLeading) {
            // 레이아웃 상수
            let avatarWidth: CGFloat = 80
            let leftPadding: CGFloat = 20
            let baseSpacing: CGFloat = 10
            let overlapX: CGFloat = 12 // 좌우값
            let overlapY: CGFloat = 0 // 상하값

            ZStack(alignment: .bottomLeading) {
                if isToastVisible {
                    // ✅ Mate 아바타도 토스트와 함께 등장/퇴장
                    MateBadge(imageName: authStore.mate ?? "MrPurr")
                        .padding(.leading, leftPadding)
                        .transition(.move(edge: .bottom).combined(with: .opacity))
                        .zIndex(5)

                    // ✅ 말풍선도 동일 타이밍으로 등장/퇴장
                    SpeechBubbleView(
                        message: toastMessage,
                        maxWidth: UIScreen.main.bounds.width * 0.7
                    )
                    .padding(.leading, leftPadding + avatarWidth + baseSpacing)
                    .offset(x: -overlapX, y: -overlapY)
                    .transition(.move(edge: .bottom).combined(with: .opacity))
                    .zIndex(10)
                }
                
            }
            .padding(.bottom, 20)
        }
        
        .onReceive(NotificationCenter.default.publisher(for: .showMateToast)) { noti in
            if let msg = (noti.userInfo?["message"] as? String)?
                .trimmingCharacters(in: .whitespacesAndNewlines),
               !msg.isEmpty {
                triggerMateToast(msg, duration: 10)
            }
        }
        
        .navigationDestination(for: Route.self) { route in
            switch route {
            case .plantAssistant:
                RoutineSurveyView(path: $path, showAddAlarmSheet: $showAddAlarmSheet)
            case .recommendedTemplates:
                RoutineTemplateView(path: $path, showAddAlarmSheet: $showAddAlarmSheet)
            case .manualCreate:
                RoutineRegisterView(mode: .create, path: $path, showAddAlarmSheet: $showAddAlarmSheet)
                    .environmentObject(store)
            case .manualCreateDetails(let routine):
                RoutineRegisterView(
                    mode: .details(routine),
                    categoryTitle: category(for: routine).categoryTitle,
                    path: $path, showAddAlarmSheet: $showAddAlarmSheet
                )
                .environmentObject(store)
            case .manualCreateEdit(let routine):
                RoutineRegisterView(
                    mode: .edit(routine),
                    categoryTitle: category(for: routine).categoryTitle,
                    path: $path, showAddAlarmSheet: $showAddAlarmSheet
                )
                .environmentObject(store)
            case .goToList:
                RoutineListView(path: $path, showAddAlarmSheet: $showAddAlarmSheet)
            }
        }
        
        .overlay {
            if tutorialManager.isActive {
                TutorialOverlayView(
                    manager: tutorialManager,
                    frames: tutorialFrames
                ) {
                    tutorialManager.finish()
                }
            }
        }
        
        // ✅ 네비게이션 바 우측 + 버튼 (FAB 대체)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Menu {
                    Button("PlanT와 루틴 만들기") {
                       if tutorialManager.isActive {
                            tutorialManager.next()
                        }
                        path.append(Route.plantAssistant)
                    }
                    Button("PlanT의 추천 루틴") {
                        if tutorialManager.isActive {
                             tutorialManager.next()
                         }
                        path.append(Route.recommendedTemplates)
                    }
                    Button("직접 등록하기") {
                        if tutorialManager.isActive {
                             tutorialManager.next()
                         }
                        path.append(Route.manualCreate)
                    }
                } label: {
                    Image(systemName: "plus")
                        .imageScale(.large)
                }
                .tutorialAnchor("plusButton")

            }
        }
        .onAppear {
            store.loadRoutines()
            store.refreshTrigger = UUID()
            guard !tutorialManager.hasShownTutorial else { return }
            
            let steps = [
                // 첫 번째 튜토리얼 (플러스 버튼 → 오른쪽 위)
                PlanTTutorialStep(
                    id: "intro",
                    message: "안녕하세요! 저는 Mr.Grrr, \n당신의 성장 메이트예요.\n작은 루틴으로\n 씨앗을 심고, 실천하면서 \n 당신만의 루틴식물을 키워보세요",
                    showNextButton: true,
                    verticalOffset: 0,     // 위로 올림
                    horizontalOffset: 0    // 오른쪽으로 이동
                ),
                PlanTTutorialStep(
                    id: "plusButton",
                    message: "오른쪽 위 + 버튼을 눌러 루틴을 추가하세요!",
                    showNextButton: true,
                    verticalOffset: -220,     // 위로 올림
                    horizontalOffset: 160    // 오른쪽으로 이동
                ),
                // 두 번째 튜토리얼 (빈 화면 안내 → 화면 중앙보다 아래쪽)
                PlanTTutorialStep(
                    id: "emptyText",
                    message: "루틴이 없을 때는 \n아무것도 표시가 안됩니다.",
                    showNextButton: true,
                    verticalOffset: 180,     // 아래로 내림
                    horizontalOffset: 0
                ),
                // 세 번째 튜토리얼 (루틴 카드 안내)
                PlanTTutorialStep(
                    id: "emptyText",
                    message: "이곳에서 루틴의 성장을 \n확인할 수 있습니다.",
                    showNextButton: true,
                    verticalOffset: 180,
                    horizontalOffset: 0
                )
            ]
            tutorialManager.start(steps: steps)
        }
    }
}
