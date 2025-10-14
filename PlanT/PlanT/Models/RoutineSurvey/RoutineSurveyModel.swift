//
//  RoutineSurveyModel.swift
//  PlanT
//
//  Created by catharina J on 9/30/25.
//

import SwiftUI

struct Option: Identifiable, Hashable {
    let id: String
    let title: String
    var subtitle: String? = nil
    var icon: String? = nil // SF Symbol or asset name
    var thumb: String? = nil
}

enum StepKind: Equatable {
    case categoryGrid   // 1단계 전용
    case single       // 라디오(1개 선택)
    case multiple     // 체크(여러개)
    case confirm      // 예/아니오
    case summary      // 요약/생성
}

struct SurveyStep: Identifiable, Equatable {
    let id: String
    let kind: StepKind
    let title: String
    let message: String?
    let options: [Option]           // summary에선 비어있을 수 있음
    let minSelection: Int
    let maxSelection: Int?          // nil이면 제한 없음
}
