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
            print(" [RoutineStore] loadRoutines() 호출됨 - 불러온 루틴개수: \(routines.count)")
        } catch {
            print("❌ 루틴 불러오기 실패:", error)
        }
    }

    func addRoutine(
        from seed: Seed,
        basedOn routine: Routine,
        categoryId: String,
        draft: RoutineDraft,
        reminderOffsets: Set<Int>
    ) {
        let newRoutine = Routine(
            title: routine.title,
            categoryId: categoryId,
            seedName: seed.name,
            duration: routine.duration,
            goal:  routine.goal,
            alarm: draft.reminderOn ? .every24Hours : .off,
            frequencyPerWeekId: routine.frequencyPerWeekId,
            frequencyPerWeekTitle: routine.frequencyPerWeekTitle,
            note: routine.note,
            isCompleted: false,
            completedCount: 0,
            createdAt: Date(),
            modifiedAt: Date(),
            startDate: draft.startDate ?? Date(),
            endDate: draft.endDate ?? Date().addingTimeInterval(7 * 24 * 60 * 60)
        )

        newRoutine.startDate = draft.startDate
        newRoutine.endDate = draft.endDate

        print("""
            ✅ ROUTINE 저장됨:
            • ID: \(newRoutine.id)
            • TITLE: \(newRoutine.title)
            • CATEGORY: \(newRoutine.categoryId)
            • GOAL: \(newRoutine.goal)
            • DURATION: \(newRoutine.duration)
            • ALARM: \(newRoutine.alarm)
        """)

        context.insert(newRoutine)
        do { try context.save() } catch {
            print("❌ SwiftData 저장 실패:", error)
        }

        // ✅ MainActor 컨텍스트에서 비동기 작업
        Task { [client, weak self] in
            guard let self else { return }

            // Supabase 업로드
            do {
                try await client
                    .from("routines")
                    .insert(newRoutine.dto)
                    .execute()
                print("✅ Supabase 업로드 완료:", newRoutine.title)
            } catch {
                print("❌ Supabase 업로드 실패:", error.localizedDescription)
            }

            // 알림 예약 (여기서는 이미 MainActor)
            NotificationManager.shared.scheduleNotification(
                for: newRoutine.id,
                title: newRoutine.title,
                baseDate: draft.startDate ?? Date(),
                offsets: Array(reminderOffsets)
            )

            // ✅ 토스트는 기다렸다가 즉시 표시
            let toast = await self.ai.fetchNewRoutineToast(
                title: newRoutine.title,
                goalRaw: newRoutine.goal,
                frequencyPerWeekTitle: newRoutine.frequencyPerWeekTitle
            )
            MateToastCenter.show(toast)

            // ✅ AI 코멘트 갱신은 스코프와 분리된 태스크로 실행(취소 영향 제거)
            Task.detached { [weak self] in
                guard let self else { return }
                await self.regenerateAIComment(for: newRoutine)
            }
        }

        loadRoutines()
    }

    func deleteRoutine(_ routine: Routine) {
        context.delete(routine)
        do { try context.save() } catch { }

        // ✅ MainActor에서 비동기 호출
        Task { [client, weak self] in
            guard let self else { return }
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
            self.aiComments.removeValue(forKey: routine.id)
            self.aiSignatures.removeValue(forKey: routine.id)
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

        // ✅ MainActor에서 비동기 호출
        Task { [client, weak self] in
            guard let self else { return }
            do {
                try await client
                    .from("routines")
                    .update(["completed_count": routine.completedCount])
                    .eq("id", value: routine.id)
                    .execute()
            } catch {
                print("❌ Supabase 완료횟수 업데이트 실패:", error.localizedDescription)
            }

            // 코멘트 갱신은 분리하여 취소 영향 줄이기 (여기서는 await 해도 OK)
            Task.detached { [weak self] in
                guard let self else { return }
                await self.regenerateAIComment(for: routine)
            }
        }

        loadRoutines()
        withAnimation(.spring()) { refreshTrigger = UUID() }
    }
}

// MARK: - AlanAI 연동 (여러/단일 루틴 처리)
extension RoutineStore {
    /// 여러 루틴을 받아 AlanAI에 요청 → aiComments 갱신
    func regenerateAIComments(for routinesToUpdate: [Routine]) async {
        // 1) 시그니처 비교로 대상 선별(넘겨받은 배열 범위 내에서만)
        let targets: [Routine] = routinesToUpdate.filter { r in
            let sig = "\(r.completedCount)/\(totalCount(for: r))"
            return aiSignatures[r.id] != sig
        }
        guard !targets.isEmpty else {
            print("ℹ️ AI 코멘트 재생성 불필요(0건)")
            return
        }

        // 2) 페이로드 구성
        let items: [AlanAIService.RoutineEncItem] = targets.map { r in
            .init(
                id: r.id,
                title: r.title,
                total: totalCount(for: r),
                done: r.completedCount
            )
        }

        // 3) 서비스 호출(완료 루틴은 서비스 내부에서 고정 문구 처리됨)
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

    /// 단일 루틴만 AlanAI에 요청 → 내부적으로 다건 API를 1건 배열로 호출
    func regenerateAIComment(for routine: Routine) async {
        await regenerateAIComments(for: [routine])
    }

    /// (옵션) 기존: 전체 스캔해서 변경된 것만 갱신
    func regenerateAICommentsIfNeeded() async {
        await regenerateAIComments(for: routines)
    }
}

extension RoutineStore {
    func hasUncompletedRoutine() -> Bool {
        return routines.contains { !$0.isCompleted }
    }
}
