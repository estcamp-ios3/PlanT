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

/// AlanAI 서비스 (싱글톤) — 같은 타겟에 AlanAIService.swift가 있어야 함
/// AlanAIService.shared.prewarmIfNeeded()
/// AlanAIService.shared.ask(question:)
@MainActor
final class RoutineStore: ObservableObject {
    @Published private(set) var routines: [Routine] = []
    @Published var refreshTrigger = UUID()

    /// AI 코멘트 저장소: [루틴ID: 코멘트(두 줄 or 한 줄)]
    @Published var aiComments: [UUID: String] = [:]

    /// AI 갱신 여부 확인용 서명(ex: "done/total")
    private var aiSignatures: [UUID: String] = [:]

    private var context: ModelContext
    private let client = supabaseClient

    // AlanAI 서비스
    private let ai = AlanAIService.shared

    init(context: ModelContext) {
        self.context = context
        loadRoutines()

        // 앱 시작 시 AlanAI 프리워밍(선택)
        Task { await ai.prewarmIfNeeded() }
    }

    func loadRoutines() {
        let fetchDescriptor = FetchDescriptor<Routine>()
        do {
            routines = try context.fetch(fetchDescriptor)
        } catch {
            print("X 루틴 불러오기 실패:", error)
        }
    }

    func addRoutine(from seed: Seed, basedOn routine: Routine, categoryId: String) {
        let newRoutine = Routine(
            title: routine.title,
            categoryId: categoryId,
            seedName: seed.name,
            duration: routine.duration,
            goal:  routine.goal,
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

            // 삭제 시 AI 상태도 정리
            aiComments.removeValue(forKey: routine.id)
            aiSignatures.removeValue(forKey: routine.id)
        }

        loadRoutines()
    }
}

// MARK: - 진행률 계산
extension RoutineStore {
    func completedCount(for routine: Routine) -> Int {
        routine.completedCount
    }

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
            // 진행 변경 → AI 코멘트 갱신 시도
            await regenerateAICommentsIfNeeded()
        }

        loadRoutines()
        withAnimation(.spring()) {
            refreshTrigger = UUID()
        }
    }
}

// MARK: - AlanAI 연동
extension RoutineStore {
    /// 변화가 있는 루틴(또는 신규)만 선별해, 항목별로 AlanAI에 질문 → aiComments 업데이트
    func regenerateAICommentsIfNeeded() async {
        // 1) 갱신이 필요한 루틴만 선별
        let targets: [Routine] = routines.filter { r in
            let sig = "\(r.completedCount)/\(totalCount(for: r))"
            return aiSignatures[r.id] != sig
        }
        guard !targets.isEmpty else {
            print("ℹ️ AI 코멘트 재생성 불필요(변화 없음)")
            return
        }

        // 2) 루틴별로 프롬프트 생성 & 호출(순차)
        var newComments = aiComments
        var newSignatures = aiSignatures

        for r in targets {
            let total = totalCount(for: r)
            let done = r.completedCount
            let prompt = makePerRoutinePrompt(title: r.title, total: total, done: done)

            let raw = await ai.ask(question: prompt)
            let cleaned = Self.sanitizeAIText(raw, total: total, done: done)
            newComments[r.id] = cleaned
            newSignatures[r.id] = "\(done)/\(total)"
        }

        // 3) 상태 반영
        aiComments = newComments
        aiSignatures = newSignatures

        print("✅ AI 코멘트 갱신 완료(\(targets.count)건)")
    }

    /// 각 루틴별 프롬프트 (완료 시 한 줄 메세지)
    private func makePerRoutinePrompt(title: String, total: Int, done: Int) -> String {
        return """
        아래 JSON 데이터를 보고, 해당 루틴에 맞는 응원 문장을 만들어줘.

        출력 형식:
        - 기본은 두 줄 문장
          1줄: "~만큼 했어요!"
          2줄: "(남은 횟수)회 남았어요!"  (남은 횟수 = total - done)
        - 만약 done == total이면 한 줄만 출력:
          "축하합니다 루틴을 완료했어요!"
        - JSON, 설명, 불릿, 번호, 기타 기호 금지
        - 제목(title)은 출력하지 마
        - 각 줄은 25자 이내

        입력 JSON:
        {"title":"\(title)","total":\(total),"done":\(done)}
        """
    }

    /// AI 텍스트 정제: 코드블록/JSON 키 제거 + "완료" 케이스 처리 + 최대 2줄 유지
    private static func sanitizeAIText(_ raw: String, total: Int, done: Int) -> String {
        // done==total 이면 1줄 메시지만 남게 강제
        if total > 0 && done >= total {
            // “완료” 관련 라인만 우선적으로 추출
            let normalized = raw
                .replacingOccurrences(of: "```json", with: "")
                .replacingOccurrences(of: "```", with: "")
                .components(separatedBy: .newlines)
                .map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }
                .filter { !$0.isEmpty }

            if let completion = normalized.first(where: {
                $0.contains("축하") || $0.contains("완료")
            }) {
                return completion
            }
        }

        // 일반 케이스: 의미 라인만 2줄까지
        let bannedPrefixes = [
            "{", "}", "[", "]",
            "\"id\"", "\"title\"", "\"total\"", "\"done\"",
            "\"time\"", "\"amount\"", "\"unit\"",
            "\"message\"", "\"comment\""
        ]

        let lines = raw
            .replacingOccurrences(of: "```json", with: "")
            .replacingOccurrences(of: "```", with: "")
            .components(separatedBy: .newlines)
            .map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }
            .filter { line in
                !line.isEmpty && !bannedPrefixes.contains(where: { line.hasPrefix($0) })
            }

        // 2줄로 축약
        if lines.isEmpty { return "" }
        if lines.count == 1 { return lines[0] }
        return lines[0] + "\n" + lines[1]
    }
}
