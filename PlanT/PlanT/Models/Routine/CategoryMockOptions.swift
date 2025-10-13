//
//  CategoryMockOptions.swift
//  PlanT
//
//  Created by catharina J on 10/13/25.
//

import Foundation

enum CategoryMockOptions {
    static let options: [Option] = [
        .init(id: "category01", title: "지적 성장",
              subtitle: "지식을 확장하고 사고를 깊게 만드는 루틴",
              icon: "book.closed", thumb: "categories01"),
        .init(id: "category02", title: "전문 역량",
              subtitle: "일과 기술의 깊이를 키우는 성장 루틴",
              icon: "briefcase", thumb: "categories02"),
        .init(id: "category03", title: "신체·건강",
              subtitle: "꾸준한 운동과 건강 관리를 위한 루틴",
              icon: "figure.walk", thumb: "categories03"),
        .init(id: "category04", title: "정서·마음",
              subtitle: "마음을 다스리고 감정을 인식하는 루틴",
              icon: "brain", thumb: "categories04"),
        .init(id: "category05", title: "대인관계·커뮤니케이션",
              subtitle: "타인과의 관계를 개선하는 루틴",
              icon: "person.2", thumb: "categories05"),
        .init(id: "category06", title: "재정·삶의 관리",
              subtitle: "시간·돈·공간을 효율적으로 관리하는 루틴",
              icon: "calendar.badge.clock", thumb: "categories06"),
    ]
}
