//
//  AuthStore.swift
//  PlanT
//
//  Created by 이지훈 on 10/14/25.
//

import Foundation
import Combine
import Supabase

// Supabase profiles 디코딩용 모델
struct Profile: Decodable {
    let id: String
    let email: String?
    let userName: String?
    let nickName: String?
    let mate: String?
}

/// 🔑 Supabase 인증 상태를 전역에서 관리
@MainActor
final class AuthStore: ObservableObject {
    // MARK: - Published Properties
    @Published var isAuthenticated = false
    @Published var userEmail: String?
    @Published var userName: String?
    @Published var nickName: String?
    @Published var mate: String?

    private let client = SupabaseManager.shared.client

    // MARK: - Public API

    /// 로그인
    func signIn(email: String, password: String) async throws {
        let result = try await client.auth.signIn(email: email, password: password)

        // 1) 인증 플래그/이메일
        isAuthenticated = true
        userEmail = result.user.email

        // 2) 우선 Auth 메타데이터에서 읽기
        applyMetadata(result.user.userMetadata)

        // 3) 부족하면 profiles에서 보완
        await loadProfileFallback()
        logCurrentUser()
    }

    /// 회원가입 (이미 가입된 이메일이면 자동 로그인 시도)
    func signUp(user: UserAuthModel) async throws {
        guard user.password == user.passwordConfirm else {
            throw AuthError.passwordsDoNotMatch
        }

        // 메타데이터에 mate 포함
        let meta: [String: AnyJSON] = [
            "userName": .string(user.userName),
            "nickName": .string(user.nickName),
            "mate":     .string(user.mate)
        ]

        do {
            let result = try await client.auth.signUp(
                email: user.email,
                password: user.password,
                data: meta
            )

            // 이메일 확인이 필요한 프로젝트일 경우 session이 nil일 수 있음
            if result.session != nil {
                isAuthenticated = true
                userEmail = result.user.email
                applyMetadata(result.user.userMetadata)
                await loadProfileFallback()
                logCurrentUser()
            } else {
                // 이메일 확인 대기 상태
                isAuthenticated = false
                userEmail = result.user.email
                applyMetadata(result.user.userMetadata) // 메타 넣어둠
                print("ℹ️ 회원가입 완료(이메일 확인 대기).")
            }
        } catch {
            // 이미 가입된 사용자 처리: 자동 로그인 시도
            if error.localizedDescription.localizedCaseInsensitiveContains("already registered") {
                print("ℹ️ 이미 가입된 이메일 → 로그인 시도")
                try await signIn(email: user.email, password: user.password)
                return
            }
            throw error
        }
    }

    /// 로그아웃
    func signOut() async {
        do {
            try await client.auth.signOut()
            clearState()
            print("👋 로그아웃 완료")
        } catch {
            print("❌ 로그아웃 실패:", error.localizedDescription)
        }
    }

    /// 앱 재시작 시 세션 복원
    func restoreSession() async {
        if let session = try? await client.auth.session {
            isAuthenticated = true
            userEmail = session.user.email

            // 메타데이터 우선
            applyMetadata(session.user.userMetadata)

            // 부족한 값은 프로필로 보완
            await loadProfileFallback()
            logCurrentUser()
        } else {
            clearState()
            print("❌ 세션 없음")
        }
    }

    // MARK: - Private Helpers

    /// Auth의 userMetadata([String: AnyJSON])를 State에 주입
    private func applyMetadata(_ meta: [String: AnyJSON]) {
        if let v = meta["userName"]?.stringValue { userName = v }
        if let v = meta["nickName"]?.stringValue { nickName = v }
        if let v = meta["mate"]?.stringValue     { mate     = v }
    }

    /// profiles 테이블에서 보완적으로 읽어오기 (RLS 정책 필요)
    private func loadProfileFallback() async {
        guard let uid = try? await client.auth.session.user.id.uuidString else { return }
        do {
            // 1) 쿼리 실행
            let response = try await client
                .from("profiles")
                .select()      // 기본은 "*"
                .eq("id", value: uid)
                .single()
                .execute()

            // 2) data -> Profile 디코딩
            let decoder = JSONDecoder()
            let profile = try decoder.decode(Profile.self, from: response.data)

            // 3) 메타데이터에 없던 값 채우기
            if userName == nil { userName = profile.userName }
            if nickName == nil { nickName = profile.nickName }
            if mate     == nil { mate     = profile.mate }

        } catch {
            // 프로필이 아직 생성되기 전에 읽으면 여기로 올 수 있음 (트리거 비동기 지연)
            print("ℹ️ profiles 보완 로드 실패(무시 가능):", error.localizedDescription)
        }
    }

    private func clearState() {
        isAuthenticated = false
        userEmail = nil
        userName = nil
        nickName = nil
        mate     = nil
    }

    private func logCurrentUser() {
        print("✅ 현재 사용자: \(userEmail ?? "(없음)")")
        print("👤 userName: \(userName ?? "(없음)")")
        print("🏷 nickName: \(nickName ?? "(없음)")")
        print("🐾 mate: \(mate ?? "(없음)")")
    }
}
