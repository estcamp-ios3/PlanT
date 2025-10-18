//
//  BottomSheetView.swift
//  PlanT
//
//  Created by 박성관 on 10/17/25.
//

import SwiftUI

struct BottomSheetView<Content: View>: View {
    @Binding var isPresented: Bool
    let content: Content
    var onDone: (() -> Void)? = nil

    init(
        isPresented: Binding<Bool>,
        title: String = "",
        onDone: (() -> Void)? = nil,
        @ViewBuilder content: () -> Content
    ) {
        self._isPresented = isPresented
        self.content = content()
        self.onDone = onDone
    }

    var body: some View {
        if isPresented {
            ZStack {
                Color.black.opacity(0.35)
                    .ignoresSafeArea()
                    .onTapGesture {
                        withAnimation(.spring()) {
                            isPresented = false
                        }
                    }
                VStack {
                    Spacer()
                    VStack(spacing: 16) {
                        HStack {
                          
                            Spacer()
                            Button("완료") {
                                onDone?()
                                withAnimation {
                                    isPresented = false
                                }
                            }
                            .font(.headline.bold())
                            .padding(.trailing, 16)
                            .padding(.bottom, 4)
                        }
                        .padding(.horizontal)
                        .padding(.top, 10)
                        
                        content
                            .padding(.horizontal, 20)
                            .padding(.bottom, 30)
                    }
                    .background(Color.white)
                    .cornerRadius(20)
                    .shadow(radius: 10)
                    .transition(.move(edge: .bottom).combined(with: .opacity))
                }
                .ignoresSafeArea(edges: .bottom)
            }
            .animation(.spring(), value: isPresented)
        }
    }
}
