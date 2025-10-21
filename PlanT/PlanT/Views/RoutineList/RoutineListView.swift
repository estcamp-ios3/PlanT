//
//  RoutineListView.swift
//  PlanT
//
//  Created by catharina J on 9/29/25.
//

import SwiftUI

private let brandIvory = Color("BrandSecondary")

struct RoutineListView: View {
    @Binding var path: NavigationPath
    @Binding var showAddAlarmSheet: Bool
    @State private var showFabMenu = false
    @State private var refreshToken = UUID()
    @State private var selectedRoutineIDs: Set<UUID> = []
    @EnvironmentObject var store: RoutineStore
    @EnvironmentObject var authStore: AuthStore
    @State private var isSelectedRoutine: Bool = false
    
    // 토스트 상태
    @State private var isToastVisible: Bool = false
    @State private var toastMessage: String = ""
    
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
            VStack(spacing: 12) {
                if store.routines.isEmpty {
                    Text("여기에 루틴이 추가됩니다.")
                        .foregroundColor(.gray)
                        .padding()
                } else {
                    ForEach(store.routines) { routine in
                        RoutineCardModernView(
                            routine: routine,
                            progress: store.progress(for: routine)
                        )
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
        
        // ✅ 왼쪽 아래: Mate + (선택적으로) 말풍선 토스트
        .overlay(alignment: .bottomLeading) {
            // 레이아웃 상수
            let avatarWidth: CGFloat = 80
            let leftPadding: CGFloat = 20
            let baseSpacing: CGFloat = 10      // Mate ↔︎ 말풍선 기본 간격
            let overlapX: CGFloat = 12         // 말풍성 좌우
            let overlapY: CGFloat = 45          // 말풍선 상하

            ZStack(alignment: .bottomLeading) {
                // Mate 아바타 (Supabase에서 가져오는 값 사용)
                MateBadge(imageName: authStore.mate ?? "MrPurr")
                    .padding(.leading, leftPadding)
                    .zIndex(5)

                // 말풍선 토스트 (보일 때만)
                if isToastVisible {
                    SpeechBubbleView(
                        message: toastMessage,
                        maxWidth: UIScreen.main.bounds.width * 0.7
                    )
                    // 아바타 오른쪽에 기본 배치 후, 살짝 왼쪽/위로 당겨 겹치기
                    .padding(.leading, leftPadding + avatarWidth + baseSpacing)
                    .offset(x: -overlapX, y: -overlapY)
                    .transition(.opacity)                   // 빠른 fade-in, 보통속도 fade-out은 트리거에서 처리
                    .zIndex(10)                             // Mate 위로
                }
            }
            .padding(.bottom, 20)
        }
        
        .overlay(alignment: .bottomTrailing) {
            ZStack(alignment: .bottomTrailing) {
                // 1) Tap-catcher to dismiss
                if showFabMenu {
                    Color.black.opacity(0.001)
                        .ignoresSafeArea()
                        .onTapGesture {
                            withAnimation(.spring(response: 0.25, dampingFraction: 0.9)) { showFabMenu = false }
                        }
                }
                
                // 2) Popup menu
                if showFabMenu {
                    VStack(alignment: .leading, spacing: 0) {
                        PlantFABMenuItem(title: "PlanT와 루틴 만들기") {
                            path.append(Route.plantAssistant)
                            showFabMenu = false
                        }
                        Divider().overlay(Color.black.opacity(0.06))
                        PlantFABMenuItem(title: "PlanT의 추천 루틴") {
                            path.append(Route.recommendedTemplates)
                            showFabMenu = false
                        }
                        Divider().overlay(Color.black.opacity(0.06))
                        PlantFABMenuItem(title: "직접 등록하기") {
                            path.append(Route.manualCreate)
                            showFabMenu = false
                        }
                    }
                    .background(
                        RoundedRectangle(cornerRadius: 12, style: .continuous)
                            .fill(brandIvory)
                            .shadow(color: Color.black.opacity(0.12), radius: 8, x: 0, y: 3)
                    )
                    .overlay(
                        RoundedRectangle(cornerRadius: 12, style: .continuous)
                            .stroke(Color("Gray400"), lineWidth: 1)
                    )
                    .fixedSize()
                    .padding(.trailing, 32)
                    .padding(.bottom, 56) // FAB(56)
                    .ignoresSafeArea()
                    .zIndex(1000)
                    .transition(.move(edge: .bottom).combined(with: .opacity))
                }
                
                // 3) FAB itself
                Button { withAnimation(.spring(response: 0.25, dampingFraction: 0.9)) { showFabMenu.toggle() } } label: {
                    Image(systemName: "plus")
                }
                .plantFABStyle(diameter: 56, iconSize: 30, useAccent: true)
                .padding(20)
                .ignoresSafeArea(.keyboard)
            }
        }
        // ✅ 전역 토스트 트리거만 수신
        .onReceive(NotificationCenter.default.publisher(for: .showMateToast)) { noti in
            if let msg = (noti.userInfo?["message"] as? String)?
                .trimmingCharacters(in: .whitespacesAndNewlines),
               !msg.isEmpty {
                triggerMateToast(msg, duration: 4)
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
        .onAppear {
            NotificationManager.shared.debugPendingNotifications()
        }
    }
}
