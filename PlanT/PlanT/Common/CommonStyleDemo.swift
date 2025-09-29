//
//  CommonStyleDemo.swift
//  PlanT
//
//  Created by catharina J on 9/29/25.
//

import SwiftUI

struct CommonStyleDemo: View {
    var body: some View {
        VStack {
            HStack(spacing: 16) {
                Button {
                    // action
                }
                label:{
                    Text("Primary")
                }
                .plantPrimaryButton()
                
                Button { }
                label:{
                    Text("Disabled")
                }
                .plantPrimaryButton()
                .disabled(true)
            }
            
            HStack(spacing: 16) {
                Button { }
                label:{
                    Text("Secondary")
                }
                .plantSecondaryButton()
                
                Button { }
                label:{
                    Text("Disabled")
                }
                .plantSecondaryButton()
                .disabled(true)
            }
            
            Spacer()
            
            VStack{
                Button { }
                label:{
                    Text("로그인")
                }
                .plantPrimaryButton()
//                .disabled(userName.isEmpty || password.isEmpty))
            }
            
            Spacer()
            
            HStack(spacing: 16) {
                Button { }
                label:{
                    Text("취소")
                }
                .plantSecondaryButton()
                
                Button { }
                label:{
                    Text("저장")
                }
                .plantPrimaryButton()
            }
        }
        .padding()
        .background(Color(.systemBackground).ignoresSafeArea())
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
