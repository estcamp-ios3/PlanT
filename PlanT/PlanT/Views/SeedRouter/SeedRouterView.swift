//
//  Untitled.swift
//  PlanT
//
//  Created by 박성관 on 9/29/25.
//

enum SeedStatus {
    case notPlanted
    case planted(Routine) // 이미 심겨진 루틴 정보
}



//class RoutineTemplateViewModel: ObservableObject {
//    @Published var seedStatus: SeedStatus = .notPlanted // 기본값
//
//    func checkSeedStatus(for routine: Routine) {
//        // 로컬 저장소 또는 서버 확인 후
//        if isPlanted(routine: routine) {
//            seedStatus = .planted(routine)
//        } else {
//            seedStatus = .notPlanted
//        }
//    }
//
//    private func isPlanted(routine: Routine) -> Bool {
//        // 여기 실제 확인 로직 필요 (예: UserDefaults, DB 등)
//        return false // 일단은 하드코딩
//    }
//}
//
//
//
//import SwiftUI
//
//struct SeedRouterView: View {
//    @ObservedObject var viewModel: RoutineTemplateViewModel
//    let selectedRoutine: Routine
//
//    var body: some View {
//        Group {
//            switch viewModel.seedStatus {
//            case .notPlanted:
//                SeedSelectionView(routine: selectedRoutine) // 씨앗 심기 화면
//            case .planted(let routine):
//                SeedPlantedDetailView(routine: routine) // 심겨진 정보 보기 화면
//            }
//        }
//        .onAppear {
//            viewModel.checkSeedStatus(for: selectedRoutine)
//        }
//    }
//}
