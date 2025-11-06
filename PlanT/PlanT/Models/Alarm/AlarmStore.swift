//
//  AlarmStore.swift
//  PlanT
//
//  Created by 박성관 on 10/17/25.
//
import Foundation
import Supabase
import SwiftUI
import Combine

@MainActor
final class AlarmStore: ObservableObject {
    
    
    static let shared = AlarmStore()
    
    @Published var alamPresets: [Int] = []
    @Published var defaultPresets: [Int] = [30, 20, 15, 10, 5]
    private let client = supabaseClient
    
   private init() {
        Task {
            await fetchPresets()
        }
    }
    func fetchPresets() async {
        do {
            let response: [AlarmPresetDTO] = try await client
                .from("alarm_presets")
                .select()
                .execute()
                .value
            
            let custom = response.map { $0.minutes }
            
            alamPresets = custom.sorted(by: >)
            print("✅ 알림 프리셋 (커스텀만) 불러오기 성공:", alamPresets)
        } catch {
            print("X 알림 프리셋 불러오기 실패: \(error)")
        }
    }
    func addPreset(_ minute: Int) async {
        do {
            let newPreset = AlarmPresetDTO(minutes: minute, is_default: false)
            try await client
                .from("alarm_presets")
                .insert(newPreset)
                .execute()
            await fetchPresets()
            print(" 알림 프리셋 추가 완료:", minute)
        } catch  {
            print("X 알림 프리셋 추가 실패:", error)
        }
    }
    func deletePreset(_ minute: Int) async {
        do {
            try await client
                .from("alarm_presets")
                .delete()
                .eq("minutes", value: minute)
                .execute()
            
            await fetchPresets()
            print(" 알림 프리셋 삭제 완료:", minute)
        } catch {
            print("X 알림 프리셋 삭제 실패:", error)
        }
    }
    func canAddPreset(_ minute: Int) -> Bool {
        let existsInDefaults = defaultPresets.contains(minute)
        let existsInCustom = alamPresets.contains(minute)

        return !(existsInDefaults || existsInCustom)
    }
}
