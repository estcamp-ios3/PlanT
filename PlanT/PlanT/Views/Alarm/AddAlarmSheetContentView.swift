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
    @State private var showLimitAlert = false
    @State private var showInvalidAlert = false

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
                .cornerRadius(30)
                .onChange(of: newAlarmInput) { oldValue, newValue in
                                //  숫자만 입력 가능하도록 필터링
                                if !newValue.allSatisfy({ $0.isNumber }) && !newValue.isEmpty {
                                    newAlarmInput = oldValue
                                    showInvalidAlert = true
                                    return
                                }
                                
                                //  숫자 범위 제한 (480분)
                                if let value = Int(newValue), value > 480 {
                                    newAlarmInput = "480"
                                    showLimitAlert = true
                                }
                            }
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
        .alert("알림은 최대 480분(8시간) 전까지만 설정할 수 있습니다.", isPresented: $showLimitAlert) {
            Button("확인", role: .cancel) { }
        }
        .alert("숫자만 입력할 수 있습니다.", isPresented: $showInvalidAlert) {
                   Button("확인", role: .cancel) { }
               }
    }
}

