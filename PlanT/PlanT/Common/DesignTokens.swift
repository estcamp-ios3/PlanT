//
//  DesignTokens.swift
//  PlanT
//
//  Created by catharina J on 9/29/25.
//

import SwiftUI

/// 버튼 배경 모서리 반경
var cornerRadius1: CGFloat = 8
var cornerRadius2: CGFloat = 16
var cornerRadius3: CGFloat = 24
var cornerRadius4: CGFloat = 32

/// 세로 여백
var vertical1: CGFloat = 4
var vertical2: CGFloat = 8
var vertical3: CGFloat = 12
var vertical4: CGFloat = 16
var vertical5: CGFloat = 20
var vertical6: CGFloat = 24

/// 버튼 내부 가로 여백
var horizontal: CGFloat = 20


/// 활성일 때 라벨 색을 그대로 두고 싶으면 true
/// 현재 구현에서는 항상 활성 시 흰색 전경색을 사용합니다.
/// 필요 시 이 값을 활용해 조건부로 전경색 적용을 변경하세요.
var respectLabelColorWhenEnabled: Bool = true
