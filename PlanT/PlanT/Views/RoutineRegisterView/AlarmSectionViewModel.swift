//
//  AlarmSectionViewModel.swift
//  PlanT
//
//  Created by 박성관 on 11/4/25.
//

import Foundation
import Combine

@MainActor
final class AlarmSectionViewModel: ObservableObject {
    @Published var selectedAlarms: Set<Int> = []
    @Published var isDeleteMode: Bool = false
    @Published var showAlarms: Bool = true
    @Published var isAddSheetPresented: Bool = false
    
    @Published private(set) var customPresets: [Int] = []
    private var cancellables: Set<AnyCancellable> = []
    var alarmStore: AlarmStore
    
    init(selectedAlarms: Set<Int> = [], alarmStore: AlarmStore) {
        self.selectedAlarms = selectedAlarms
        self.alarmStore = alarmStore
        alarmStore.$alamPresets
            .receive(on: DispatchQueue.main)
            .sink { [weak self] newPresets in
        self?.customPresets = newPresets
    }
            .store(in: &cancellables)
}
    // MARK: - Computed Views
    var filteredPresets: [Int] {
        if isDeleteMode {
            return customPresets.sorted(by: <)
        } else {
            let all = Set(alarmStore.defaultPresets + alarmStore.alamPresets)
            return all.sorted(by: <)
        }
        
    }
    var canAddMorePreset: Bool {
        alarmStore.alamPresets.count < 10
    }
    
    func isSelected(minute: Int) -> Bool {
        selectedAlarms.contains(minute)
    }
    
    func canDelete(minute: Int) -> Bool {
        !alarmStore.defaultPresets.contains(minute)
    }
    
    // MARK: - Actions
    
    func toggleAlarm(_ minute: Int) {
        if selectedAlarms.contains(minute) {
            selectedAlarms.remove(minute)
        } else {
            selectedAlarms.insert(minute)
        }
    }
    func deletePresets(_ minute: Int) {
        customPresets.removeAll { $0 == minute }
        objectWillChange.send()
        
            Task {
            await alarmStore.deletePreset(minute)
        }
    }
    func showAddPresetSheet() {
        isAddSheetPresented = true
    }
}
