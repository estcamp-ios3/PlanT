//
//  ChecklistCardView.swift
//  PlanT
//
//  Created by APPLE on 2025-10-13.
//

import SwiftUI

struct TodoListCardView: View {
    @Binding public var group: TodoListCard
    @State private var deleteDialog = false
    @State private var selectedItem: TodoListCard? = nil
    public let onDelete: () -> Void

    public var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            // 체크리스트 항목들이 들어가는 영역
            NavigationStack {

                VStack(alignment: .leading, spacing: 12) {
                    ForEach($group.items) { item in
                        TodoListCheckItemView(item: item)
                    }

                    // 더보기(...) 표시 90도 돌여서 세로로 보여준다
                    if group.items.count > 3 {
                        HStack {
                            Image(systemName: "ellipsis")
                                .rotationEffect(.degrees(90))
                                .foregroundColor(.gray)
                        }
                        .frame(maxWidth: .infinity, alignment: .center)
                        .padding(.top, 4)
                    }
                    Spacer()
                }
                .padding()
                .background(Color.white)
                .cornerRadius(10)
                .overlay(
                    RoundedRectangle(cornerRadius: 10)
                        .stroke(Color.gray.opacity(0.3), lineWidth: 1)
                )
                //            .frame(minWidth: 180, maxWidth: 180, minHeight: 220, alignment: .top)
                .frame(minWidth: 180, maxWidth: 180, minHeight: 220, maxHeight: 220, alignment: .top)
                .background(Color.gray.opacity(0.2))
                .overlay(
                    Button(action: {
                        // 삭제 액션
                        print("삭제 버튼 클릭")
                        //                    onDelete()
                        deleteDialog.toggle()
                    }) {
                        Image(systemName: "xmark.circle.fill")
                        //                        .foregroundColor(.red)
                            .background(Color.white.clipShape(Circle()))
                    }
                        .padding(8)
                    , alignment: .topTrailing  // 오른쪽 상단
                )
                .confirmationDialog(
                    "삭제하시겠습니까?",
                    isPresented: $deleteDialog,
                    titleVisibility: .visible
                ) {
                    Button("삭제", role: .destructive) {
                        withAnimation {
                            onDelete()
                        }
                    }
                    Button("취소", role: .cancel) { }
                }
            }
            .navigationDestination(item: $selectedItem) { item in
                TodoListDetailView(item: group)
            }

            // 카드 제목
            Text(group.title)
                .font(.headline)
                .lineLimit(1)
        }
        .contextMenu {
            // 1. 수정 버튼을 만들기

            // 2. 삭제 버튼
            Button(role: .destructive) {
                // 삭제 버튼을 누르면 콜백 클로저 실행
                onDelete()
            } label: {
                Label("삭제", systemImage: "trash")
            }
        }
    }
}
