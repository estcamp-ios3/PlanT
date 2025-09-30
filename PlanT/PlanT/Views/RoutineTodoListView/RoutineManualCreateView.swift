import SwiftUI

struct RoutineManualCreateView: View {
    var body: some View {
        VStack(spacing: 12) {
            Text("직접 루틴 등록")
                .font(.largeTitle)
                .bold()
            Text("수동으로 루틴을 생성하세요.")
                .foregroundStyle(.secondary)
            RoundedRectangle(cornerRadius: 12)
                .stroke(style: StrokeStyle(lineWidth: 2, dash: [6]))
                .frame(height: 200)
        }
        .padding()
    }
}

#Preview {
    RoutineManualCreateView()
}
