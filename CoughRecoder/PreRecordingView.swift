import SwiftUI

struct PreRecordingView: View {
    @Binding var navigationPath: [String]
    @Environment(\.horizontalSizeClass) private var hSize
    
    var body: some View {
        VStack {
            Text("録音を開始します")
                .font(.system(size: AppUI.titleFontSize(hSize: hSize), weight: .regular))
                .padding(.vertical, 12)
            Divider()
            
            if hSize == .compact {
                GeometryReader { proxy in
                    let gap = Layout.verticalGap(hSize)
                    VStack(spacing: gap) {
                        VStack(alignment: .leading, spacing: 8) {
                            PreRecoRow(
                                number: 1,
                                text: "静かな環境で録音してください。",
                                fontSize: Layout.fontSize(hSize)
                            )
                            Spacer()
                            Image(.preReco1)
                                .resizable()
                                .scaledToFit()
                                .frame(height: Layout.imageSize(hSize))
                                .frame(maxWidth: .infinity, alignment: .center)
                            Spacer()
                        }
                        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
                        .padding(.horizontal)

                        VStack(alignment: .leading, spacing: 8) {
                            PreRecoRow(
                                number: 2,
                                text: "録音時に「咳をしてください」などの、周辺からの話しかけはしないでください。",
                                fontSize: Layout.fontSize(hSize)
                            )
                            Spacer()
                            Image(.preReco2)
                                .resizable()
                                .scaledToFit()
                                .frame(height: Layout.imageSize(hSize))
                                .frame(maxWidth: .infinity, alignment: .center)
                            Spacer()
                        }
                        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
                        .padding(.horizontal)

                        VStack(alignment: .leading, spacing: 8) {
                            PreRecoRow(
                                number: 3,
                                text: "録音は5秒以上30秒以内で最低3回以上の咳をしてください。",
                                fontSize: Layout.fontSize(hSize)
                            )
                            Spacer()
                            Image(.preReco3)
                                .resizable()
                                .scaledToFit()
                                .frame(height: Layout.imageSize(hSize))
                                .frame(maxWidth: .infinity, alignment: .center)
                            Spacer()
                        }
                        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
                        .padding(.horizontal)
                    }
                    .frame(width: proxy.size.width, height: proxy.size.height)
                    .padding(.vertical, gap)
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .padding(.horizontal)
            } else {
                HStack(alignment: .top) {
                    VStack {
                        HStack(alignment: .firstTextBaseline) {
                            NumberCircle(number: 1)
                            Text("静かな環境で録音してください。")
                                .font(.system(size: Layout.fontSize(hSize)))
                        }
                        .frame(height: 150, alignment: .top)

                        Image(.preReco1)
                            .resizable()
                            .scaledToFit()
                            .frame(height: 250)
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.horizontal)
                    VStack {
                        HStack(alignment: .firstTextBaseline) {
                            NumberCircle(number: 2)
                            Text("録音時に「咳をしてください」などの、周辺からの話しかけはしないでください。")
                                .font(.system(size: Layout.fontSize(hSize)))
                        }
                        .frame(height: 150, alignment: .top)

                        Image(.preReco2)
                            .resizable()
                            .scaledToFit()
                            .frame(height: 250)
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.horizontal)
                    VStack {
                        HStack(alignment: .firstTextBaseline) {
                            NumberCircle(number: 3)
                            Text("録音は5秒以上30秒以内で最低3回以上の咳をしてください。")
                                .font(.system(size: Layout.fontSize(hSize)))
                        }
                        .frame(height: 150, alignment: .top)

                        Image(.preReco3)
                            .resizable()
                            .scaledToFit()
                            .frame(height: 250)
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.horizontal)
                }
                .padding(.horizontal)
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            }
            
            Divider()
            
            HStack {
                Button(action: {
                    navigationPath.removeLast()
                }) {
                    Text("戻る")
                        .frame(maxWidth: .infinity)
                        .frame(height: AppUI.buttonHeight(hSize: hSize))
                        .font(.system(size: AppUI.buttonFontSize(hSize: hSize)))
                        .padding(.horizontal)
                        .background(Color.gray.opacity(0.2))
                        .cornerRadius(10)
                }
                
                Button(action: {
                    navigationPath.append("Recording")
                }) {
                    Text("録音開始")
                        .frame(maxWidth: .infinity)
                        .frame(height: AppUI.buttonHeight(hSize: hSize))
                        .font(.system(size: AppUI.buttonFontSize(hSize: hSize), weight: .semibold))
                        .padding(.horizontal)
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(10)
                }
            }
            .padding()
        }
        .navigationBarBackButtonHidden(true)
    }
}

extension View {
    @ViewBuilder
    func onChangeCompat<V: Equatable>(
        _ value: V,
        perform: @escaping (V) -> Void
    ) -> some View {
        if #available(iOS 17.0, *) {
            self.onChange(of: value) { _, newValue in
                perform(newValue)
            }
        } else {
            self.onChange(of: value, perform: perform)
        }
    }
}

// compact 用：行数に応じて数字バッジをテキストの縦中央に揃える
private struct PreRecoRow: View {
    let number: Int
    let text: String
    let fontSize: CGFloat

    @State private var textHeight: CGFloat = 0

    var body: some View {
        HStack(alignment: .center, spacing: 20) {
            NumberCircle(number: number)
                .frame(
                    width: fontSize * 1.6,
                    height: max(fontSize * 1.6, textHeight)
                )

            Text(text)
                .font(.system(size: fontSize))
                .fixedSize(horizontal: false, vertical: true)
                .background(
                    GeometryReader { geo in
                        Color.clear
                            .onAppear { textHeight = geo.size.height }
                            // ★ ここを置き換え：非推奨APIではなく互換ヘルパーを使用
                            .onChangeCompat(geo.size.height) { newHeight in
                                textHeight = newHeight
                            }
                    }
                )
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.horizontal, 10)
    }
}

extension PreRecordingView {
    enum Layout {
        static func fontSize(_ hSize: UserInterfaceSizeClass?) -> CGFloat {
            (hSize == .compact) ? 14 : 25
        }
        static func imageSize(_ hSize: UserInterfaceSizeClass?) -> CGFloat {
            (hSize == .compact) ? 100 : 250
        }
        static func verticalGap(_ hSize: UserInterfaceSizeClass?) -> CGFloat {
            (hSize == .compact) ? 12 : 16
        }
    }
}

#Preview {
    PreRecordingView(navigationPath: .constant([]))
        .environmentObject(RecordingSession())
}
