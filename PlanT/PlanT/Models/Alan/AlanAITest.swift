//
//  AlanAITest.swift
//  PlanT
//
//  Created by 이지훈 on 10/17/25.
//

import SwiftUI
import AlanAI

let clientId = "89a3432c-e591-4751-9b97-2d4fc2d9fa6a" // 지훈 키값
let alanAI = AlanAI(clientID: clientId)

let routine = [
    "물마시기, 아침 6시 기상시, 500ml, 1잔, 총7회 중 6회 완료",
    "운동하기, 아침 7시 기상시, 30분, 3회, 총5회 중 2회 완료",
    "독서하기, 아침 8시 기상시, 1시간, 1회, 총4회 중 2회 완료"
]

let question1 = """
다음 조건에 맞는 답변을 한국어로 제공해.
1. 각 \(routine)에 대해 응원의 말을 달성율에 따라 다음과 같은 형식으로 적어줘:
~~만큼 했어요(예: 거의 다 했다, 반 정도 달성했다, 시작이 반이다 이런 식으로). 앞으로 n회만 하면 목표 달성이에요!
"""

struct AlanAITest: View {
    @State private var answer: String = ""

    var body: some View {
        VStack(spacing: 16) {
            ScrollView {
                Text(answer)
                    .frame(maxWidth: .infinity, alignment: .center)
                    .multilineTextAlignment(.center)
                    .padding()
            }

            Button("Ask Alan") {
                Task {
                    // ✅ 1️⃣ 먼저 “응답 생성중” 표시
                    await MainActor.run {
                        answer = "🤖 응답 생성중..."
                    }

                    // ✅ 2️⃣ 실제 AlanAI 호출 후 결과 표시
                    let result = await askAlan(question: question1)
                    await MainActor.run {
                        answer = result
                    }
                }
            }
            .buttonStyle(.borderedProminent)
        }
        .padding()
    }
}

func askAlan(question: String) async -> String {
    do {
        let response: AlanResponse? = try await alanAI.question(query: question)
        if let response {
            return response.content ?? "N/A"
        } else {
            return "❌ AlanAI 응답이 비어 있습니다."
        }
    } catch {
        print("❌ AlanAI Error:", error.localizedDescription)
        return "❌ 오류 발생: \(error.localizedDescription)"
    }
}

#Preview {
    AlanAITest()
}
