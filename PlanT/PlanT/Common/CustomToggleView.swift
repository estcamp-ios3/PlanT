//
//  CustomToggleView.swift
//  PlanT
//
//  Created by 박성관 on 10/13/25.
//
import SwiftUI


struct CustomToggleView: View {
    @Binding var isOn: Bool
    
    var body: some View {
        ZStack(alignment: isOn ? .trailing : .leading)  {
            RoundedRectangle(cornerRadius: 16)
                .fill(isOn ? Color.orange : Color.gray.opacity(0.3))
                .frame(width: 50, height: 28)
                .animation(.easeInOut(duration: 0.2), value: isOn)
            
            Circle()
                .fill(Color.white)
                .frame(width: 24, height: 24)
                .padding(2)
                .shadow(radius: 1)
        }
        .onTapGesture {
            withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                isOn.toggle()
            }
        }
    }
}
