//
//  RoutineDateView.swift
//  PlanT
//
//  Created by catharina J on 10/14/25.
//
import SwiftUI

struct RoutineDateView: View {
    // 외부에서 데이터 제어
    @Binding var isEnabled: Bool       // 수정가능
        @Binding var showDateHeader: Bool   // 헤더 사용
        @Binding var useDate: Bool          // “날짜 사용” 토글
        @Binding var isAllDay: Bool         // “종일”
        @Binding var hasEnd: Bool           // “종료일”
        @Binding var startDate: Date        // 시작(날짜+시간)
        @Binding var endDate: Date          // 종료(날짜+시간)
    
    @State private var showPicker = false
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            // 1) 상단 토글
            if showDateHeader {
                HStack {
                    Text("날짜 사용")
                        .font(.headline)
                        .themedTextColor()

                    Spacer()
                    Toggle("", isOn: $useDate)
                        .labelsHidden()
                        .toggleStyle(CustomToggleStyle())
                }
                .padding(.vertical, 4)
            }
            
            Group{
                // 2) 토글 OFF면 끝
                if !useDate {
                    Divider()
                }
                //만약 토글이 숨겨져 있으면, useDate가 항상 true인 셈으로 처리
                if !showDateHeader || useDate {
                    // 3) 체크 옵션들
                    HStack(spacing: 16) {
                        CheckLabelView(isChecked: $hasEnd, label: "종료일")
                        CheckLabelView(isChecked: $isAllDay, label: "하루종일")
                    }
                    .padding(.top, 2)
                    
                    // 4) 입력필드
                    //    - 종일이면 시간 피커 숨기거나 비활성
                    //    - 종료일이면 End 필드 노출
                    HStack(spacing: 12) {
                        dateBlock(title: "시작", date: $startDate, showTime: !isAllDay)
                            .frame(maxWidth: .infinity)
                        
                        if hasEnd {
                            Image("ArrowDate")
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                                .frame(width:24)
                            
                            // 종료가 시작보다 빠르면 시작과 동일로 보정 (간단 보호)
                            dateBlock(title: "종료", date: $endDate, showTime: !isAllDay)
                                .frame(maxWidth: .infinity)
                               
                                .onChange(of: startDate) { oldValue, newValue in
                                    guard newValue != oldValue else { return }
                               print(startDate)
                                    if endDate < newValue { endDate = newValue }
                                }
                                .onChange(of: endDate) { oldValue, newValue in
                                    if newValue < startDate { endDate = startDate }
                                }
                        }
                    }
                    .transition(.opacity.combined(with: .move(edge: .top)))
                }
            }
        }
        .animation(.easeInOut, value: useDate)
        .animation(.easeInOut, value: isAllDay)
        .animation(.easeInOut, value: hasEnd)
        .frame(maxWidth:.infinity)
    }
    
    // MARK: - 단일 블록 (날짜 + 선택적으로 시간)
    @ViewBuilder
    private func dateBlock(title: String, date: Binding<Date>, showTime: Bool) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Button {
                    showPicker = true
                } label: {
                    Text(date.wrappedValue.formatted(date: .abbreviated, time: .omitted))
                        .padding(.vertical, vertical2)
                        .padding(.horizontal, vertical3)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .background(isEnabled ? Color("Gray100"): Color(.systemBackground) , in: RoundedRectangle(cornerRadius: cornerRadius3))
                        .themedTextColor()

                }
                .sheet(isPresented: $showPicker) {
                    VStack {
                        DatePicker("", selection: date, displayedComponents: .date)
                            .datePickerStyle(.graphical)   // 전체 달력 표시
                            .labelsHidden()
                        Button("완료") { showPicker = false }
                            .padding(.top)
                    }
                    .padding()
                    .presentationDetents([.medium])
                }
                .buttonStyle(.plain)
                .disabled(!isEnabled)
            
            // 시간 (휠)
            if showTime || !isAllDay {
                TimePickerField(date: date, isEnabled: $isEnabled) // ← 탭 시트로 휠 표시
            }
        }
        .frame(maxWidth: .infinity)
    }
}

