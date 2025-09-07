//
//  NumberCircle.swift
//  CoughRecoder
//
//  Created by 原田佳祐 on 2025/09/07.
//

import SwiftUI

struct NumberCircle: View {
    let number: Int
    /// 丸のベースライン微調整（負にすると丸が上がる）
    let baselineTweak: CGFloat

    init(number: Int, baselineTweak: CGFloat = 8) {
        self.number = number
        self.baselineTweak = baselineTweak
    }

    var body: some View {
        ZStack {
            Circle()
                .fill(Color.blue)
                .frame(width: 40, height: 40)
            Text("\(number)")
                .font(.system(size: 20, weight: .bold))
                .foregroundColor(.white)
        }
        // ベースライン＝「円の中心」から少し上へ（負方向）シフト
        .alignmentGuide(.firstTextBaseline) { d in
            d[VerticalAlignment.center] + baselineTweak
        }
    }
}

#Preview {
    NumberCircle(number: 1)
}
