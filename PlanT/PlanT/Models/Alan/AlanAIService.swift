//
//  AlanAIService.swift
//  PlanT
//
//  Created by Team PlanT on 2025-10-20.
//

import Foundation
import AlanAI

// Alan 호출을 안전하게 감싸는 박스 액터
private actor AlanClientBox {
    private let client: AlanAI
    init(client: AlanAI) { self.client = client }

    func question(_ query: String) async throws -> AlanResponse? {
        try await client.question(query: query)
    }

    func ping() async throws -> AlanResponse? {
        try await client.question(query: "ping")
    }
}

final class AlanAIService {

    static let shared = AlanAIService()

    private let clientBox: AlanClientBox
    private var didPrewarm = false

    private init() {
        let clientId = "34a0ba9f-c677-4406-815a-47b88e791679"
        let client = AlanAI(clientID: clientId)
        self.clientBox = AlanClientBox(client: client)

        // 앱 시작 후 바로 웜업 시도 (실패 무시)
        Task { [weak self] in
            await self?.prewarmIfNeeded()
        }
    }

    // MARK: - Warmup (비차단, 실패 무시)
    func prewarmIfNeeded() async {
        guard !didPrewarm else { return }
        didPrewarm = true
        Task(priority: .background) { [clientBox] in
            _ = try? await clientBox.ping()
            print("✅ AlanAI prewarm attempted")
        }
    }

    // MARK: - Timeout wrapper (T는 Sendable이어야 함)
    private func withTimeout<T: Sendable>(
        _ seconds: TimeInterval,
        operation: @escaping @Sendable () async throws -> T
    ) async throws -> T {
        try await withThrowingTaskGroup(of: T.self) { group in
            group.addTask { try await operation() }
            group.addTask {
                try await Task.sleep(nanoseconds: UInt64(seconds * 1_000_000_000))
                throw URLError(.timedOut)
            }
            let result = try await group.next()!
            group.cancelAll()
            return result
        }
    }

    // MARK: - Low-level ask (타임아웃 + 1회 재시도)
    func ask(question: String, timeout: TimeInterval = 8) async -> String {
        let effectiveTimeout = max(timeout, question.count > 180 ? 10 : timeout)

        // 1차 시도
        do {
            let content: String = try await withTimeout(effectiveTimeout) { [clientBox] in
                let res = try await clientBox.question(question)
                return res?.content ?? ""
            }
            return content
        } catch {
            // 타임아웃/취소/기타 에러 처리
            if let urlErr = error as? URLError, urlErr.code == .timedOut {
                print("⏳ AlanAI timed out after \(effectiveTimeout)s (len=\(question.count))")
            } else if error is CancellationError {
                // ✅ 정상적인 내부 취소 케이스: 로그 남기지 않음
                return ""
            } else {
                print("❌ AlanAI ask error:", error.localizedDescription)
            }

            // 2차 재시도(짧게)
            do {
                try await Task.sleep(nanoseconds: 400_000_000)
                let content: String = try await withTimeout(min(6, effectiveTimeout)) { [clientBox] in
                    let res = try await clientBox.question(question)
                    return res?.content ?? ""
                }
                return content
            } catch {
                // 재시도도 실패 → 타임아웃만 소소하게 로깅
                if let urlErr = error as? URLError, urlErr.code == .timedOut {
                    print("⏳ AlanAI retry timed out (len=\(question.count))")
                }
                return ""
            }
        }
    }

    /// 디버그용(타임아웃 없이 원본 결과/에러 로그)
    func askDebug(question: String) async -> (rawAnswer: String, errorDesc: String?, metaLog: String) {
        var meta = """
        ── AlanAI Debug ─────────────────
        prompt.length = \(question.count)
        date = \(Date())
        """
        do {
            let res = try await clientBox.question(question)
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

    // MARK: - 여러 루틴 고수준
    struct RoutineEncItem: Codable {
        let id: UUID
        let title: String
        let total: Int
        let done: Int
    }

    /// 병렬 처리 + 타임아웃 + 즉시 fallback + 동시성 제한
    func generateEncouragement(for items: [RoutineEncItem]) async -> [UUID: String] {
        guard !items.isEmpty else { return [:] }
        await prewarmIfNeeded()

        var result: [UUID: String] = [:]
        let pending = items.filter { !($0.total > 0 && $0.done >= $0.total) }
        let finished = items.filter { $0.total > 0 && $0.done >= $0.total }

        // 완료 루틴 즉시
        for item in finished {
            result[item.id] = "🎉 축하해요! 루틴을 완성했어요!"
        }

        // 기본 문구를 먼저 넣어 사용자 체감 빠르게
        var needFetch: [RoutineEncItem] = []
        for item in pending {
            let remain = max(0, item.total - item.done)
            result[item.id] = "응원하고 있어요!\n\(remain)회 남았어요!" // 즉시 폴백
            needFetch.append(item)
        }

        guard !needFetch.isEmpty else { return result }

        // ✅ 동시 호출 제한: 2개
        let maxConcurrent = 2
        var index = 0
        while index < needFetch.count {
            let slice = needFetch[index..<min(index + maxConcurrent, needFetch.count)]

            await withTaskGroup(of: (UUID, String).self) { group in
                for item in slice {
                    group.addTask { [weak self] in
                        guard let self else {
                            let remain = max(0, item.total - item.done)
                            return (item.id, "응원하고 있어요!\n\(remain)회 남았어요!")
                        }
                        let raw = await self.ask(
                            question: self.makePerRoutinePrompt(title: item.title, total: item.total, done: item.done),
                            timeout: 8 // 살짝 늘림
                        )
                        let lines = Self.normalizeLines(from: raw)
                        let value: String
                        if lines.count >= 2 {
                            value = lines[0] + "\n" + lines[1]
                        } else if lines.count == 1 {
                            let remain = max(0, item.total - item.done)
                            value = lines[0] + "\n" + "\(remain)회 남았어요!"
                        } else {
                            let remain = max(0, item.total - item.done)
                            value = "응원하고 있어요!\n\(remain)회 남았어요!"
                        }
                        return (item.id, value)
                    }
                }

                // 뒤늦게라도 결과 오면 덮어쓰기
                for await (id, text) in group {
                    result[id] = text
                }
            }

            index += maxConcurrent
        }

        return result
    }

    // MARK: - Mypage용 기존 프롬프트(유지)
    private func makePerRoutinePrompt(title: String, total: Int, done: Int) -> String {
        return """
        아래 JSON 데이터를 참고해서 **자연스러운 한 줄 한국어 응원 메시지**를 만들어줘.
        이후 출력은 두 줄:
        1줄: 네가 만든 응원 한 줄
        2줄: "\(max(0, total - done))회 남았어요!"

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

    // MARK: - 새 루틴 토스트용 프롬프트(현행 유지)
    private func newRoutinePrompt(title: String, minutes: Int?, timesPerWeek: Int?) -> String {
        let mm = minutes ?? 0
        let tw = timesPerWeek ?? 0
        return """
        아래 정보를 바탕으로 **정확히 2줄** 한국어 문장을 출력하세요.

        형식(고정):
        1줄: "\(title)\(mm > 0 ? " 1회 \(mm)분씩" : "")\(tw > 0 ? " \(tw)회" : "") 루틴을 시작하시려는군요!"
        2줄: 진심 어린 조언 한 줄(20자 이내, 자연스럽게, 존댓말)

        규칙:
        - 결과는 **정확히 2줄**만 출력합니다. 설명/불릿/따옴표/마크다운/코드블록/이모지 금지.
        - 1줄은 위의 **형식을 그대로** 따릅니다. (분/횟수 0이면 구절 생략)
        - 2줄은 **제목/숫자 반복 없이** 짧은 조언 한 문장(20자 이내, 존댓말).
        """
    }

    /// 새 루틴 2줄 토스트 생성 (타임아웃 + fallback)
    func fetchNewRoutineToast(title: String, goalRaw: String, frequencyPerWeekTitle: String) async -> String {
        let minutes = Self.extractFirstInt(from: goalRaw)
        let timesPerWeek = Self.extractFirstInt(from: frequencyPerWeekTitle)

        let prompt = newRoutinePrompt(title: title, minutes: minutes, timesPerWeek: timesPerWeek)
        let raw = await ask(question: prompt, timeout: 6)
        let lines = Self.normalizeLines(from: raw)
        let text = lines.prefix(2).joined(separator: "\n").trimmingCharacters(in: .whitespacesAndNewlines)

        if text.isEmpty {
            if let m = minutes, let t = timesPerWeek, m > 0, t > 0 {
                return "응답을 받지 아니하였다" //"\(title) 1회 \(m)분씩 \(t)회 루틴을 시작하시려는군요!\n함께 꾸준히 가볼까요?"
            }
        }
        return text
    }

    // MARK: - 공통 유틸 (액터 격리 제거)
    nonisolated static func normalizeLines(from raw: String) -> [String] {
        raw
            .replacingOccurrences(of: "```json", with: "")
            .replacingOccurrences(of: "```", with: "")
            .replacingOccurrences(of: "\"", with: "")
            .components(separatedBy: .newlines)
            .map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }
            .filter { !$0.isEmpty }
            .filter { line in
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

    nonisolated static func extractFirstInt(from text: String) -> Int? {
        let digits = text
            .trimmingCharacters(in: .whitespacesAndNewlines)
            .unicodeScalars
            .map { CharacterSet.decimalDigits.contains($0) ? Character($0) : " " }
        let parts = String(digits).split(separator: " ")
        if let first = parts.first, let val = Int(first) { return val }
        return nil
    }
}
