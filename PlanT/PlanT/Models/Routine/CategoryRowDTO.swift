//
//  CategoryRowDTO.swift
//  PlanT
//
//  Created by catharina J on 10/13/25.
//

import Foundation

/// Supabase categories 테이블(6컬럼)에 정확히 맞춘 DTO
struct CategoryRowDTO: Decodable, Identifiable {
    let id: Int64
    let slug: String
    let name_ko: String
    let description: String?
    let icon_name: String?
    let sort_order: Int
}


