//
//  AddAlarmSheetContent.swift
//  PlanT
//
//  Created by 박성관 on 10/18/25.
//
import SwiftUI

struct AddAlarmSheetContent: View {
    @Binding var showAddAlarmSheet: Bool
    @EnvironmentObject var alarmStore: AlarmStore
    @State private var newAlarmInput = ""
    
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
                    Task {
                        await alarmStore.addPreset(minute)
                    }
                    newAlarmInput = ""
                    withAnimation {
                        showAddAlarmSheet = false
                    }
                }
            }
            .frame(maxWidth: .infinity)
            .padding()
            .background(Color("BrandSecondary"))
            .foregroundStyle(Color(.white))
            .cornerRadius(10)
        }
    }
}

