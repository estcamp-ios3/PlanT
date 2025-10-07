//
//  RoutineListView.swift
//  PlanT
//
//  Created by catharina J on 9/29/25.
//

import SwiftUI

private let brandIvory = Color("BrandSecondary")
private let gray100 = Color("Gray100")

struct RoutineListView: View {
    @Binding var path: NavigationPath
    @State private var showFabMenu = false
    @State private var refreshToken = UUID()
    @State private var selectedRoutineIDs: Set<UUID> = []
    @EnvironmentObject var store: RoutineStore
    
    
enum Route: Hashable {
        case plantAssistant
        case recommendedTemplates
        case manualCreate
        case goToList
    }

    private func category(for routine: Routine) -> RoutineCategory {
        for category in sampleCategories {
            if category.routines.contains(where: { $0.id == routine.id }) {
                return category
            }
        }
        return sampleCategories.first!
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
                            RoutineCardView(
                                routine: routine,
                                category: category(for: routine),
                                isSelected: Binding(
                                    get: { selectedRoutineIDs.contains(routine.id) },
                                    set: { newValue in
                                        if newValue {
                                            selectedRoutineIDs.insert(routine.id)
                                        } else {
                                            selectedRoutineIDs.remove(routine.id)
                                        }
                                    }
                                ),
                                onSelect: {
                                    if selectedRoutineIDs.contains(routine.id) {
                                        selectedRoutineIDs.remove(routine.id)
                                    } else {
                                        selectedRoutineIDs.insert(routine.id)
                                    }
                                }
                            )
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
            }
            .overlay(alignment: .bottomTrailing) {
                ZStack(alignment: .bottomTrailing) {
                    // 1) Tap-catcher to dismiss
                    if showFabMenu {  
                        Color.black.opacity(0.001)
                            .ignoresSafeArea()
                            .onTapGesture {
                                withAnimation(.spring(response: 0.25, dampingFraction: 0.9)) { showFabMenu = false
                                }
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
                        .padding(.trailing, 16)
                        .padding(.bottom, 76) // FAB(56) + 간격(16) + 여유
                        .ignoresSafeArea()
                        .zIndex(1000)
                        .transition(.move(edge: .bottom).combined(with: .opacity))
                    }

                    // 3) FAB itself
                    Button { withAnimation(.spring(response: 0.25, dampingFraction: 0.9)) { showFabMenu.toggle() } } label: {
                        Image(systemName: "plus")
                    }
                    .plantFABStyle(diameter: 56, iconSize: 30, useAccent: true)
                    .padding(.bottom, 20)
                    .ignoresSafeArea(.keyboard)
                }
            }
            
            .onReceive(NotificationCenter.default.publisher(for: .routineCreated)) { _ in
                // TODO: 여기에 실제 네트워크/DB 갱신 호출(ex: store.reload()) 넣어도 됨
                refreshToken = UUID()
            }
            .navigationDestination(for: Route.self) { route in
                switch route {
                case .plantAssistant:
                    RoutineSurveyView()
                case .recommendedTemplates:
                    RoutineTemplateView(path: $path)
                case .manualCreate:
                    RoutineRegisterView(mode: .create)
                case .goToList:
                    RoutineListView(path: $path)
                }
            }
        
    }
}




