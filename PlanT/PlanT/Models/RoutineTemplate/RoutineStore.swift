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

// MARK: - AlanAI 연동 (완료 루틴은 AI 호출 생략)
extension RoutineStore {
    /// 변화가 있는 루틴만 선별 → AlanAIService에 위임 → aiComments 갱신
    func regenerateAICommentsIfNeeded() async {
        // 1) 시그니처 비교로 대상 선별
        let targets: [Routine] = routines.filter { r in
            let sig = "\(r.completedCount)/\(totalCount(for: r))"
            return aiSignatures[r.id] != sig
        }
        guard !targets.isEmpty else {
            print("ℹ️ AI 코멘트 재생성 불필요(변화 없음)")
            return
        }

        // 2) 서비스에 넘길 페이로드 구성
        let items: [AlanAIService.RoutineEncItem] = targets.map { r in
            .init(
                id: r.id,
                title: r.title,
                total: totalCount(for: r),
                done: r.completedCount
            )
        }

        // 3) 서비스 호출(완료 루틴 처리 + 응원+남은횟수 2줄 생성 포함)
        let generated: [UUID: String] = await ai.generateEncouragement(for: items)

        // 4) 상태 반영
        var newComments = aiComments
        var newSigs = aiSignatures

        for (id, text) in generated {
            newComments[id] = text
        }
        for r in targets {
            newSigs[r.id] = "\(r.completedCount)/\(totalCount(for: r))"
        }

        aiComments = newComments
        aiSignatures = newSigs
        print("✅ 자유 응원 코멘트 갱신 완료(\(targets.count)건)")
    }
}
