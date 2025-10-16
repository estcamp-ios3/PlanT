//
//  SupabaseManager.swift
//  PlanT
//
//  Created by 이지훈 on 10/13/25.
//

// supabase 연결관리

import Foundation
import Supabase

/// ✅ Supabase 전역 클라이언트 인스턴스 (싱글톤 X, 전역 상수)
let supabaseClient = SupabaseClient(
    supabaseURL: URL(string: "https://zgkbeonrsmpqxmdluuke.supabase.co")!,
    supabaseKey: "sb_publishable_Du9vakPpo5HS9voxeMkoRQ_FnGpIa5P"
)
