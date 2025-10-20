//
//  AICommentPersistence.swift
//  PlanT
//
//  Created by 이지훈 on 10/20/25.
//

import Foundation

enum AICommentPersistence {
    private static let key = "aiComments.v1"

    /// 저장된 AI 코멘트 맵 로드: [UUID: String]
    static func load() -> [UUID: String] {
        guard let data = UserDefaults.standard.data(forKey: key) else { return [:] }
        do {
            let map = try JSONDecoder().decode([String: String].self, from: data)
            var result: [UUID: String] = [:]
            for (k, v) in map {
                if let id = UUID(uuidString: k) {
                    result[id] = v
                }
            }
            return result
        } catch {
            print("⚠️ AICommentPersistence.load decode 실패:", error.localizedDescription)
            return [:]
        }
    }

    /// AI 코멘트 맵 저장: [UUID: String]
    static func save(_ dict: [UUID: String]) {
        let strDict = Dictionary(uniqueKeysWithValues: dict.map { ($0.key.uuidString, $0.value) })
        do {
            let data = try JSONEncoder().encode(strDict)
            UserDefaults.standard.set(data, forKey: key)
        } catch {
            print("⚠️ AICommentPersistence.save encode 실패:", error.localizedDescription)
        }
    }

    static func clear() {
        UserDefaults.standard.removeObject(forKey: key)
    }
}
