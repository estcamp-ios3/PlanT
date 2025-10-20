//
//  RoutineStore.swift
//  PlanT
//
//  Created by 박성관 on 10/2/25.
//

import Foundation
import SwiftData
import Combine
import Supabase
import SwiftUI

@MainActor
final class RoutineStore: ObservableObject {
    @Published private(set) var routines: [Routine] = []
    @Published var refreshTrigger = UUID()

    /// AI 코멘트: [루틴ID: "첫줄\n둘째줄" 또는 완료시 "완료 한 줄"]
    @Published var aiComments: [UUID: String] = [:]

    /// AI 갱신 여부 확인용 서명(ex: "done/total")
    private var aiSignatures: [UUID: String] = [:]

    private var context: ModelContext
    private let client = supabaseClient

    /// AlanAI 서비스
    private let ai = AlanAIService.shared

    init(context: ModelContext) {
        self.context = context
        loadRoutines()
        Task { await ai.prewarmIfNeeded() }
    }

    // MARK: - Load/CRUD
    func loadRoutines() {
        let fetchDescriptor = FetchDescriptor<Routine>()
        do {
            routines = try context.fetch(fetchDescriptor)
        } catch {
            print("❌ 루틴 불러오기 실패:", error)
        }
    }

    func addRoutine(from seed: Seed, basedOn routine: Routine, categoryId: String) {
        let newRoutine = Routine(
            title: routine.title,
            categoryId: categoryId,
            seedName: seed.name,
            duration: routine.duration,
            goal: routine.goal,
            alarm: routine.alarm,
            frequencyPerWeekId: routine.frequencyPerWeekId,
            frequencyPerWeekTitle: routine.frequencyPerWeekTitle,
            note: routine.note,
            isCompleted: false,
            completedCount: 0,
            createdAt: Date(),
            modifiedAt: Date()
        )

        context.insert(newRoutine)
        do {
            try context.save()
            print("✅ SwiftData 저장 완료:", newRoutine.title)
        } catch {
            print("❌ SwiftData 저장 실패:", error)
        }

        Task {
            do {
                try await client.from("routines").insert(newRoutine.dto).execute()
                print("✅ Supabase 업로드 완료:", newRoutine.title)
            } catch {
                print("❌ Supabase 업로드 실패:", error.localizedDescription)
            }
            // 새 루틴 생성 → AI 코멘트 갱신 시도
            await regenerateAICommentsIfNeeded()
        }

        loadRoutines()
    }

    func deleteRoutine(_ routine: Routine) {
        context.delete(routine)
        do {
            try context.save()
            print("✅ SwiftData 삭제 완료:", routine.title)
        } catch {
            print("❌ SwiftData 저장 실패:", error)
        }

        Task {
            do {
                try await client
                    .from("routines")
                    .delete()
                    .eq("id", value: routine.id)
                    .execute()
                print("✅ Supabase 삭제 완료:", routine.title)
            } catch {
                print("❌ Supabase 삭제 실패:", error.localizedDescription)
            }
            aiComments.removeValue(forKey: routine.id)
            aiSignatures.removeValue(forKey: routine.id)
        }

        loadRoutines()
    }
}

// MARK: - 진행률 계산
extension RoutineStore {
    func completedCount(for routine: Routine) -> Int { routine.completedCount }

    func totalCount(for routine: Routine) -> Int {
        Int(routine.frequencyPerWeekId.replacingOccurrences(of: "x", with: "")) ?? 0
    }

    func progress(for routine: Routine) -> Double {
        let total = totalCount(for: routine)
        guard total > 0 else { return 0 }
        let completed = completedCount(for: routine)
        return min(100, (Double(completed) / Double(total)) * 100)
    }
}

// MARK: - 진행횟수 증가
extension RoutineStore {
    func increaseProgress(for routine: Routine) {
        routine.completedCount += 1
        routine.modifiedAt = .now

        do {
            try context.save()
            print("✅ SwiftData 완료횟수 증가 저장:", routine.title, "(\(routine.completedCount)회)")
        } catch {
            print("❌ SwiftData 저장 실패:", error)
        }

        Task {
            do {
                try await client
                    .from("routines")
                    .update(["completed_count": routine.completedCount])
                    .eq("id", value: routine.id)
                    .execute()
                print("✅ Supabase 완료횟수 업데이트 완료")
            } catch {
                print("❌ Supabase 완료횟수 업데이트 실패:", error.localizedDescription)
            }
            await regenerateAICommentsIfNeeded()
        }

        loadRoutines()
        withAnimation(.spring()) {
            refreshTrigger = UUID()
        }
    }
}

// MARK: - AlanAI 연동 (완료 루틴은 AI 호출 생략) – 개별 요청(두 줄 구성)
extension RoutineStore {
    func regenerateAICommentsIfNeeded() async {
        let targets: [Routine] = routines.filter { r in
            let sig = "\(r.completedCount)/\(totalCount(for: r))"
            return aiSignatures[r.id] != sig
        }
        guard !targets.isEmpty else {
            print("ℹ️ AI 코멘트 재생성 불필요(변화 없음)")
            return
        }

        var newComments = aiComments
        var newSignatures = aiSignatures

        for r in targets {
            let total = totalCount(for: r)
            let done  = r.completedCount

            if total > 0, done >= total {
                // 완료는 즉시 한 줄
                newComments[r.id]  = "축하합니다 루틴을 완료했어요!"
                newSignatures[r.id] = "\(done)/\(total)"
                print("🎉 루틴 완료 감지 — AI 호출 생략:", r.title)
                continue
            }

            let firstLine = progressPhrase(total: total, done: done)
            let remain = max(0, total - done)

            let prompt = makePerRoutinePrompt(
                title: r.title,
                total: total,
                done: done,
                firstLine: firstLine,
                remain: remain
            )

            let raw = await ai.ask(question: prompt)
            let secondOrDoneLine = Self.sanitizeAISecondLine(raw: raw)

            let second = secondOrDoneLine.isEmpty ? "\(remain)회 남았어요!" : secondOrDoneLine
            let final = firstLine + "\n" + second

            newComments[r.id]  = final
            newSignatures[r.id] = "\(done)/\(total)"
        }

        aiComments = newComments
        aiSignatures = newSignatures
        print("✅ AI 코멘트 갱신 완료(\(targets.count)건)")
    }

    private func progressPhrase(total: Int, done: Int) -> String {
        guard total > 0 else { return "목표 설정이 필요해요!" }
        if done >= total { return "축하합니다 루틴을 완료했어요!" }
        if done == 0 { return "첫걸음이 중요해요!" }
        // 로컬 한 줄(첫 줄) 규칙을 더 간단히 유지하고 싶다면 여기만 조정
        let ratio = Double(done) / Double(total)
        switch ratio {
        case ..<0.26: return "시작이 반이에요!"
        case ..<0.61: return "벌써 반이나 했어요!"
        case ..<1.0:  return "거의 다 했어요!"
        default:      return "축하합니다 루틴을 완료했어요!"
        }
    }

    private func makePerRoutinePrompt(title: String, total: Int, done: Int, firstLine: String, remain: Int) -> String {
        """
        아래 JSON 데이터를 참고하여, **두 번째 줄만** 만들어줘.

        출력 형식:
        - 나는 이미 첫 번째 줄을 정했어: "\(firstLine)"
        - 너는 두 번째 줄만 출력해.
          형식: "\(remain)회 남았어요!"
        - JSON, 설명, 불릿, 번호, 기타 기호 금지
        - 각 줄은 25자 이내

        입력 JSON:
        {"title":"\(title)","total":\(total),"done":\(done)}
        """
    }

    private static func sanitizeAISecondLine(raw: String) -> String {
        let cleaned = raw
            .replacingOccurrences(of: "```json", with: "")
            .replacingOccurrences(of: "```", with: "")
            .trimmingCharacters(in: .whitespacesAndNewlines)

        let patterns = [
            #"\"message\"\s*:\s*\"([\s\S]*?)\""#,
            #"\"comment\"\s*:\s*\"([\s\S]*?)\""#
        ]
        for pat in patterns {
            if let regex = try? NSRegularExpression(pattern: pat, options: [.dotMatchesLineSeparators]) {
                let range = NSRange(cleaned.startIndex..<cleaned.endIndex, in: cleaned)
                let matches = regex.matches(in: cleaned, options: [], range: range)
                if !matches.isEmpty {
                    let msgs: [String] = matches.compactMap { m in
                        guard m.numberOfRanges > 1,
                              let r = Range(m.range(at: 1), in: cleaned) else { return nil }
                        return String(cleaned[r])
                            .replacingOccurrences(of: "\\n", with: "\n")
                            .replacingOccurrences(of: "\\\"", with: "\"")
                            .trimmingCharacters(in: .whitespacesAndNewlines)
                    }
                    return msgs.joined(separator: "\n").components(separatedBy: .newlines).first ?? ""
                }
            }
        }

        let bannedPrefixes = [
            "{", "}", "[", "]",
            "\"id\"", "\"title\"", "\"total\"", "\"done\"",
            "\"time\"", "\"amount\"", "\"unit\"",
            "\"message\"", "\"comment\""
        ]
        let lines = cleaned
            .components(separatedBy: .newlines)
            .map { $0.trimmingCharacters(in: .whitespaces) }
            .filter { line in
                !line.isEmpty && !bannedPrefixes.contains(where: { prefix in line.hasPrefix(prefix) })
            }

        if let completion = lines.first(where: { $0.contains("축하") || $0.contains("완료") }) {
            return completion
        }
        if let remainLine = lines.first(where: { $0.contains("회 남았어요") }) {
            return remainLine
        }
        return lines.first ?? ""
    }
}

// MARK: - (선택) 배치 방식: 한 번에 한 줄 코멘트 생성해 매핑
extension RoutineStore {
    /// AlanAIService의 배치 API 사용: 각 루틴당 "한 줄" 응원만 필요한 경우
    func regenerateOneLineCommentsBatch() async {
        let items: [AlanAIService.OneLineItem] = routines.map { r in
            .init(
                title: r.title,
                total: totalCount(for: r),
                done: r.completedCount
            )
        }
        let lines = await ai.generateOneLineComments(for: items)
        guard !lines.isEmpty else {
            print("ℹ️ 배치 생성 결과 없음")
            return
        }

        var mapped: [UUID: String] = [:]
        for (idx, r) in routines.enumerated() {
            let total = totalCount(for: r)
            let done  = r.completedCount
            if total > 0, done >= total {
                mapped[r.id] = "축하합니다 루틴을 완료했어요!" // 완료는 고정
            } else if idx < lines.count {
                mapped[r.id] = lines[idx]
            }
        }
        aiComments = mapped
        print("✅ 배치 한 줄 코멘트 갱신 완료(\(mapped.count)건)")
    }
}
