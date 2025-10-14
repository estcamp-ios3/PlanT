//
//  TmpContentView.swift
//  PlanT
//
//  Created by APPLE on 2025-10-13.
//

import SwiftUI

// 1. 데이터 모델 (예시)
struct TmpChecklistItem: Identifiable, Hashable {
    let id = UUID()
    let title: String
    let description: String
}

// 2. 메인 화면
struct TmpContentView: View {
    // 선택된 아이템을 추적하는 State 변수
    @State private var selectedItem: TmpChecklistItem? = nil

    // 샘플 데이터
    let items = [
        TmpChecklistItem(title: "체크리스트 1", description: "설명 1"),
        TmpChecklistItem(title: "체크리스트 2", description: "설명 2"),
        TmpChecklistItem(title: "체크리스트 3", description: "설명 3")
    ]

    var body: some View {
        NavigationStack {
            VStack(spacing: 24) {
                ForEach(items) { item in
                    HStack {
                        TmpChecklistCardView(item: item)
                            .onTapGesture {
                                // 카드 클릭 시 선택된 아이템 저장
                                selectedItem = item
                            }
                    }
                }
            }
            .padding()
            // 네비게이션 목적지 설정
            .navigationDestination(item: $selectedItem) { item in
                TmpChecklistDetailView(item: item)
            }
            .navigationTitle("체크리스트")
        }
    }
}

// 3. 카드 뷰 (예시)
struct TmpChecklistCardView: View {
    let item: TmpChecklistItem

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(item.title)
                .font(.headline)
            Text(item.description)
                .font(.subheadline)
                .foregroundColor(.gray)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding()
        .background(Color.white)
        .cornerRadius(12)
        .shadow(radius: 2)
    }
}

// 4. 상세 화면
struct TmpChecklistDetailView: View {
    let item: TmpChecklistItem

    var body: some View {
        VStack(spacing: 20) {
            Text(item.title)
                .font(.largeTitle)
                .fontWeight(.bold)

            Text(item.description)
                .font(.body)

            Spacer()
        }
        .padding()
        .navigationTitle("상세보기")
        .navigationBarTitleDisplayMode(.inline)
    }
}

#Preview {
    TmpContentView()
}
