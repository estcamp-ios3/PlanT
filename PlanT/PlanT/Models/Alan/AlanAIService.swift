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
        let clientId = "0f6ae041-abee-44e8-b970-910cbaf08c28" // Alan 키
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

    /// 완료 루틴은 고정 문구, 미완료는 프롬프트에서 두 줄을 그대로 받아 사용
    func generateEncouragement(for items: [RoutineEncItem]) async -> [UUID: String] {
        guard !items.isEmpty else { return [:] }

        var result: [UUID: String] = [:]

        for item in items {
            // ✅ 완료 루틴은 AI 호출 없이 즉시 리턴
            if item.total > 0 && item.done >= item.total {
                result[item.id] = "🎉 축하해요! 루틴을 완성했어요!"
                continue
            }

            // ✅ 프롬프트에서 '두 줄'을 만들게 하고, 그대로 사용
            let raw = await ask(question: makePerRoutinePrompt(title: item.title, total: item.total, done: item.done))
            let lines = Self.normalizeLines(from: raw)

            if lines.count >= 2 {
                result[item.id] = lines[0] + "\n" + lines[1]
            } else if lines.count == 1 {
                // 한 줄만 오면 2줄 형식 보장 위해 남은 횟수는 로컬에서 보강
                let remain = max(0, item.total - item.done)
                result[item.id] = lines[0] + "\n" + "\(remain)회 남았어요!"
            } else {
                // 완전 빈 응답이면 최소한의 안전장치
                let remain = max(0, item.total - item.done)
                result[item.id] = "응원하고 있어요!\n\(remain)회 남았어요!"
            }
        }

        return result
    }

    // MARK: - 프롬프트 (그대로 유지하되, AI가 '두 줄'을 내도록 지시)
    private func makePerRoutinePrompt(title: String, total: Int, done: Int) -> String {
        return """
        아래 JSON 데이터를 참고해서 **자연스러운 한 줄 한국어 응원 메시지**를 만들어줘.
        이후 출력은 두 줄:
        1줄: 네가 만든 응원 한 줄
        2줄: "\(max(0, total - done))회 남았어요!"  // ✅ 직접 계산

        규칙:
        - 문장은 25자 이내로 간결하게.
        - **루틴 이름(title)의 단어나 문구는 절대 포함하지 마.**
        - 제목(title) 언급 없이, 상황에 맞는 감정적 응원만 써.
        - 설명/따옴표/JSON/불릿 없이 결과만 출력.
        - 총 두 줄만 출력.

        JSON:
        {"title":"\(title)","total":\(total),"done":\(done)}
        """
    }

    // MARK: - 정규화(코드펜스/따옴표/JSON 흔적 제거 → 라인 배열)
    private static func normalizeLines(from raw: String) -> [String] {
        raw
            .replacingOccurrences(of: "```json", with: "")
            .replacingOccurrences(of: "```", with: "")
            .replacingOccurrences(of: "\"", with: "")
            .components(separatedBy: .newlines)
            .map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }
            .filter { !$0.isEmpty }
            .filter { line in
                // JSON 키/괄호류는 제거
                guard !line.hasPrefix("{"),
                      !line.hasPrefix("}"),
                      !line.hasPrefix("["),
                      !line.hasPrefix("]"),
                      !line.lowercased().hasPrefix("message:"),
                      !line.lowercased().hasPrefix("comment:")
                else { return false }
                return true
            }
    }

    // (과거 호환용 — 지금은 사용 안 해도 됨)
    static func sanitizeAISecondLine(raw: String) -> String {
        normalizeLines(from: raw).first ?? ""
    }
}
