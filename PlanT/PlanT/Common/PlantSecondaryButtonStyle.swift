//
//  PlantPrimaryButtonStyle.swift
//  PlanT
//
//  Created by catharina J on 9/29/25.
//

import SwiftUI

// MARK: - Primary ButtonStyle
/// 앱 전반에서 사용하는 기본(Primary) 버튼 스타일입니다.
/// - 일관된 폰트, 색상, 내부 여백, 코너 반경, 눌림 애니메이션을 제공합니다.
struct PlantSecondaryButtonStyle: ButtonStyle {
    /// 버튼 배경 모서리 반경
    var cornerRadius: CGFloat = 30

    /// 버튼 내부 세로 여백
    var vertical: CGFloat = 12

    /// 버튼 내부 가로 여백
    var horizontal: CGFloat = 20

    /// true일 경우 버튼이 가능한 가로 최대 너비로 확장됩니다.
    var expandToMaxWidth: Bool = true

    /// 활성일 때 라벨 색을 그대로 두고 싶으면 true
    /// 현재 구현에서는 항상 활성 시 흰색 전경색을 사용합니다.
    /// 필요 시 이 값을 활용해 조건부로 전경색 적용을 변경하세요.
    var respectLabelColorWhenEnabled: Bool = true

    /// 버튼의 활성/비활성 상태 (SwiftUI 환경 값)
    @Environment(\.isEnabled) private var isEnabled
    /// 접근성 설정: 동작 줄이기 (애니메이션/스케일 효과 최소화)
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    
    func makeBody(configuration: Configuration) -> some View {
        // 디자인 시스템 색상(Assets) 사용, 없을 경우 시스템 기본 색으로 폴백
        let primaryBG  = Color(uiColor: UIColor(named: "BrandSecondary") ?? .white)
        let disabledBG = Color(uiColor: UIColor(named: "Gray100") ?? .systemGray5)
        let primaryFG  = Color(uiColor: UIColor(named: "3B4019") ?? .black)
        let disabledFG = Color(uiColor: UIColor(named: "Gray400") ?? .systemGray)
        
        // 활성/비활성 상태에 따른 배경/전경 색 결정
        let bg = isEnabled ? primaryBG : disabledBG
        let fg = isEnabled ? primaryFG : disabledFG
        
        return configuration.label
            // 기본 타이포그래피: 굵은 라운디드 헤드라인
            .font(.system(.title3, design: .rounded))
            .bold(true)
            // 전경색: 활성 시 흰색, 비활성 시 회색
            // NOTE: 라벨 고유 색을 유지하려면 `respectLabelColorWhenEnabled`를 활용해 조건부 적용하세요.
            .foregroundStyle(fg)
            // 내부 여백: 상하/좌우
            .padding(.vertical, vertical)
            .padding(.horizontal, horizontal)
            // 가로 최대 확장 여부
            .frame(maxWidth: expandToMaxWidth ? .infinity : nil)
            // 배경: 라운디드 사각형에 배경색 채우기
            .background(bg, in: RoundedRectangle(cornerRadius: cornerRadius, style: .continuous))
            // 테두리: 아주 옅은 외곽선으로 입체감 부여
            .overlay(
                RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                    .strokeBorder(Color.black.opacity(0.05), lineWidth: 0.5)
            )
            // 눌림 상태에서 살짝 투명해 보이도록 처리
            .opacity(configuration.isPressed ? 0.95 : 1)
            // 접근성 '동작 줄이기'가 꺼져 있을 때만 살짝 축소 애니메이션
            .scaleEffect(configuration.isPressed && !reduceMotion ? 0.97 : 1)
            // 눌림 상태 변화에 스프링 애니메이션 적용
            .animation(.spring(response: 0.25, dampingFraction: 0.9), value: configuration.isPressed)
            // 접근성: 버튼 역할 명시
            .accessibilityAddTraits(.isButton)
    }
}

// MARK: - Modifier
extension View {
    /// 손쉽게 기본(Primary) 버튼 스타일을 적용하는 헬퍼입니다.
    /// - Parameters:
    ///   - cornerRadius: 배경 모서리 반경
    ///   - vertical: 내부 세로 여백
    ///   - horizontal: 내부 가로 여백
    /// - Returns: Primary 스타일이 적용된 버튼 뷰
    /// - Usage:
    /// ```swift
    /// Button("확인") { /* action */ }
    ///     .plantPrimaryButton()
    /// ```
    func plantSecondaryButton(
        cornerRadius: CGFloat = cornerRadius4,
        vertical: CGFloat = vertical4,
        horizontal: CGFloat = 20
    ) -> some View {
        self.buttonStyle(
            PlantSecondaryButtonStyle(
                cornerRadius: cornerRadius,
                vertical: vertical,
                horizontal: horizontal
            )
        )
    }
}
