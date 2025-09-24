import SwiftUI

struct NumberCircle: View {
    let number: Int
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
        .alignmentGuide(.firstTextBaseline) { d in
            d[VerticalAlignment.center] + baselineTweak
        }
    }
}

#Preview {
    NumberCircle(number: 1)
}
