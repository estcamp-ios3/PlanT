//
//  SeedType.swift
//  PlanT
//
//  Created by 박성관 on 10/17/25.
//

import Foundation

struct Seed: Identifiable, Equatable {
    let id = UUID()
    let name: String
    let imagePrefix: String
    let stages: Int = 5
    
}
    
    // 전체 씨앗 리스트 (Seed? 배열로 구성하여 빈 칸 표현 가능)
    let allSeeds: [Seed] = [
        Seed(name: "사과", imagePrefix: "seed_Apple"),
        Seed(name: "복숭아", imagePrefix: "seed_Peach"),
        Seed(name: "해바라기", imagePrefix: "seed_Sunflower"),
       
    ]

