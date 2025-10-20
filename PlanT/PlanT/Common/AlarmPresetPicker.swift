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

            // ✅ 헤더 영역
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

                // ✅ 프리셋 총 10개 미만일 때만 "+" 버튼 표시
                if alarmStore.alamPresets.count < 10 {
                    Button {
                        withAnimation { showAddAlarmSheet = true }
                    } label: {
                        Image(systemName: "plus")
                            .padding(8)
                            .background(Color.gray.opacity(0.2))
                            .clipShape(Circle())
                    }
                }
            }
            .padding(.bottom, 4)

            // ✅ 기본 프리셋은 선택모드에서는 보이고, 삭제모드일 때만 숨김
            LazyVGrid(columns: [GridItem(.adaptive(minimum: 60), spacing: 4)], spacing: 10) {
                ForEach(
                    alarmStore.alamPresets.filter { preset in
                        // ✅ 삭제 모드면 기본 프리셋 숨김, 아니라면 전부 보임
                        return !isDeleteMode || !alarmStore.defaultPresets.contains(preset)
                    },
                    id: \.self
                ) { minute in
                    Button {
                        if isDeleteMode {
                            // ✅ 기본 프리셋은 이미 필터되어 있음 → 그대로 삭제 처리
                            if !alarmStore.defaultPresets.contains(minute) {
                                Task { await alarmStore.deletePreset(minute) }
                            }
                        } else {
                            // ✅ 선택/해제 모드
                            if selectedAlarms.contains(minute) {
                                selectedAlarms.remove(minute)
                            } else {
                                selectedAlarms.insert(minute)
                            }
                        }
                    } label: {
                        Text("\(minute)분 전")
                            .font(.subheadline)
                            .padding(.vertical, 8)
                            .padding(.horizontal, 10)
                            .frame(maxWidth: .infinity)
                            .background(
                                isDeleteMode ?
                                Color.red.opacity(0.3) :
                                (selectedAlarms.contains(minute) ? Color.orange : Color.gray.opacity(0.2))
                            )
                            .foregroundColor(.black)
                            .cornerRadius(8)
                    }
                }
            }
            .transition(.opacity.combined(with: .move(edge: .top)))
            .animation(.spring(), value: selectedAlarms)
        }
    }
}
