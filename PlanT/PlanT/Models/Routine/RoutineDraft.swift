//
//  RoutineDraft.swift
//  PlanT
//
//  Created by catharina J on 10/13/25.
//
// 루틴 초안(RoutineDraft) 및 서버 전송용 DTO, 변환/유효성 검사 헬퍼 포함
//

import Foundation


// MARK: - 화면 전용 모델 (Codable 추가만 + 요일 타입 세이프)
/// 루틴 생성/수정 화면에서 사용하는 임시 초안 모델
/// 실제 루틴이 생성되기 전까지 임시로 정보를 담아둠
struct RoutineDraft: Codable, Hashable, Identifiable {

    var id = UUID()    /// [클라이언트 전용] 임시 초안 고유 식별자 (UUID, 앱 내부 용도)

    // MARK: - Routine Category (카테고리 정보)
    /// [category_id] bigint | 필수 | 루틴이 속한 카테고리 식별자 (서버 routines.category_id)
    /// 예: 12345
    var categoryId: Int64

    /// [클라이언트 전용] 카테고리 이름 (화면 표시용)
    /// 예: "운동", "공부"
    var categoryTitle: String

    // MARK: - Routine Type (루틴 종류)
    /// [routine_type_id] varchar | 필수 | 루틴 종류 식별자 (서버 routines.routine_type_id)
    /// 예: "walk", "study"
    var routineTypeId: String

    /// [클라이언트 전용] 루틴 종류 이름 (예: '걷기', '독서')
    var routineTypeTitle: String

    // MARK: - Frequency & Duration (빈도 및 수행 시간)
    /// [frequency_per_week_id] varchar | 필수 | 주간 수행 빈도 식별자 (서버 routines.frequency_per_week_id)
    /// 예: "3x" (주 3회)
    var frequencyPerWeekId: String

    /// [클라이언트 전용] 주간 빈도 표시 (예: "주 3회")
    var frequencyPerWeekTitle: String

    /// [duration_id] varchar | 필수 | 1회 수행 시간 식별자 (서버 routines.duration_id)
    /// 예: "20min"
    var durationId: String

    /// [클라이언트 전용] 1회 수행 시간 표시 (예: "20분")
    var durationTitle: String

    // MARK: - Period (수행 기간)
    /// [period_is_no_limit] boolean | 필수 | 기간 무제한 여부 (true면 시작/종료일 무시)
    var periodIsNoLimit: Bool

    /// [start_datetime] timestamptz | 옵션 | 루틴 시작일 (기간 제한 있을 경우 필수)
    /// 예: 2025-10-15T00:00:00Z
    var startDate: Date?

    /// [end_datetime] timestamptz | 옵션 | 루틴 종료일 (nil이면 무제한)
    /// 예: 2026-01-01T00:00:00Z
    var endDate: Date?

    // MARK: - Reminder (알림 설정)
    /// [use_notification] boolean | 필수 | 알림 사용 여부
    var reminderOn: Bool

    /// [notification_time] varchar "HH:mm:ss" | 옵션 | 알림 시각 (시간 정보만 사용)
    /// 예: "08:30:00"
    var reminderTime: Date?

    /// [notification_days] varchar[] | 옵션 | 알림 요일 목록 (예: ["mon", "wed"])
    var reminderDays: [Weekday]?

    // MARK: - Meta (기타 정보)
    /// [goal] text | 필수 | 루틴 목표 설명
    /// 예: "하루 30분 걷기"
    var goal: String

    /// [notes] text | 옵션 | 추가 메모
    var notes: String?

    /// [icon_name] varchar | 옵션 | 아이콘 이름
    var iconName: String?

    /// [is_favorite] boolean | 필수 | 즐겨찾기 여부
    var isFavorite: Bool

    // MARK: - App Internal Metadata (앱 내부 관리용)
    /// [클라이언트 전용] 초안 생성 시각 (서버 저장 안 함)
    var createdAt: Date = Date()

    /// [클라이언트 전용] 마지막 수정 시각 (서버 저장 안 함)
    var updatedAt: Date = Date()

    // MARK: - TODO: 서버 routines 테이블에 있지만 클라이언트 초안에 미포함된 필드 예시
    // var deleted_at: Date?    // 삭제 시각 (서버 관리용)
    // var repeat_pattern_id: String?  // 반복 패턴 식별자 (예: 매주, 매월)
    // var progress_status: String?    // 현재 진행 상태
    // var parent_routine_id: UUID?    // 부모 루틴 id (하위 루틴 관리용)
}
