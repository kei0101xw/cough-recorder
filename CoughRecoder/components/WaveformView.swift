import SwiftUI


struct WaveformView: View {
    let levels: [CGFloat]

    var body: some View {
        GeometryReader { geo in
            let count = max(levels.count, 1)
            let barWidth = geo.size.width / CGFloat(count)
            let midY = geo.size.height / 2

            Canvas { context, size in
                for (i, level) in levels.enumerated() {
                    let h = max(2, level * size.height)
                    let x = CGFloat(i) * barWidth
                    let rectTop = CGRect(x: x, y: midY - h/2, width: barWidth * 0.8, height: h)
                    context.fill(Path(roundedRect: rectTop, cornerRadius: barWidth * 0.25), with: .color(.red))
                }
            }
        }
        .accessibilityLabel("音量波形")
        .drawingGroup()
    }
}

