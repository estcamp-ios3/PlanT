//
//  AlanAITest.swift
//  PlanT
//
//  Created by 이지훈 on 10/17/25.
//

import SwiftUI
import AlanAI

// MARK: - AlanAI 클라이언트 (글로벌 재사용)
private let clientId = "89a3432c-e591-4751-9b97-2d4fc2d9fa6a"
private let alanAI = AlanAI(clientID: clientId)

// MARK: - 데이터 모델 (토큰 절약용 JSON 구조)
struct RoutineItem: Codable {
    let title: String
    let time: String
    let amount: String
    let unit: String
    let total: Int
    let done: Int
}

// 샘플 데이터
private let routines: [RoutineItem] = [
    .init(title: "물마시기", time: "06:00", amount: "500", unit: "ml",  total: 7, done: 6),
    .init(title: "운동하기", time: "07:00", amount: "30",  unit: "min", total: 5, done: 2),
    .init(title: "독서하기", time: "08:00", amount: "60",  unit: "min", total: 4, done: 2),
]

// MARK: - 프롬프트 (짧고 구조화)
private func makePrompt() -> String {
    let json = (try? String(data: JSONEncoder().encode(routines), encoding: .utf8)) ?? "[]"
    return """
    다음 JSON 배열을 보고 각 항목마다 한국어로 한 줄 응원을 만들어줘.
    형식: "(목표 이름 제외)~~만큼 했어요. 앞으로 n회면 목표 달성이에요!"
    제약: 각 줄은 25자 이내, 총 \(routines.count)줄만.

    JSON:
    \(json)
    """
}

// MARK: - 간단 캐시 (같은 질문이면 즉시 반환)
actor AnswerCache {
    private var map: [String: String] = [:]
    func get(_ key: String) -> String? { map[key] }
    func set(_ key: String, value: String) { map[key] = value }
}
private let cache = AnswerCache()

// MARK: - 프리워밍 (앱/뷰 진입 시 한 번 호출 권장)
private var didPrewarm = false
@MainActor
private func prewarmAlanIfNeeded() {
    guard !didPrewarm else { return }
    didPrewarm = true
    Task.detached {
        _ = try? await alanAI.question(query: "ping")
    }
}

// MARK: - 네트워크 호출 (캐시 래핑)
private func askAlanCached(question: String) async -> String {
    let key = String(question.hashValue)
    if let cached = await cache.get(key) { return cached }
    let result = await askAlanNetwork(question: question)
    await cache.set(key, value: result)
    return result
}

private func askAlanNetwork(question: String) async -> String {
    do {
        let response: AlanResponse? = try await alanAI.question(query: question)
        if let response {
            return response.content ?? "N/A"
        } else {
            return "❌ AlanAI 응답이 비어 있습니다."
        }
    } catch {
        return "❌ 오류: \(error.localizedDescription)"
    }
}

// MARK: - View
struct AlanAITest: View {
    @State private var answer: String = ""
    @State private var isLoading = false

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
                            .frame(maxWidth: .infinity, alignment: .center)
                            .multilineTextAlignment(.center)
                            .padding()
                    }
                }
            }
            .frame(maxWidth: .infinity, minHeight: 160)

            Button {
                Task {
                    await MainActor.run {
                        isLoading = true
                        answer = "🤖 응답 생성중..."
                    }
                    let prompt = makePrompt()
                    let result = await askAlanCached(question: prompt)
                    await MainActor.run {
                        isLoading = false
                        answer = result
                    }
                }
            } label: {
                Text(isLoading ? "요청 중..." : "Ask Alan")
                    .frame(maxWidth: .infinity)
            }
            .buttonStyle(.borderedProminent)
            .disabled(isLoading)
        }
        .padding()
        .task { prewarmAlanIfNeeded() } // 프리워밍
    }
}

#Preview {
    AlanAITest()
}
