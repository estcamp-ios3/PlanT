//
//  SupabaseManager.swift
//  PlanT
//
//  Created by 이지훈 on 10/13/25.
//

// supabase 연결관리

import Foundation
import Supabase

final class SupabaseManager {
    static let shared = SupabaseManager()
    let client: SupabaseClient

    private init() {
        client = SupabaseClient(
            supabaseURL: URL(string: "https://zgkbeonrsmpqxmdluuke.supabase.co")!,
            supabaseKey: "sb_publishable_Du9vakPpo5HS9voxeMkoRQ_FnGpIa5P"
        )
    }
}
