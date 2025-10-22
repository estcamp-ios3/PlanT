//
//  AlarmPresetPicker.swift
//  PlanT
//
//  Created by 박성관 on 10/20/25.
//
import SwiftUI

struct AlarmPresetPicker: View {
    @EnvironmentObject var alarmStore: AlarmStore
    @Binding var selectedAlarms: Set<Int>
    @Binding var showAddAlarmSheet: Bool
    @State private var isDeleteMode = false

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {

            HStack {
                Text("알림")
                    .font(.subheadline).bold()

                Spacer()

                if isDeleteMode {
                    Button("완료") { isDeleteMode = false }
                        .font(.subheadline).bold()
                        .foregroundColor(.red)
                } else {
                    Button(role: .destructive) {
                        withAnimation { isDeleteMode = true }
                    } label: {
                        Image(systemName: "minus")
                            .font(.system(size: 18, weight: .bold))
                            .padding(6)
                    }
                }

           
            }
            .padding(.bottom, 4)

            LazyVGrid(
                columns: [GridItem(.adaptive(minimum:60), spacing: 4)],
                spacing: 10
            ) {
                ForEach(alarmStore.alamPresets.filter { !isDeleteMode || !alarmStore.defaultPresets.contains($0) }, id: \.self) { minute in
                    Button(action: {
                        if isDeleteMode {
                            if !alarmStore.defaultPresets.contains(minute) {
                                Task { await alarmStore.deletePreset(minute) }
                            }
                        } else {
                            if selectedAlarms.contains(minute) {
                                selectedAlarms.remove(minute)
                            } else {
                                selectedAlarms.insert(minute)
                            }
                        }
                    }) {
                        Text("\(minute)분 전")
                            .font(.subheadline)
                            .padding(.vertical, 8)
                            .padding(.horizontal, 10)
                            .frame(maxWidth: .infinity)
                            .background(
                                isDeleteMode
                                ? Color.red.opacity(0.3)
                                : selectedAlarms.contains(minute) ? Color.orange : Color.gray.opacity(0.2)
                            )
                            .foregroundColor(.black)
                            .cornerRadius(30)
                    }
                }

                if alarmStore.alamPresets.count < 10 {
                    Button(action: {
                        withAnimation { showAddAlarmSheet = true }
                    }) {
                        Image(systemName: "plus")
                            .font(.subheadline)
                            .padding(8)
                            .frame(maxWidth: .infinity, minHeight: 36)
                            .background(Color.gray.opacity(0.2))
                            .clipShape(Circle())
                    }
                }
            }
            .transition(.opacity.combined(with: .move(edge: .top)))
            .animation(.spring(), value: selectedAlarms)
        }
    }
}
