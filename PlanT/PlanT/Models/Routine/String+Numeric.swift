import Foundation

public extension String {
    /// 문자열에서 숫자 문자만 추출하여 Int64로 변환합니다.
    /// - Returns: 변환에 성공하면 Int64 값을 반환합니다. 문자열에 숫자가 없으면 0을 반환합니다.
    /// - Note: 문자열이 순수 숫자(예: "123")인 경우 그대로 변환합니다. 혼합 문자열(예: "3x")의 경우 숫자만 추출하여("3") 변환합니다.
    func numericInt64(fallback: Int64 = 0) -> Int64 {
        if let direct = Int64(self) { return direct }
        let digits = self.compactMap { $0.isNumber ? $0 : nil }
        guard !digits.isEmpty else { return fallback }
        return Int64(String(digits)) ?? fallback
    }
}

