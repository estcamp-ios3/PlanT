//
//  AlanAITest.swift
//  PlanT
//
//  Created by 이지훈 on 10/17/25.
//

import SwiftUI

// MARK: - 프롬프트 모델
private struct RoutineItem: Codable {
    let title: String
    let total: Int
    let done: Int
}

// MARK: - RoutineStore → 프롬프트 생성
private func makePrompt(from store: RoutineStore) -> String {
    let items: [RoutineItem] = store.routines.map { r in
        RoutineItem(
            title: r.title,
            total: Int(r.frequencyPerWeekId.replacingOccurrences(of: "x", with: "")) ?? 0,
            done: r.completedCount
        )
    }

    guard !items.isEmpty else {
        return "루틴이 없습니다. 빈 배열입니다: []"
    }

    let json = (try? String(data: JSONEncoder().encode(items), encoding: .utf8)) ?? "[]"

    return """
    다음 JSON 배열을 보고 각 항목마다 한국어로 한 줄 응원을 만들어줘.
    형식: "(목표 이름 제외)~~만큼 했어요. 앞으로 n회면 목표 달성이에요!"
    제약: 각 줄은 25자 이내, 총 \(items.count)줄만.

    JSON:
    \(json)
    """
}

// MARK: - 결과를 라인 배열로 정규화
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

// MARK: - View
struct AlanAITest: View {
    @EnvironmentObject var routineStore: RoutineStore
    @State private var answer: String = ""
    @State private var isLoading = false

    private let aiService = AlanAIService.shared

    var body: some View {
        VStack(spacing: 16) {
            Group {
                if isLoading {
                    VStack(spacing: 8) {
                        ProgressView()
                        Text("🤖 응답 생성중...").foregroundStyle(.secondary)
                    }
                } else {
                    ScrollView {
                        Text(answer.isEmpty ? "버튼을 눌러 응답을 받아보세요." : answer)
                            .frame(maxWidth: .infinity)
                            .multilineTextAlignment(.center)
                            .padding()
                    }
                }
            }
            .frame(maxWidth: .infinity, minHeight: 160)

            Button {
                Task { await runAsk() }
            } label: {
                Text(isLoading ? "요청 중..." : "Ask Alan")
                    .frame(maxWidth: .infinity)
            }
            .buttonStyle(.borderedProminent)
            .disabled(isLoading)
        }
        .padding()
        .task { await aiService.prewarmIfNeeded() }
    }

    private func runAsk() async {
        await MainActor.run {
            isLoading = true
            answer = "🤖 응답 생성중..."
        }

        // ✅ RoutineStore → 프롬프트 생성
        let prompt = makePrompt(from: routineStore)

        // ✅ AlanAIService (디버그 API) 호출
        let (rawAnswer, errorDesc, metaLog) = await aiService.askDebug(question: prompt)

        // 🔎 콘솔 로그로 에러/메타 확인
        print(metaLog)
        if let errorDesc {
            print("❌ AlanAI errorDescription:", errorDesc)
        }

        // ✅ 결과 정규화
        let lines = normalizedLines(from: rawAnswer)

        await MainActor.run {
            isLoading = false
            if let errorDesc, rawAnswer.isEmpty {
                // 실패 시 사용자에게도 표시(선택)
                answer = "❌ AI 오류: \(errorDesc)"
            } else {
                answer = lines.isEmpty ? (rawAnswer.isEmpty ? "응답이 비어 있습니다." : rawAnswer) : lines.joined(separator: "\n")
            }

            // 라인 → 루틴별 매핑(필요 시)
            var mapped: [UUID: String] = [:]
            for (idx, routine) in routineStore.routines.enumerated() {
                guard idx < lines.count else { break }
                mapped[routine.id] = lines[idx]
            }
            routineStore.aiComments = mapped
        }
    }
}

#Preview {
    Text("Preview에서는 RoutineStore 주입이 필요합니다.")
}
