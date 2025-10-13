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
    @StateObject private var authStore = AuthStore()
    
    // SwiftData용 컨테이너 정의
    var sharedModelContainer: ModelContainer = {
        //  스키마 등록
        let schema = Schema([Routine.self])
        
        //  설정 구성 (저장소 이름)
        let configuration = ModelConfiguration(schema: schema, url: URL.documentsDirectory.appending(path: "Main.store"))
        
        //  ModelContainer 생성
        return try! ModelContainer(for: schema, configurations: [configuration])
    }()
    
    var body: some Scene {
        WindowGroup {
            if authStore.isAuthenticated {
                ContentView()
                    .environmentObject(authStore)
                    .environmentObject(RoutineStore(context: sharedModelContainer.mainContext))
            } else {
                LoginView()
                    .environmentObject(authStore)
            }
        }
        .modelContainer(sharedModelContainer)
    }
}
