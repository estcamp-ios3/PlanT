////
////  AlanAITest.swift
////  PlanT
////
////  Created by 이지훈 on 10/17/25.
////
//
//import SwiftUI
//
//// MARK: - 프롬프트 모델
//private struct RoutineItem: Codable {
//    let title: String
//    let total: Int
//    let done: Int
//}
//
//// MARK: - RoutineStore → 프롬프트 생성
//private func makePrompt(from store: RoutineStore) -> String {
//    let items: [RoutineItem] = store.routines.map { r in
//        RoutineItem(
//            title: r.title,
//            total: Int(r.frequencyPerWeekId.replacingOccurrences(of: "x", with: "")) ?? 0,
//            done: r.completedCount
//        )
//    }
//
//    guard !items.isEmpty else {
//        return "루틴이 없습니다. 빈 배열입니다: []"
//    }
//
//    let json = (try? String(data: JSONEncoder().encode(items), encoding: .utf8)) ?? "[]"
//
//    // ✅ 예시/조건 제거: AI가 상황을 보고 스스로 응원 문장을 선택
//    return """
//    아래 JSON 배열에는 각 루틴의 이름(title), 전체 목표 횟수(total), 현재까지 완료한 횟수(done)가 들어 있습니다.
//    각 루틴마다 현재 상황에 어울리는 짧은 한국어 응원 문장을 만들어주세요.
//
//    요구사항:
//    - 루틴마다 정확히 한 줄만 출력하세요.
//    - 문장은 25자 이내로 간결하게 작성하세요.
//    - 제목(title)이나 숫자 나열은 피하고, 자연스러운 응원/격려/축하 메시지로만 구성하세요.
//    - 출력은 JSON/마크다운/설명 없이, 루틴 개수만큼 한 줄씩 나열하세요.
//    - 달성 상태라면 축하 뉘앙스, 아직 진행 중이라면 격려 뉘앙스로 자연스럽게 표현하세요.
//
//    JSON 데이터:
//    \(json)
//    """
//}
//
//// MARK: - 결과를 라인 배열로 정규화
//private func normalizedLines(from raw: String) -> [String] {
//    raw
//        .replacingOccurrences(of: "```json", with: "")
//        .replacingOccurrences(of: "```", with: "")
//        .components(separatedBy: .newlines)
//        .map { $0.trimmingCharacters(in: .whitespaces) }
//        .filter {
//            !$0.isEmpty &&
//            !$0.hasPrefix("{") &&
//            !$0.hasPrefix("}") &&
//            !$0.hasPrefix("[") &&
//            !$0.hasPrefix("]")
//        }
//}
//
//// MARK: - View
//struct AlanAITest: View {
//    @EnvironmentObject var routineStore: RoutineStore
//    @State private var answer: String = ""
//    @State private var isLoading = false
//
//    private let aiService = AlanAIService.shared
//
//    var body: some View {
//        VStack(spacing: 16) {
//            Group {
//                if isLoading {
//                    VStack(spacing: 8) {
//                        ProgressView()
//                        Text("🤖 응답 생성중...").foregroundStyle(.secondary)
//                    }
//                } else {
//                    ScrollView {
//                        Text(answer.isEmpty ? "버튼을 눌러 응답을 받아보세요." : answer)
//                            .frame(maxWidth: .infinity)
//                            .multilineTextAlignment(.center)
//                            .padding()
//                    }
//                }
//            }
//            .frame(maxWidth: .infinity, minHeight: 160)
//
//            Button {
//                Task { await runAsk() }
//            } label: {
//                Text(isLoading ? "요청 중..." : "Ask Alan")
//                    .frame(maxWidth: .infinity)
//            }
//            .buttonStyle(.borderedProminent)
//            .disabled(isLoading)
//        }
//        .padding()
//        .task { await aiService.prewarmIfNeeded() }
//    }
//
//    // MARK: - AlanAI 호출 실행
//    private func runAsk() async {
//        await MainActor.run {
//            isLoading = true
//            answer = "🤖 응답 생성중..."
//        }
//
//        // ✅ RoutineStore → 프롬프트 생성
//        let prompt = makePrompt(from: routineStore)
//
//        // ✅ AlanAIService (디버그 API) 호출
//        let (rawAnswer, errorDesc, metaLog) = await aiService.askDebug(question: prompt)
//
//        // 🔎 콘솔 로그로 에러/메타 확인
//        print(metaLog)
//        if let errorDesc {
//            print("❌ AlanAI errorDescription:", errorDesc)
//        }
//
//        // ✅ 결과 정규화
//        let lines = normalizedLines(from: rawAnswer)
//
//        await MainActor.run {
//            isLoading = false
//            if let errorDesc, rawAnswer.isEmpty {
//                answer = "❌ AI 오류: \(errorDesc)"
//            } else {
//                answer = lines.isEmpty
//                    ? (rawAnswer.isEmpty ? "응답이 비어 있습니다." : rawAnswer)
//                    : lines.joined(separator: "\n")
//            }
//
//            // ✅ AI 응답을 RoutineStore에 매핑
//            var mapped: [UUID: String] = [:]
//            for (idx, routine) in routineStore.routines.enumerated() {
//                guard idx < lines.count else { break }
//                mapped[routine.id] = lines[idx]
//            }
//            routineStore.aiComments = mapped
//        }
//    }
//}
//
//#Preview {
//    Text("Preview에서는 RoutineStore 주입이 필요합니다.")
//}
