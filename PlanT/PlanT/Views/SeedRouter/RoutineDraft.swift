// 설문 결과를 다음 화면(SeedStatusView)로 전달하기 위한 "루틴 초안" 모델
// - Navigation 경로(Route)에서 안전하게 사용하기 위해 Hashable을 채택했습니다.
// - 설문에서 선택한 옵션의 id와 사람이 읽기 쉬운 title을 모두 보관합니다.
import Foundation

/// 루틴 생성 직전까지의 임시 데이터 컨테이너 (최종 등록 시 Routine으로 변환)
struct RoutineDraft: Hashable, Identifiable {
    let id = UUID()
    // Store both ids and human-readable titles for flexibility
    var categoryId: String          // 설문에서 선택한 카테고리의 id
    var categoryTitle: String       // 카테고리의 표시용 제목
    var routineTypeId: String       // 루틴 종류(타입)의 id
    var routineTypeTitle: String    // 루틴 종류(타입)의 표시용 제목
    var frequencyPerWeekId: String  // 주당 빈도 id (예: "3x")
    var frequencyPerWeekTitle: String // 주당 빈도 표시용 제목 (예: "주 3회")
    var durationId: String          // 1회 수행 시간 id (예: "20분")
    var durationTitle: String       // 1회 수행 시간 표시용 제목
    var periodIsNoLimit: Bool       // 기간 제한 없음 여부 (true: 기간 없음)
    var reminderOn: Bool            // 알림 사용 여부
    var goal: String                
}
