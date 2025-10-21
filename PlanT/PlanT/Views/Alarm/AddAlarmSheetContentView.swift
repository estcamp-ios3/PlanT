//
//  AddAlarmSheetContentView.swift
//  PlanT
//
//  Created by 박성관 on 10/18/25.
//
import SwiftUI

struct AddAlarmSheetContentView: View {
    @Binding var showAddAlarmSheet: Bool
    @EnvironmentObject var alarmStore: AlarmStore
    @State private var newAlarmInput = ""
    @State private var showAlert = false
    @StateObject private var keyboard = KeyboardResponder()
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                
                Text("알림 시간 직접 추가")
                    .font(.headline)
                Spacer()
             
                .foregroundColor(.blue)
            }
            
            TextField("예: 25", text: $newAlarmInput)
                .keyboardType(.numberPad)
                .textFieldStyle(RoundedBorderTextFieldStyle())
            
            Button("추가") {
                if let minute = Int(newAlarmInput), minute > 0 {
                    if alarmStore.canAddPreset(minute) {
                        Task {
                            await alarmStore.addPreset(minute)
                        }
                        newAlarmInput = ""
                        withAnimation {
                            showAddAlarmSheet = false
                        }
                    } else {
                        showAlert = true
                    }
                }
            }
            .frame(maxWidth: .infinity)
            .padding()
            .plantPrimaryButton()

        }
        .padding(.bottom, keyboard.keyboardHeight)
        .animation(.easeOut(duration: 0.25), value: keyboard.keyboardHeight)
        .alert("이미 존재하거나 기본값은 추가할 수 없어요.", isPresented: $showAlert) {
            Button("확인", role: .cancel) {}
        }
    }
}

