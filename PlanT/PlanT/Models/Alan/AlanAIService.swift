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

    /// 디버그 호출: (원문, 에러문구, 메타로그) 반환
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

    // MARK: - 여러 루틴 한 번에 고수준 API
    struct RoutineEncItem: Codable {
        let id: UUID
        let title: String
        let total: Int
        let done: Int
    }

    /// 요구사항:
    /// - 완료 루틴은 AI 호출하지 않고 고정 문구 반환("🎉 축하해요! 루틴을 완성했어요!")
    /// - 그 외는 프롬프트로 1줄 응원 받고, 2줄 형식(응원 + 남은횟수)으로 최종 조립
    func generateEncouragement(for items: [RoutineEncItem]) async -> [UUID: String] {
        guard !items.isEmpty else { return [:] }

        var result: [UUID: String] = [:]

        for item in items {
            // 완료 루틴 즉시 처리
            if item.total > 0 && item.done >= item.total {
                result[item.id] = "🎉 축하해요! 루틴을 완성했어요!"
                continue
            }

            let remain = max(0, item.total - item.done)
            let prompt = makePerRoutinePrompt(title: item.title, total: item.total, done: item.done)

            // 네트워크 호출
            let raw = await ask(question: prompt)

            // "첫 줄"만 추출 (JSON/코드블록 제거 등)
            let firstLine = Self.sanitizeAISecondLine(raw: raw)
            let encouragement = firstLine.isEmpty ? "오늘도 한 걸음 나아가고 있어요!" : firstLine

            // 최종 2줄(응원 + 남은횟수)
            result[item.id] = encouragement + "\n" + "\(remain)회 남았어요!"
        }

        return result
    }

    // MARK: - (이전 RoutineStore에 있던) 프롬프트/정제 로직을 서비스로 이전

    /// 자유 응원 프롬프트
    private func makePerRoutinePrompt(title: String, total: Int, done: Int) -> String {
        return """
        아래 JSON 데이터를 참고해서 **자연스러운 한 줄 한국어 응원 메시지**를 만들어줘.
        이후 출력은 두 줄:
        1줄: 네가 만든 응원 한 줄
        2줄: "\(max(0, total - done))회 남았어요!"  // ✅ 직접 계산

        규칙:
        - 문장은 25자 이내로 간결하게.
        - 설명/따옴표/JSON/불릿 없이 결과만 출력.
        - 총 두 줄만 출력.

        JSON:
        {"title":"\(title)","total":\(total),"done":\(done)}
        """
    }

    /// (이름 유지) AI 응답 정제 — 첫 줄만 추출해서 반환
    static func sanitizeAISecondLine(raw: String) -> String {
        let cleaned = raw
            .replacingOccurrences(of: "```json", with: "")
            .replacingOccurrences(of: "```", with: "")
            .replacingOccurrences(of: "\"", with: "")
            .trimmingCharacters(in: .whitespacesAndNewlines)

        let bannedPrefixes = ["{", "}", "[", "]", "message:", "comment:"]

        let lines = cleaned
            .components(separatedBy: .newlines)
            .map { $0.trimmingCharacters(in: .whitespaces) }
            .filter { line in
                guard !line.isEmpty else { return false }
                return !bannedPrefixes.contains(where: { prefix in line.hasPrefix(prefix) })
            }

        // 첫 줄만 사용 (AI가 두 줄을 주더라도 1줄만 취함)
        return lines.first ?? cleaned
    }
}
