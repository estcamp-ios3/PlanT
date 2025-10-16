//
//  MyPageUserCardView.swift
//  PlanT
//
//  Created by 이지훈 on 9/30/25.
//

import SwiftUI

struct MypageUserCardView: View {
    @ObservedObject var viewModel: MypageUserCardViewModel
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            // 상단: 아바타 + 닉네임 + 설정 버튼
            HStack(alignment: .center, spacing: 12) {
                Image(viewModel.model.mateName)
                    .resizable()
                    .scaledToFit()
                    .frame(width: 48, height: 48)
                    .padding(6)
                    .background(Circle().fill(Color.white))
                
                Text(viewModel.model.nickName)
                    .font(.system(size: 18, weight: .heavy))
                    .foregroundColor(.black)
                    .lineSpacing(2)
                
                Spacer()
            }
            .overlay(alignment: .topTrailing) {
                
                Button("설정") {
                    viewModel.tapSettings()
                }
                .font(.system(size: 14, weight: .semibold))
                .foregroundColor(.gray)
                .padding(6)
            }
            
            // 하단 통계 섹션
            HStack(spacing: 16) {
                StatItem(
                    icon: Image(systemName: "leaf.fill"),
                    label: "성장중인 작물",
                    value: viewModel.model.growingCount,
                    tint: Color.green
                )
                StatItem(
                    icon: Image(systemName: "globe"),
                    label: "수확한 작물",
                    value: viewModel.model.harvestedCount,
                    tint: Color.blue
                )
                StatItem(
                    icon: Image(systemName: "circlebadge.fill"),
                    label: "보유포인트",
                    value: viewModel.model.points,
                    tint: Color.orange
                )
            }
        }
        .padding(8)
        .background(
            RoundedRectangle(cornerRadius: 20, style: .continuous)
                .fill(Color(UIColor.systemGray6))
        )
        // ✅ ViewModel이 관리하는 상태를 이용해 화면 이동
        .navigationDestination(isPresented: $viewModel.isShowingSetting) {
            SettingView()
        }
    }
}

// 내부에서 쓰는 서브뷰(같은 파일에 포함)
private struct StatItem: View {
    let icon: Image
    let label: String
    let value: Int
    let tint: Color
    
    var body: some View {
        HStack(spacing: 10) {
            icon
                .resizable()
                .scaledToFit()
                .frame(width: 28, height: 28)
                .foregroundStyle(tint)
                .shadow(color: .black.opacity(0.08), radius: 2, x: 0, y: 1)
            
            VStack(alignment: .leading, spacing: 2) {
                Text(label)
                    .font(.system(size: 12, weight: .semibold))
                    .lineLimit(1)
                    .minimumScaleFactor(0.8)
                
                Text(value.formatted(.number.grouping(.automatic)))
                    .font(.system(size: 20, weight: .bold))
                    .foregroundColor(tint)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}

private struct MypageUserCardView_PreviewWrapper: View {
    @StateObject var mock = AuthStore()
    
    var body: some View {
        let vm = MypageUserCardViewModel(authStore: mock)
        
        MypageUserCardView(viewModel: vm)
            .environmentObject(mock)
            .padding()
            .background(Color.white)
            .onAppear {
                mock.nickName = "나는 확신의 P이다\n이번에는 꼭 완료해야지"
                mock.mate = "MrPurr"
            }
    }
}

#Preview {
    NavigationStack {
        MypageUserCardView_PreviewWrapper()
    }
}
