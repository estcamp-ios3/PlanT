//
//  PlanTApp.swift
//  PlanT
//
//  Created by catharina J on 9/29/25.
//

import SwiftUI
import SwiftData

@main
struct PlanTApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    
    @StateObject private var authStore = AuthStore()
    @StateObject private var routineStore: RoutineStore
    @StateObject private var alarmStore = AlarmStore()
    @StateObject private var routineAlarmStore: RoutineAlarmStore

    let sharedModelContainer: ModelContainer

    init() {
        // SwiftData 컨테이너 구성
        let schema = Schema([
            Routine.self,
            RoutineAlarm.self
        ])
        let configuration = ModelConfiguration(
            schema: schema,
            url: URL.documentsDirectory.appending(path: "Main.store")
        )
        let container = try! ModelContainer(for: schema, configurations: [configuration])

        self.sharedModelContainer = container
        // ✅ RoutineStore를 App 레벨에서 한 번만 생성
        _routineStore = StateObject(wrappedValue: RoutineStore(context: container.mainContext))
        _routineAlarmStore = StateObject(wrappedValue: RoutineAlarmStore(context: container.mainContext))
        NotificationManager.shared.requestPermission()
    }

    var body: some Scene {
        WindowGroup {
            if authStore.isAuthenticated {
                ContentView()
                    .environmentObject(authStore)
                    .environmentObject(routineStore)
                    .environmentObject(alarmStore)
                    .environmentObject(routineAlarmStore)
            } else {
                LoginView(authStore: authStore)
                    .environmentObject(authStore)
                    .task { await authStore.restoreSession() }
            }
        }
        .modelContainer(sharedModelContainer) // modelContext 전달
    }
}
