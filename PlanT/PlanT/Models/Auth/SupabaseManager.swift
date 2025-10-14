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
            supabaseKey: "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Inpna2Jlb25yc21wcXhtZGx1dWtlIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NTkxMTgxNzgsImV4cCI6MjA3NDY5NDE3OH0.-gKwzz8EefnGhCTk2GnmFHYsO-uIcHV6Zi5Usj76NH0"
        )
    }
}
