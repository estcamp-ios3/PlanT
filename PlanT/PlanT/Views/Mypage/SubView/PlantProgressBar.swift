//
//  PlantProgressBar.swift
//  PlanT
//
//  Created by 이지훈 on 9/30/25.
//

import SwiftUI

public struct BrandColors {
    public static var primaryFill: Color {
        Color(uiColor: UIColor(named: "BrandPrimary") ?? .systemGreen)
    }
    public static var secondaryTrack: Color {
        Color(uiColor: UIColor(named: "BrandSecondary") ?? .systemGray5)
    }
}

public struct PlantProgressBar: View {
    public var progress: Double
    public var height: CGFloat

    public init(progress: Double, height: CGFloat = 14) {
        self.progress = progress
        self.height = height
    }

    public var body: some View {
        GeometryReader { geo in
            let width = geo.size.width
            let clamped = min(max(progress, 0), 1)

            ZStack(alignment: .leading) {
                Capsule().fill(BrandColors.secondaryTrack)
                Capsule()
                    .fill(BrandColors.primaryFill)
                    .frame(width: width * clamped)
            }
        }
        .frame(height: height)
    }
}

#Preview {
    PlantProgressBar(progress: 0.25, height: vertical4)
}
