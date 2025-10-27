//
//  AuthStore.swift
//  PlanT
//
//  Created by 이지훈 on 10/14/25.
//

import Foundation
import Combine
import Supabase

// MARK: - Supabase 프로필 모델
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
    
    // MARK: - 의존성
    private let supabaseManager = SupabaseManager()
    
    // MARK: - 로그인
    func signIn(email: String, password: String) async throws {
        let user = try await supabaseManager.signIn(email: email, password: password)
        
        isAuthenticated = true
        userEmail = user.email
        applyUserdata(user)
        await loadProfileFallback()
        logCurrentUser()
    }
    
    // MARK: - 회원가입
    func signUp(user: UserAuthModel) async throws {
        do {
            try await supabaseManager.signUp(user: user)
            print("✅ 회원가입 성공")
        } catch {
            print("❌ 회원가입 실패:", error.localizedDescription)
            throw error
        }
    }
    
    // MARK: - 로그아웃
    func signOut() async {
        do {
            try await supabaseManager.signOut()
            clearState()
            print("👋 로그아웃 완료")
        } catch {
            print("❌ 로그아웃 실패:", error.localizedDescription)
        }
    }
    
    // MARK: - 프로필 업데이트
    func updateProfile(userName: String, nickName: String, mate: String) async throws {
        guard let session = try? await supabaseManager.restoreSession() else { return }
        let uid = session.user.id.uuidString
        
        try await supabaseClient
            .from("profiles")
            .update([
                "userName": userName,
                "nickName": nickName,
                "mate": mate
            ])
            .eq("id", value: uid)
            .execute()
        
        // 로컬 상태 즉시 반영
        self.userName = userName
        self.nickName = nickName
        self.mate = mate
    }
    
    // MARK: - 세션 복원
    func restoreSession() async {
        do {
            if let session = try await supabaseManager.restoreSession() {
                isAuthenticated = true
                userEmail = session.user.email
                let meta = session.user.userMetadata
                applyMetadata(meta)
                await loadProfileFallback()
                logCurrentUser()
            } else {
                clearState()
                print("❌ 세션 없음")
            }
        } catch {
            clearState()
            print("❌ 세션 복원 실패:", error.localizedDescription)
        }
    }
    
    // MARK: - Private Helpers
    
    private func applyMetadata(_ meta: [String: AnyJSON]) {
        if let v = meta["userName"]?.stringValue { userName = v }
        if let v = meta["nickName"]?.stringValue { nickName = v }
        if let v = meta["mate"]?.stringValue     { mate     = v }
    }
    
    private func applyUserdata(_ user: User) {
        userName = user.userName
        nickName = user.nickName
        mate     = user.mate
    }
    
    private func loadProfileFallback() async {
        do {
            if let session = try await supabaseManager.restoreSession() {
                let uid = session.user.id.uuidString
                let profile = try await supabaseManager.loadProfileFallback(for: uid)
                
                userName = profile.userName
                nickName = profile.nickName
                mate = profile.mate
            }
        } catch {
            print("ℹ️ profiles 보완 로드 실패:", error.localizedDescription)
        }
    }
    
    private func clearState() {
        isAuthenticated = false
        userEmail = nil
        userName = nil
        nickName = nil
        mate = nil
    }
    
    private func logCurrentUser() {
        print("✅ 현재 사용자: \(userEmail ?? "(없음)")")
        print("👤 userName: \(userName ?? "(없음)")")
        print("🏷 nickName: \(nickName ?? "(없음)")")
        print("🐾 mate: \(mate ?? "(없음)")")
    }
}
