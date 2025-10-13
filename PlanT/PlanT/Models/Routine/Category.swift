//
//  Category.swift
//  PlanT
//
//  Created by catharina J on 10/13/25.
//

/// 카테고리 모델 구조체
/// 서버에서 받아오는 카테고리 정보를 코드로 표현합니다.

import Foundation

// MARK: - Category

/// 카테고리(분류)를 표현하는 모델입니다.
/// 서버에 저장된 카테고리 정보를 앱 내에서 사용하기 쉽게 변환합니다.
struct Category: Codable, Identifiable, Hashable {
    let id: Int64    /// 카테고리 고유 식별자 (Int64) - 서버에서 내려오는 데이터
    let slug: String    /// 카테고리 영문 고유 문자열(슬러그, 예: "healthy-food")
    let nameKo: String    /// 카테고리 대표 한글명
    let description: String?    /// 카테고리 설명 (옵션, 없을 수 있음)
    let iconName: String?    /// 카테고리 대표 아이콘 이름 (SF Symbol 또는 커스텀, 옵션)
    let sortOrder: Int    /// 카테고리 정렬 기준(숫자가 작을수록 먼저)
    let isActive: Bool    /// 현재 활성화된 카테고리 여부 // [확장필드]

    /// 서버 필드명과 매핑하기 위한 CodingKeys
    enum CodingKeys: String, CodingKey {
        case id
        case slug
        case nameKo       = "name_ko"
        case description
        case iconName     = "icon_name"
        case sortOrder    = "sort_order"
        case isActive     = "is_active"
    }
}
