//
//  AlarmSectionView.swift
//  PlanT
//
//  Created by 박성관 on 11/4/25.
//

import SwiftUI

struct AlarmSectionView: View {
    @ObservedObject var viewModel: AlarmSectionViewModel

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            headerSection()
            
            if viewModel.showAlarms {
                presetsGridSection()
                    .padding(.top, 4)
            }
        }
        .padding(.horizontal, 16)
    }
    
    // MARK: - Header Section (알림, 토글, 삭제모드)
    private func headerSection() -> some View {
        HStack {
            Text("알림")
                .font(.subheadline).bold()
                .themedTextColor()
            
            Spacer()
            
            Text("맞춤 알림 생성, 삭제")
                .font(.footnote).bold()
                .foregroundColor(.gray.opacity(0.6))
            
            if viewModel.isDeleteMode {
                Button("완료") { viewModel.isDeleteMode = false }
                    .font(.subheadline).bold()
                    .foregroundColor(.red)
            } else {
                Button(role: .destructive) {
                    viewModel.isDeleteMode = true
                } label: {
                    Image(systemName: "pencil.tip.crop.circle.badge.minus")
                        .font(.system(size: 20, weight: .bold))
                        .padding(6)
                }
            }
            
            Toggle("", isOn: $viewModel.showAlarms)
                .labelsHidden()
                .toggleStyle(CustomToggleStyle())
        }
    }
    
    private func gridColumns(for width: CGFloat) -> [GridItem] {
        let itemWidth: CGFloat = 70
        let spacing: CGFloat = 8
        let columnCount = max(Int((width + spacing) / (itemWidth + spacing)),2)
        return Array(repeating: GridItem(.flexible(), spacing: spacing), count: columnCount)
    }
    
    
    // MARK: - Preset Buttons Grid Section
    private func presetsGridSection() -> some View {
        GeometryReader { geo in
            let columns = Array(repeating: GridItem(.flexible(), spacing: 10), count: 4)

            LazyVGrid(columns: columns, spacing: 10) {
                ForEach(viewModel.filteredPresets, id: \.self) { minute in

                    Button {
                        if viewModel.isDeleteMode {
                            viewModel.deletePresets(minute)
                        } else {
                            viewModel.toggleAlarm(minute)
                        }
                    } label: {
                        Text("\(minute)분 전")
                            .font(.subheadline)
                            .padding(.vertical, 8)
                            .padding(.horizontal, 10)
                            .frame(maxWidth: .infinity)
                            .background(
                                viewModel.isDeleteMode ?
                                    Color.red.opacity(0.3) :
                                    viewModel.isSelected(minute: minute) ?
                                        Color("BrandAccent") : Color("BrandSecondary")
                            )
                            .foregroundColor(.black)
                            .cornerRadius(30)
                    }
                }
                
                if viewModel.canAddMorePreset {
                    Button {
                        viewModel.showAddPresetSheet()
                    } label: {
                        Image(systemName: "plus")
                            .font(.subheadline)
                            .padding(8)
                            .frame(maxWidth: .infinity, minHeight: 36)
                            .background(Color.gray.opacity(0.2))
                            .clipShape(Circle())
                    }
                }
            }
        }
        .frame(height: 130)
    }
}
