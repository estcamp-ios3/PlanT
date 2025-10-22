//
//  GenericStepView.swift
//  PlanT
//
//  Created by catharina J on 9/30/25.
//

import SwiftUI
import Foundation

struct GenericStepView: View {
    @ObservedObject var vm: RoutineSurveyViewModel
    let step: SurveyStep
    
    @State private var showCustomField = false
    @State private var customText = ""
    @FocusState private var customFocused: Bool
    
    
    var body: some View {
        // Compute displayOptions outside of the ViewBuilder to avoid returning Void in a ViewBuilder context
        let displayOptions: [Option] = vm.options(for: step)
        
        return Group {
            VStack(alignment: .leading, spacing: vertical1) {
                
                if vm.currentIndex > 0 {
                    Text(vm.progressiveSentence)
                        .font(.title)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .transition(.opacity.combined(with: .move(edge: .bottom)))
                        .animation(.easeInOut(duration: 0.4), value: vm.currentIndex)
                        .padding(.bottom, 4)
                        .bold()
                }
                
                if step.id == "health_type", let catTitle = vm.selectedCategoryTitle {
                    // 선택된 카테고리 제목만 PlantPrimary 컬러 적용
                    (
                        Text(catTitle)
                            .foregroundStyle(Color("BrandPrimary"))
                            .bold()
                        + Text("을(를) 선택하셨어요!")
                            .foregroundStyle(Color("Gray900"))
                    )
                    .font(.title)
                    .bold()
                } else if let m = vm.message(for: step) {
                    Text(m)
                        .font(.title)
                        .foregroundStyle(Color("Gray900"))
                        .bold()
                }
               
                Text(step.title)
                    .font(.title)
                    .bold()
                    .foregroundStyle(Color("Gray900"))
                
//                let prev = vm.priorAnswers()
//                if !prev.isEmpty {
//                   
//                    let sentence = prev.map { $0.answer }.joined(separator: " → ")
//                   
//                    Text(sentence)
//                        .font(.subheadline)
//                        .foregroundColor(Color("Gray900"))
//                        .padding(10)
//                        .background(Color("BrandSecondary")).opacity(0.3)
//                        .cornerRadius(12)
//                        .frame(maxWidth: .infinity, alignment: .leading)
//                        .transition(.opacity.combined(with: .move(edge: .bottom)))
//                        .animation(.easeInOut(duration: 0.4), value: sentence)
//                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)
            
            switch step.kind {
            case .single, .multiple, .confirm:
                VStack(spacing: 10) {
                    ForEach(displayOptions) { opt in
                        OptionRow(option: opt,
                                  selected: vm.isSelected(opt) || (opt.id == "custom_input" && showCustomField),  //UI 상태로만 선택 표시
                                  action: {
                            if opt.id == "custom_input" {
                                // 직접입력 노출 (어떤 step이든 공통)
                                showCustomField = true
                            } else {
                                // 일반 옵션 선택 시 직접입력 숨김
                                showCustomField = false
                                customText = ""
                                vm.toggle(opt)
                            }
                        })
                    }
                    // 2) 인라인 TextField (직접 입력)
                    if showCustomField {
                        VStack(alignment: .leading, spacing: 8) {
                            if step.id == "duration" {
                                Text("원하는 시간을 분 단위로 입력하세요")
                                    .font(.footnote)
                                    .foregroundStyle(.secondary)
                                TextField("예: 25", text: $customText)
                                    .keyboardType(.numberPad)
                                    .submitLabel(.done)
                                    .focused($customFocused)
                                    .onSubmit {
                                        let t = customText.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)
                                        if let n = Int(t), n > 0 {
                                            vm.selectValue(for: step.id, value: "\(n)분")
                                            customFocused = false
                                        }
                                    }
                                    .onChange(of: customText) { _, new in
                                        let t = new.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)
                                        if let n = Int(t), n > 0 {
                                            vm.selectValue(for: step.id, value: "\(n)분")
                                        } else {
                                            vm.selectValue(for: step.id, value: "")
                                        }
                                    }
                                    .textFieldStyle(RoundedBorderTextFieldStyle())
                            }
                        }
                        .padding(.top, 4)
                        .id("__custom_input__\(step.id)")
                    }
                    
                }
                // ✅ 콘텐츠가 짧으면 화면의 남는 높이를 채우고, 맨 아래에 정렬
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .bottom)
                
            case .summary:
                EmptyView()
//                Text(vm.summaryText)
//                    .font(.callout)
//                    .padding()
//                    .frame(maxWidth: .infinity, alignment: .leading)
//                    .background(Color(.secondarySystemBackground), in: RoundedRectangle(cornerRadius: 12))
//                    .frame(maxWidth: .infinity)
            default: EmptyView()
            }
            
        }
//        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
        .onChange(of: step.id) { oldValue, newValue in
            showCustomField = false
            customText = ""
        }
        .onChange(of: showCustomField) { _, visible in
            if visible {
                // 다음 런루프에서 포커스 부여 및 현재 텍스트로 값 반영
                DispatchQueue.main.async {
                    customFocused = true
                    let t = customText.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)
                    if step.id == "duration" {
                        if let n = Int(t), n > 0 {
                            vm.selectValue(for: step.id, value: "\(n)분")
                        } else {
                            vm.selectValue(for: step.id, value: "")
                        }
                    }
                }
            } else {
                // 숨길 때 포커스 해제
                customFocused = false
            }
        }
    }
}

