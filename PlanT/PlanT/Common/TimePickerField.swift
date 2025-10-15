//
//  TimePickerField.swift
//  PlanT
//
//  Created by catharina J on 10/14/25.
//

import SwiftUI

// MARK: - 탭하면 시트로 휠을 보여주는 시간 필드
struct TimePickerField: View {
    @Binding var date: Date
    @Binding var isEnabled: Bool
    var placeholder: String = "HH:MM"
    
    @State private var showSheet = false
    
    private var timeText: String {
        date.formatted(date: .omitted, time: .shortened) // 시스템 24/12시간 규칙 따름
    }
    
    var body: some View {
        Button {
            if isEnabled { showSheet = true }
        } label: {
            Text(!(timeText == "HH:MM") ? timeText : placeholder)
                .multilineTextAlignment(.leading)  //왼쪽정렬
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.vertical, vertical2)
                .padding(.horizontal, vertical3)
                .foregroundStyle(isEnabled ? .primary : .secondary)
                .background(isEnabled ? Color("Gray100") : Color.white)
                .clipShape(RoundedRectangle(cornerRadius: cornerRadius3))
            
        }
        .buttonStyle(.plain)
        .disabled(!isEnabled)
        .sheet(isPresented: $showSheet) {
            NavigationStack {
                VStack {
                    // 휠 스타일 시간 선택기
                    DatePicker(
                        "",
                        selection: $date,
                        displayedComponents: .hourAndMinute
                    )
                    .datePickerStyle(.wheel)
                    .labelsHidden()
                    .padding()
                }
                .navigationTitle("시간 선택")
                .navigationBarTitleDisplayMode(.inline)
                .toolbar {
                    ToolbarItem(placement: .topBarTrailing) {
                        Button("완료") { showSheet = false }
                    }
                }
                .presentationDetents([.medium]) // 필요시 [.medium, .large]
            }
        }
        .accessibilityLabel("시간 선택")
        .accessibilityValue(timeText)
        .onChange(of: isEnabled) { _, newValue in
            if !newValue { showSheet = false }
        }
    }
}
