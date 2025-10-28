//
//  SettingUserCardView.swift
//  PlanT
//
//  Created by 이지훈 on 10/23/25.
//

import SwiftUI

struct SettingUserCardView: View {
    @EnvironmentObject var authStore: AuthStore
    @StateObject private var viewModel: MypageUserCardViewModel
    @State private var isEditing = false

    // ✅ 수정 중 값 관리용
    @State private var editedUserName: String = ""
    @State private var editedNickName: String = ""
    @State private var editedMate: String = ""

    // 메이트 선택용 상태
    @State private var showMatePicker = false
    @State private var tempSelectedMate: Mate? = nil

    // AuthStore 주입, 내부에서 ViewModel 생성
    init(authStore: AuthStore) {
        _viewModel = StateObject(wrappedValue: MypageUserCardViewModel(authStore: authStore))
    }

    var body: some View {
        ZStack(alignment: .topTrailing) {
            VStack(alignment: .leading, spacing: vertical3) {
                Image(viewModel.model.mateName)
                    .resizable()
                    .scaledToFit()
                    .frame(width: 100, height: 100)
                    .padding(vertical2)
                    .background(Circle().fill(.white))
                    .overlay(alignment: .topTrailing) {
                        if isEditing {
                            Button {
                                tempSelectedMate = Mate(rawValue: authStore.mate ?? "")
                                showMatePicker = true
                            } label: {
                                Image(systemName: "pencil.circle.fill")
                                    .symbolRenderingMode(.hierarchical)
                                    .font(.system(size: 30, weight: .bold))
                                    .foregroundColor(Color("567319"))
                                    .background(
                                        Circle()
                                            .fill(.white)
                                            .frame(width: vertical6, height: vertical6)
                                    )
                                    .offset(x: vertical1, y: -vertical1)
                            }
                            .buttonStyle(.plain)
                            .accessibilityLabel("메이트 변경")
                        }
                    }

                // 프로필 정보
                VStack(alignment: .leading, spacing: vertical2) {
                    // ✅ 이름
                    if isEditing {
                        editableField(label: "이름", text: $editedUserName)
                    } else {
                        profileInfo(label: "이름", value: authStore.userName)
                    }

                    // ✅ 닉네임
                    if isEditing {
                        editableField(label: "닉네임", text: $editedNickName)
                    } else {
                        profileInfo(label: "닉네임", value: authStore.nickName)
                    }

                    // ✅ 이메일 (수정 불가)
                    profileInfo(label: "이메일", value: authStore.userEmail)
                }
            }
            .padding(.leading, vertical3)
            .padding(.vertical, vertical3)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(
                RoundedRectangle(cornerRadius: cornerRadius3, style: .continuous)
                    .fill(Color(UIColor.systemGray6))
                    .ignoresSafeArea(edges: .horizontal)
            )

            Button {
                if isEditing {
                    Task { await saveProfileChanges() }
                } else {
                    editedUserName = authStore.userName ?? ""
                    editedNickName = authStore.nickName ?? ""
                    editedMate = authStore.mate ?? ""
                }
                withAnimation { isEditing.toggle() }
            } label: {
                Text(isEditing ? "완료" : "수정")
                    .font(.system(size: vertical4, weight: .semibold))
                    .foregroundColor(.gray100)
            }
            .plantPrimaryButton()
            .padding(.leading, { // 해상도별 '수정' 버튼 분기처리
                let width = UIScreen.main.bounds.width
                switch width {
                case ..<376:       // iPhone SE / mini (375 이하)
                    return 240
                case 376..<414:    // 일반 (기본형 모델 390~402)
                    return 270
                default:           // 대형 (플러스, 맥스 모델 414~430 이상)
                    return 300
                }
            }())
            .padding(.trailing, vertical4)
            .padding(.top, vertical4)
        }
        .sheet(isPresented: $showMatePicker) {
            MatePickerSheet(
                selectedMate: $tempSelectedMate,
                onDone: {
                    if let sel = tempSelectedMate {
                        authStore.mate = sel.rawValue
                    }
                }
            )
            .presentationDetents([.fraction(0.35), .medium])
            .presentationDragIndicator(.visible)
        }
    }

    // MARK: - 프로필 저장 처리
    private func saveProfileChanges() async {
        authStore.userName = editedUserName
        authStore.nickName = editedNickName
        do {
            try await authStore.updateProfile(userName: editedUserName, nickName: editedNickName, mate: authStore.mate ?? "")
            print("✅ 프로필 업데이트 성공")
        } catch {
            print("❌ 프로필 업데이트 실패:", error.localizedDescription)
        }
    }
}

// MARK: - 내부 전용: 메이트 선택 시트
private struct MatePickerSheet: View {
    @Environment(\.dismiss) private var dismiss
    @Binding var selectedMate: Mate?
    var onDone: () -> Void

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                MateView(selectedMate: $selectedMate)
                    .padding(.horizontal, vertical2)
                    .padding(.top, vertical2)

                Spacer(minLength: 0)
            }
            .navigationTitle("메이트 선택")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("취소") { dismiss() }
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("완료") {
                        onDone()
                        dismiss()
                    }
                    .disabled(selectedMate == nil)
                }
            }
        }
    }
}

// MARK: - 재사용 가능한 스타일 & 헬퍼
private struct ProfileInfoStyle: ViewModifier {
    func body(content: Content) -> some View {
        content
            .font(.system(size: vertical5, weight: .heavy))
            .foregroundColor(.primary)
            .lineLimit(1)
            .minimumScaleFactor(0.85)
    }
}

private extension View {
    func profileInfoStyle() -> some View { modifier(ProfileInfoStyle()) }
}

@ViewBuilder
private func profileInfo(label: String, value: String?) -> some View {
    Text("\(label) : \(value ?? "불러오는 중...")")
        .profileInfoStyle()
}

@ViewBuilder
private func editableField(label: String, text: Binding<String>) -> some View {
    VStack(alignment: .leading, spacing: vertical1) {
        Text(label)
            .font(.system(size: vertical4, weight: .semibold))
            .foregroundColor(.gray)
        TextField("\(label) 입력", text: text)
            .textFieldStyle(.roundedBorder)
            .font(.system(size: vertical5, weight: .heavy))
            .padding(.trailing, 40)
    }
}

// MARK: - Preview
#Preview {
    let mock = AuthStore()
    mock.userName = "테스트"
    mock.nickName = "Test"
    mock.mate = "MrPurr"
    mock.userEmail = "test@plant.com"

    return NavigationStack {
        SettingUserCardView(authStore: mock)
            .environmentObject(mock)
            .padding()
            .background(Color.white)
    }
}
