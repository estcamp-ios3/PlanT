import SwiftUI

struct TutorialOverlayView: View {
    @ObservedObject var manager: TutorialManager
    let frames: [String: CGRect]
    let onFinish: () -> Void

    var body: some View {
        guard let step = manager.currentStep else {
            return AnyView(EmptyView())
        }

        // ✅ 일반 target (튜토리얼 앵커 프레임)
        let target = frames[step.id] ?? .zero

        return AnyView(
            ZStack {
                Color(.systemBackground)
                    .ignoresSafeArea()
                    .allowsHitTesting(false)

                // ✅ intro 단계일 경우 별도 디자인
                if step.id == "intro" {
                    VStack(spacing: 24) {
                        Spacer()
                        Image("MrGrrr") // ← 프로젝트 asset에 추가된 캐릭터 이름
                            .resizable()
                            .scaledToFit()
                            .frame(width: 130, height: 130)
                            .shadow(radius: 10)

                        Text(step.message)
                            .multilineTextAlignment(.center)
                            .foregroundColor(Color("BrandPrimary"))
                            .font(.title3.bold())
                            .padding(20)
                            .background(Color("BG_F2F2F2"))
                            .cornerRadius(16)
                            .padding(.horizontal, 30)

                        Button(action: {
                            manager.next()
                        }) {
                            Text("시작하기")
                        }
                        .plantPrimaryButton()
                        .padding(.horizontal, 30)
                        Spacer()
                    }
                    .transition(.opacity)
                } else {
                    // ✅ 나머지 단계 (기존 방식 유지)
                    VStack {
                        Spacer()
                            .frame(height:
                                target.isEmpty
                                ? 250 + step.verticalOffset
                                : target.maxY - 80 + step.verticalOffset
                            )
                        HStack {
                            Spacer()
                                .frame(width:
                                    target.isEmpty
                                    ? 24 + step.horizontalOffset
                                    : max(0, target.midX - 100 + step.horizontalOffset)
                                )

                            VStack(alignment: .leading, spacing: 12) {
                                Text(step.message)
                                    .foregroundColor(Color("BrandPrimary"))
                                    .font(.headline)
                                    .padding(14)
                                    .cornerRadius(12)

                                if !target.isEmpty {
                                    Image(systemName: "arrow.up")
                                        .font(.system(size: 36, weight: .bold))
                                        .foregroundColor(Color("BrandAccent"))
                                        .padding(.leading, 16)
                                }

                                if step.showNextButton {
                                    Button(action: {
                                        manager.next()
                                    }) {
                                        Text("다음")
                                          
                                    }
                                    .plantPrimaryButton()
                                    .frame(width: 80)                                }
                            }
                            Spacer()
                        }
                        Spacer()
                    }
                }
            }
            .animation(.easeInOut(duration: 0.3), value: manager.currentIndex)
        )
    }
}
