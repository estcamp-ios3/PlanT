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
                    .padding(8)
                    .background(
                        Circle()
                            .fill(.white)
                    )

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
                RoundedRectangle(cornerRadius: 20, style: .continuous)
                    .fill(Color(UIColor.systemGray6))
                    .ignoresSafeArea(edges: .horizontal)
            )

            Button {
                if isEditing {
                    Task {
                        await saveProfileChanges()
                    }
                } else {
                    editedUserName = authStore.userName ?? ""
                    editedNickName = authStore.nickName ?? ""
                }

                withAnimation {
                    isEditing.toggle()
                }
            } label: {
                Text(isEditing ? "완료" : "수정")
                    .font(.system(size: vertical4, weight: .semibold))
                    .foregroundColor(.gray100)
            }
            .plantPrimaryButton()
            .padding(.leading, UIScreen.main.bounds.width <= 375 ? 244 : 260)            .padding(.trailing, vertical4)
            .padding(.top, vertical4)
        }
    }

    // MARK: - 프로필 저장 처리
    private func saveProfileChanges() async {
        authStore.userName = editedUserName
        authStore.nickName = editedNickName

        // ✅ Supabase 업데이트 트리거
        do {
            try await authStore.updateProfile(userName: editedUserName, nickName: editedNickName)
            print("✅ 프로필 업데이트 성공")
        } catch {
            print("❌ 프로필 업데이트 실패:", error.localizedDescription)
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
    func profileInfoStyle() -> some View {
        modifier(ProfileInfoStyle())
    }
}

@ViewBuilder
private func profileInfo(label: String, value: String?) -> some View {
    Text("\(label) : \(value ?? "불러오는 중...")")
        .profileInfoStyle()
}

// ✅ 수정모드 전용 텍스트필드
@ViewBuilder
private func editableField(label: String, text: Binding<String>) -> some View {
    VStack(alignment: .leading, spacing: 4) {
        Text(label)
            .font(.system(size: 14, weight: .semibold))
            .foregroundColor(.gray)
        TextField("\(label) 입력", text: text)
            .textFieldStyle(.roundedBorder)
            .font(.system(size: 18, weight: .heavy))
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
