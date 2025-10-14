//
//  CustomToggleView.swift
//  PlanT
//
//  Created by 박성관 on 10/13/25.
//
import SwiftUI

struct CustomToggleStyle: ToggleStyle {
    var width: CGFloat = 45
    var height: CGFloat = 8
    var circleSize: CGFloat = 24
    var onColor: Color = Color("F2E1AC")
    var circleColor: Color = Color(.systemOrange)
    var offColor: Color = Color(.systemGray5)
    
    func makeBody(configuration: Configuration) -> some View {
        Button {
            withAnimation(.spring(response: 0.25, dampingFraction: 0.8)) {
                configuration.isOn.toggle()
            }
        } label: {
            ZStack(alignment: configuration.isOn ? .trailing : .leading) {
                RoundedRectangle(cornerRadius: height / 2)
                    .fill(configuration.isOn ? onColor : offColor)
                    .frame(width: width, height: height)
                
                Circle()
                    .fill(circleColor)
                    .frame(width: circleSize, height: circleSize)
                    .padding(2)
            }
        }
        
        .buttonStyle(.plain)
        
    }
}


