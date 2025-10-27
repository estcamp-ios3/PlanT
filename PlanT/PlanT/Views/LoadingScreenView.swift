//
//  LoadingScreenView.swift
//  PlanT
//
//  Created by catharina J on 10/20/25.
//
import SwiftUI
import Lottie

//Getting started with dotLottie - https://lottiefiles.notion.site/Getting-started-with-dotLottie-907cb7b157b34990a7bba7bcae8f21b0

struct LoadingScreenView: View {
    var body: some View {
        VStack {
            Text("씨앗 심는중")
                .font(.largeTitle)
                .bold(true)
            
            LottieView(animation: .named("seedsLottie")) // 파일명.json
                .playbackMode(.playing(.fromProgress(0, toProgress: 1, loopMode: .loop)))
                .frame(width: 320, height: 400)
                .scaleEffect(3.0)
                .accessibilityHidden(true)
        }
        .padding(.bottom, 34)
    }
}

#Preview {
    LoadingScreenView()
}
