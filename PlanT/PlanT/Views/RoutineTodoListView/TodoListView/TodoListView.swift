//
//  TodoListView.swift
//  PlanT
//
//  Created by APPLE on 2025-09-28.
//

import SwiftUI

struct TodoListView: View {
    @State private var checklistGroups: [TodoListCard] = [
        TodoListCard(title: "iOS 3차 앱개발 프..", items: [
            TodoListCheckItem(text: "와이어 프레임", isChecked: false),
            TodoListCheckItem(text: "기능명세", isChecked: false),
            TodoListCheckItem(text: "화면 플로우(사용자 시나...", isChecked: false),
            TodoListCheckItem(text: "아이디어", isChecked: true),
            TodoListCheckItem(text: "ADS", isChecked: true)
        ]),
        TodoListCard(title: "장보기", items: [
            TodoListCheckItem(text: "대파 1단", isChecked: false),
            TodoListCheckItem(text: "한우 1++ 안심 스테이크...", isChecked: false)
        ]),
        TodoListCard(title: "iOS 3차 앱개발 프..", items: [
            TodoListCheckItem(text: "와이어 프레임", isChecked: false),
            TodoListCheckItem(text: "기능명세", isChecked: false),
            TodoListCheckItem(text: "화면 플로우(사용자 시나...", isChecked: false),
            TodoListCheckItem(text: "아이디어", isChecked: true),
            TodoListCheckItem(text: "ADS", isChecked: true)
        ]),
        TodoListCard(title: "장보기", items: [
            TodoListCheckItem(text: "대파 1단", isChecked: false),
            TodoListCheckItem(text: "한우 1++ 안심 스테이크...", isChecked: false)
        ]),
        TodoListCard(title: "iOS 3차 앱개발 프..", items: [
            TodoListCheckItem(text: "와이어 프레임", isChecked: false),
            TodoListCheckItem(text: "기능명세", isChecked: false),
            TodoListCheckItem(text: "화면 플로우(사용자 시나...", isChecked: false),
            TodoListCheckItem(text: "아이디어", isChecked: true),
            TodoListCheckItem(text: "ADS", isChecked: true)
        ]) // 마지막 아이템을 홀수 개로 만들어 테스트
    ]

    @State private var isShowingAddGroupAlert = false
    @State private var newGroupTitle = ""

    // 그룹을 삭제하는 함수
    private func deleteGroup(at offsets: IndexSet) {
        checklistGroups.remove(atOffsets: offsets)
    }

    // ID를 기반으로 그룹을 삭제하는 함수
    private func deleteGroup(with id: UUID) {
        checklistGroups.removeAll { $0.id == id }
    }

    // 그리드 행의 개수를 계산합니다. (전체 아이템 개수를 2로 나눈 올림 값)
    private var rowCount: Int {
        (checklistGroups.count + 1) / 2
    }

    public var body: some View {
        ZStack(alignment: .bottomTrailing) {
            // 전체 배경색 설정
            Color(UIColor.systemGroupedBackground)
                .ignoresSafeArea()

            // 스크롤 가능한 뷰
            ScrollView {
                // 수직으로 행과 구분선을 쌓기 위한 VStack
                NavigationStack {
                    VStack(spacing: 24) {
                        // 계산된 행의 수만큼 반복
                        ForEach(0..<rowCount, id: \.self) { rowIndex in
                            // 각 행은 수평으로 아이템을 나열하는 HStack
                            HStack {
                                // 행의 첫 번째 아이템 인덱스 계산
                                let firstItemIndex = rowIndex * 2
                                // 해당 인덱스의 아이템에 대한 뷰 생성
                                TodoListCardView(group: $checklistGroups[firstItemIndex]) {
                                    deleteGroup(with: $checklistGroups[firstItemIndex].id)
                                }

                                // 행의 두 번째 아이템이 존재하는지 확인
                                let secondItemIndex = firstItemIndex + 1
                                if secondItemIndex < checklistGroups.count {
                                    // 존재하면 두 번째 아이템에 대한 뷰 생성
                                    TodoListCardView(group: $checklistGroups[secondItemIndex]) {
                                        deleteGroup(with: $checklistGroups[secondItemIndex].id)
                                    }
                                } else {
                                    // 아이템 개수가 홀수라 마지막 행에 아이템이 하나뿐인 경우,
                                    // 공간을 채워 왼쪽 정렬을 유지
                                    Spacer()
                                }
                            }

                            // 마지막 행이 아닐 경우에만 구분선 추가
                            if rowIndex < rowCount - 1 {
                                Rectangle()
                                    .frame(height: 13)
                                //                                .foregroundColor(Color.gray.opacity(0.3))
                                    .foregroundColor(.clear)
                                    .padding(.vertical, 8)
                            }
                        }
                    }
//                    .navigationDestination(item: $selectedItem) { item in
//                        ChecklistDetailView(item: item)
//                    }
                }
                .padding()
            }

//            // 플로팅 액션 버튼 (오른쪽 하단)
//            Button(action: {
//                self.isShowingAddGroupAlert.toggle()
//            }) {
//                Image(systemName: "plus")
//                    .font(.title.weight(.semibold))
//                    .padding()
////                    .background(Color.orange)
//                    .background(Color.clear)
//                    .foregroundColor(.green)
//                    .clipShape(Circle())
//                    .shadow(radius: 4, x: 0, y: 4)
//            }
//            .padding()
        }
        .alert("할일 그룹 생성", isPresented: $isShowingAddGroupAlert) {
            // Alert 내부에 TextField 추가
            TextField("그룹 이름", text: $newGroupTitle)

            // "생성" 버튼
            Button("생성") {
                // onChange 대체
            }
            .disabled(newGroupTitle.isEmpty)

            // "취소" 버튼
            Button("취소", role: .cancel) {
                newGroupTitle = ""
            }
        } message: {
            // Alert의 부가 설명 메시지
            Text("새로운 할 일 그룹의 이름을 입력해주세요.")
        }
        .onChange(of: isShowingAddGroupAlert) { oldValue, newValue in
            // alert가 닫힐 때 (isShowingAddGroupAlert가 false가 될 때)
            if oldValue == true && newValue == false {
                if !newGroupTitle.isEmpty {
                    let newGroup = TodoListCard(title: newGroupTitle, items: [])
                    checklistGroups.insert(newGroup, at: 0)
                }
            }
            // 작업이 끝났으니 텍스트 필드를 초기화합니다.
            newGroupTitle = ""
        }
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button(action: {
                    self.isShowingAddGroupAlert.toggle()
                }) {
                    Image(systemName: "plus")
                        .font(.body.weight(.semibold))
                        .foregroundColor(.green)
                        .shadow(radius: 4, x: 0, y: 4)
                }
                .padding(.trailing)
                .offset(x: 10)
            }
        }
    }
}

#Preview {
    TodoListView()
}
