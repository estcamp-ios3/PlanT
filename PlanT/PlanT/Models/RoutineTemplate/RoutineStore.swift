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

    /// AI 코멘트: [루틴ID: "AI 생성 문장"]
    @Published var aiComments: [UUID: String] = [:] {
        didSet { AICommentPersistence.save(aiComments) }
    }

    /// AI 갱신 여부 확인용 서명(ex: "done/total")
    private var aiSignatures: [UUID: String] = [:]

    private var context: ModelContext
    private let client = supabaseClient
    private let ai = AlanAIService.shared

    init(context: ModelContext) {
        self.context = context
        loadRoutines()

        // 저장된 AI 코멘트 복원
        self.aiComments = AICommentPersistence.load()

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
        do { try context.save() } catch { print("❌ SwiftData 저장 실패:", error) }

        Task {
            do {
                try await client.from("routines").insert(newRoutine.dto).execute()
                print("✅ Supabase 업로드 완료:", newRoutine.title)
            } catch {
                print("❌ Supabase 업로드 실패:", error.localizedDescription)
            }
            await regenerateAICommentsIfNeeded()
        }

        loadRoutines()
    }

    func deleteRoutine(_ routine: Routine) {
        context.delete(routine)
        do { try context.save() } catch { }

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

            // AI 상태 정리
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

        do { try context.save() } catch { print("❌ SwiftData 저장 실패:", error) }

        Task {
            do {
                try await client
                    .from("routines")
                    .update(["completed_count": routine.completedCount])
                    .eq("id", value: routine.id)
                    .execute()
            } catch {
                print("❌ Supabase 완료횟수 업데이트 실패:", error.localizedDescription)
            }
            await regenerateAICommentsIfNeeded()
        }

        loadRoutines()
        withAnimation(.spring()) { refreshTrigger = UUID() }
    }
}

// MARK: - AlanAI 연동 (첫 줄/조건 없이 자유 응원 생성)
extension RoutineStore {
    func regenerateAICommentsIfNeeded() async {
        let targets: [Routine] = routines.filter { r in
            let sig = "\(r.completedCount)/\(totalCount(for: r))"
            return aiSignatures[r.id] != sig
        }
        guard !targets.isEmpty else {
            print("ℹ️ AI 코멘트 재생성 불필요")
            return
        }

        var newComments = aiComments
        var newSignatures = aiSignatures

        for r in targets {
            let total = totalCount(for: r)
            let done = r.completedCount

            // ✅ 완료 루틴 → AI 호출 생략, 고정 메시지
            if total > 0 && done >= total {
                newComments[r.id] = "🎉 축하해요! 루틴을 완성했어요!"
                newSignatures[r.id] = "\(done)/\(total)"
                continue
            }

            // ✅ AI에게 자유롭게 한 줄 생성 요청
            let prompt = makePerRoutinePrompt(title: r.title, total: total, done: done)

            let raw = await ai.ask(question: prompt)
            let cleaned = Self.sanitizeAISecondLine(raw: raw)

            let final = cleaned.isEmpty
                ? "오늘도 한 걸음 나아가고 있어요!"
                : cleaned

            newComments[r.id] = final
            newSignatures[r.id] = "\(done)/\(total)"
        }

        aiComments = newComments
        aiSignatures = newSignatures
        print("✅ 자유 응원 코멘트 갱신 완료(\(targets.count)건)")
    }

    // MARK: - 자유 응원 프롬프트
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

    // MARK: - AI 응답 정제 (불필요한 포맷 제거)
    private static func sanitizeAISecondLine(raw: String) -> String {
        let cleaned = raw
            .replacingOccurrences(of: "```json", with: "")
            .replacingOccurrences(of: "```", with: "")
            .replacingOccurrences(of: "\"", with: "")
            .trimmingCharacters(in: .whitespacesAndNewlines)

        let bannedPrefixes = ["{", "}", "[", "]", "message:", "comment:"]
        let lines = cleaned
            .components(separatedBy: .newlines)
            .map { $0.trimmingCharacters(in: .whitespaces) }
            .filter { !$0.isEmpty && !bannedPrefixes.contains(where: { $0.hasPrefix($0) }) }

        return lines.first ?? cleaned
    }
}
