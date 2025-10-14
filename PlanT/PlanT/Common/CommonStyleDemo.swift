//
//  CommonStyleDemo.swift
//  PlanT
//
//  Created by catharina J on 9/29/25.
//

import SwiftUI

struct CommonStyleDemo: View {
    @State private var isAllDay = false
    @State private var isAny = false
    
    var body: some View {
        ScrollView {
            VStack(spacing: vertical5) {
                // MARK: - 주기능 버튼
                HStack(spacing: vertical3) {
                    Button { /* action */
                    } label: {
                        Text("Primary")
                    }
                    .plantPrimaryButton()
                    
                    Button { /* action */
                    } label: {
                        Text("Disabled")
                    }
                    .plantPrimaryButton()
                    .disabled(true)
                }
                
                // MARK: - 부기능 버튼
                HStack(spacing: vertical3) {
                    Button { /* action */
                    } label: {
                        Text("Secondary")
                    }
                    .plantSecondaryButton()
                    
                    Button { /* action */
                    } label: {
                        Text("Disabled")
                    }
                    .plantSecondaryButton()
                    .disabled(true)
                }
                
                // MARK: - 이미지는 비율에 맞춰 frame 사이즈 안에 잘리지 않도록 넣기
                HStack(alignment: .top) {
                    Image("sun_shine")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 100, height: 100)
                    
                    Image("seed_Sunflower05")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 250, height: 400)
                }
                
                // MARK: - 로그인 예시
                Button { /* action */
                } label: {
                    Text("로그인")
                }
                .plantPrimaryButton()
                // .disabled(userName.isEmpty || password.isEmpty))
                
                Spacer()
                
                // MARK: - 확인/취소 예시
                HStack(spacing: vertical3) {
                    Button { /* action */
                    } label: {
                        Text("취소")
                    }
                    .plantSecondaryButton()
                    
                    Button { /* action */
                    } label: {
                        Text("저장")
                    }
                    .plantPrimaryButton()
                }
            }
        }
        .padding()
        .background(Color(.systemBackground).ignoresSafeArea())
        // MARK: - 새로 만들기 버튼
        .overlay(alignment: .bottomTrailing) {
            Button { /* action */
            } label: {
                Image(systemName: "plus")
            }
            .plantFABStyle(diameter: 56, iconSize: 30, useAccent: true)
            .padding(20)
            .padding(.bottom, 68)
        }
        
        // MARK: - Checkbox + Label
        HStack(spacing: vertical3) {
            CheckLabelView(isChecked: $isAllDay, label: "종일")
            CheckLabelView(isChecked: $isAny, label: "종료일")
        }
    }
}
#Preview("Light") {
    CommonStyleDemo()
        .preferredColorScheme(.light)
}

#Preview("Dark") {
    CommonStyleDemo()
        .preferredColorScheme(.dark)
}
