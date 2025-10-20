//
//  AlanAIService.swift
//  PlanT
//
//  Created by Team PlanT on 2025-10-20.
//

import Foundation
import AlanAI

@MainActor
final class AlanAIService {

    static let shared = AlanAIService()

    private let client: AlanAI
    private var didPrewarm = false

    private init() {
        let clientId = "34a0ba9f-c677-4406-815a-47b88e791679" // Alan 키
        self.client = AlanAI(clientID: clientId)
    }

    // MARK: - Warmup
    func prewarmIfNeeded() async {
        guard !didPrewarm else { return }
        didPrewarm = true
        do {
            _ = try await client.question(query: "ping")
            print("✅ AlanAI prewarm success")
        } catch {
            print("⚠️ AlanAI prewarm failed:", error.localizedDescription)
        }
    }

    // MARK: - Low-level
    func ask(question: String) async -> String {
        do {
            let res: AlanResponse? = try await client.question(query: question)
            return res?.content ?? ""
        } catch {
            print("❌ AlanAI ask error:", error.localizedDescription)
            return ""
        }
    }

    func askDebug(question: String) async -> (rawAnswer: String, errorDesc: String?, metaLog: String) {
        var meta = """
        ── AlanAI Debug ─────────────────
        prompt.length = \(question.count)
        date = \(Date())
        """
        do {
            let res: AlanResponse? = try await client.question(query: question)
            let raw = res?.content ?? ""
            meta += "\nresult.length = \(raw.count)"
            meta += "\n────────────────────────────"
            return (raw, nil, meta)
        } catch {
            let desc = error.localizedDescription
            meta += "\nerror = \(desc)"
            meta += "\n────────────────────────────"
            return ("", desc, meta)
        }
    }

    // MARK: - High-level: 여러 루틴 한 번에 한 줄 코멘트 생성
    struct OneLineItem: Codable {
        let title: String
        let total: Int
        let done: Int
    }

    /// 여러 루틴을 한 번에 한 줄 응원으로 생성
    func generateOneLineComments(for items: [OneLineItem]) async -> [String] {
        guard !items.isEmpty else { return [] }

        let json = (try? String(data: JSONEncoder().encode(items), encoding: .utf8)) ?? "[]"

        let prompt = """
        아래 JSON 배열에는 각 루틴의 이름(title), 전체 목표 횟수(total), 현재까지 완료한 횟수(done)가 들어 있습니다.
        각 루틴마다 현재 상황에 어울리는 짧은 한국어 응원 문장을 만들어주세요.

        요구사항:
        - 루틴마다 정확히 한 줄만 출력하세요.
        - 문장은 25자 이내로 간결하게 작성하세요.
        - 제목(title)이나 숫자 나열은 피하고, 자연스러운 응원/격려/축하 메시지로만 구성하세요.
        - 출력은 JSON/마크다운/설명 없이, 루틴 개수만큼 한 줄씩 나열하세요.
        - 달성 상태라면 축하 뉘앙스, 아직 진행 중이라면 격려 뉘앙스로 자연스럽게 표현하세요.

        JSON 데이터:
        \(json)
        """

        let raw = await ask(question: prompt)
        return normalizedLines(from: raw)
    }

    // MARK: - 정규화 유틸
    private func normalizedLines(from raw: String) -> [String] {
        raw
            .replacingOccurrences(of: "```json", with: "")
            .replacingOccurrences(of: "```", with: "")
            .components(separatedBy: .newlines)
            .map { $0.trimmingCharacters(in: .whitespaces) }
            .filter {
                !$0.isEmpty &&
                !$0.hasPrefix("{") &&
                !$0.hasPrefix("}") &&
                !$0.hasPrefix("[") &&
                !$0.hasPrefix("]")
            }
    }
}
