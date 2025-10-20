//
//  AlanAIService.swift
//  PlanT
//

import Foundation
import AlanAI

/// AlanAI SDK를 감싸는 서비스
@MainActor
final class AlanAIService {

    static let shared = AlanAIService()

    private let client: AlanAI
    private var didPrewarm = false

    private init() {
        // 자신의 키로 교체
        let clientId = "89a3432c-e591-4751-9b97-2d4fc2d9fa6a"
        self.client = AlanAI(clientID: clientId)
    }

    /// 최초 1회 프리워밍
    func prewarmIfNeeded() async {
        guard !didPrewarm else { return }
        didPrewarm = true
        do {
            _ = try await client.question(query: "ping")
            print("✅ AlanAI prewarm success")
        } catch {
            didPrewarm = false // 실패 시 다음에 다시 시도 가능
            print("❌ AlanAI prewarm error:", error.localizedDescription)
        }
    }

    /// 기존 간단 버전(문자열만 반환)
    func ask(question: String) async -> String {
        do {
            let response: AlanResponse? = try await client.question(query: question)
            return response?.content ?? "N/A"
        } catch {
            print("❌ AlanAI ask error:", error.localizedDescription)
            return "❌ 오류: \(error.localizedDescription)"
        }
    }

    /// 🔎 디버그용: 에러/타이밍/원문 응답 로그까지 함께 반환
    /// - Returns: (answer: String, errorDescription: String?, metaLog: String)
    func askDebug(question: String) async -> (String, String?, String) {
        let start = Date()
        do {
            let response: AlanResponse? = try await client.question(query: question)
            let elapsed = String(format: "%.2fs", Date().timeIntervalSince(start))
            let content = response?.content ?? "N/A"

            let meta =
            """
            [AlanAI DEBUG]
            • elapsed: \(elapsed)
            • content length: \(content.count)
            • preview: \(content.prefix(140))
            """
            return (content, nil, meta)
        } catch {
            let elapsed = String(format: "%.2fs", Date().timeIntervalSince(start))
            let desc = (error as NSError).description
            let meta =
            """
            [AlanAI DEBUG]
            • elapsed: \(elapsed)
            • error: \(error)
            • localized: \(error.localizedDescription)
            • nsError: \(desc)
            """
            return ("", error.localizedDescription, meta)
        }
    }
}
