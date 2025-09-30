import SwiftUI

struct PlantAssistantView: View {
    var body: some View {
        VStack {
            Text("PlanT와 루틴 만들기")
                .font(.largeTitle)
                .bold()
            Text("여기에서 PlanT가 루틴을 함께 설계해 드려요.")
                .padding()
        }
    }
}

#Preview {
    PlantAssistantView()
}
