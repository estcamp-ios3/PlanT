//
//  SettingListView.swift
//  PlanT
//
//  Created by 이지훈 on 10/23/25.
//

import SwiftUI

struct SettingListView: View {
    @State private var appVersion: String =
        Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "알 수 없음" // Info.plist에서 앱 버전

    @State private var showNoticeSheet = false
    @State private var showTermsSheet = false
    @State private var showPrivacySheet = false
    @State private var showContactAlert = false
    @State private var deleteAccountAlert = false

    var body: some View {
        List {
            // MARK: - 공지사항 섹션
            Section(header: Text("앱 정보")) {
                Button { showNoticeSheet = true } label: {
                    SettingRow(title: "공지사항", systemImage: "megaphone.fill")
                }

                HStack {
                    SettingRow(title: "버전 정보", systemImage: "info.circle.fill")
                    Spacer()
                    Text(appVersion)
                        .foregroundColor(.gray)
                        .font(.callout)
                }
            }

            // MARK: - 고객지원 섹션
            Section(header: Text("고객 지원")) {
                Button { showContactAlert = true } label: {
                    SettingRow(title: "문의하기", systemImage: "envelope.fill")
                }
            }

            // MARK: - 정책 섹션
            Section(header: Text("정책 및 약관")) {
                Button { showTermsSheet = true } label: {
                    SettingRow(title: "이용약관", systemImage: "doc.text.fill")
                }
                Button { showPrivacySheet = true } label: {
                    SettingRow(title: "개인정보 처리방침", systemImage: "lock.shield.fill")
                }
            }
            
            // MARK: - 회원 탈퇴
            Section(header: Text("회원 탈퇴")) {
                Button {
                    deleteAccountAlert = true   // ✅ 알럿 띄우기
                } label: {
                    SettingRow(title: "회원 탈퇴", systemImage: "person.crop.circle.badge.minus")
                }
            }
        }
        .clipShape(RoundedRectangle(cornerRadius: cornerRadius3, style: .continuous))
        .listStyle(.insetGrouped)

        // MARK: - 공지사항 시트
        .sheet(isPresented: $showNoticeSheet) {
            NoticeListView()
        }

        // MARK: - 이용약관 시트
        .sheet(isPresented: $showTermsSheet) {
            TermsView(title: "이용약관", content: dummyTerms)
        }

        // MARK: - 개인정보 처리방침 시트
        .sheet(isPresented: $showPrivacySheet) {
            TermsView(title: "개인정보 처리방침", content: dummyPrivacy)
        }

        // MARK: - 문의하기 Alert
        .alert("문의하기", isPresented: $showContactAlert) {
            Button("확인", role: .cancel) { }
        } message: {
            Text("문의: planT_support@teamplant.com")
        }
        
        // MARK: - 회원 탈퇴 Alert (확인/취소)
        .alert("정말 탈퇴하시겠어요?", isPresented: $deleteAccountAlert) {
            Button("취소", role: .cancel) { }
            Button("회원 탈퇴", role: .destructive) {
                // TODO: 실제 탈퇴 로직 연결 (예: AuthStore.deleteAccount())
                // ex) Task { try? await authStore.deleteAccount() }
            }
        } message: {
            Text("계정 및 데이터가 영구적으로 삭제될 수 있습니다.")
        }
    }
}

// MARK: - SettingRow (공통 셀)
private struct SettingRow: View {
    let title: String
    let systemImage: String

    var body: some View {
        HStack(spacing: vertical3) {
            Image(systemName: systemImage)
                .foregroundColor(Color("567319"))
            Text(title)
                .foregroundColor(.primary)
        }
    }
}

// MARK: - 공지사항 뷰 (모달)
private struct NoticeListView: View {
    var body: some View {
        NavigationStack {
            List {
                Text("• 2025-10-20 앱 안정성 업데이트")
                Text("• 2025-10-15 새로운 루틴 추가 기능 출시")
                Text("• 2025-10-10 UI 디자인 개선")
            }
            .navigationTitle("공지사항")
            .navigationBarTitleDisplayMode(.inline)
            .modalToolbar()
        }
    }
}

// MARK: - 약관 / 개인정보 뷰 (모달)
private struct TermsView: View {
    let title: String
    let content: String

    var body: some View {
        NavigationStack {
            ScrollView {
                Text(content)
                    .font(.body)
                    .padding()
                    .multilineTextAlignment(.leading)
            }
            .navigationTitle(title)
            .navigationBarTitleDisplayMode(.inline)
            .modalToolbar()
        }
    }
}

// MARK: - 더미 텍스트
private let dummyTerms = """
이용약관 예시 내용입니다.
1. 본 서비스는 사용자 경험 향상을 목표로 합니다.
2. 사용자는 언제든지 루틴을 수정하거나 삭제할 수 있습니다.
3. 회사는 서비스 품질 향상을 위해 일부 기능을 업데이트할 수 있습니다.
"""

private let dummyPrivacy = """
개인정보 처리방침 예시 내용입니다.
1. 수집 항목: 이메일, 사용자 이름, 루틴 정보 등
2. 수집 목적: 맞춤형 루틴 추천 및 통계 분석
3. 보관 기간: 탈퇴 시까지, 법령에 따라 일정 기간 보관 가능
"""

#Preview {
    NavigationStack {
        SettingListView()
    }
}
