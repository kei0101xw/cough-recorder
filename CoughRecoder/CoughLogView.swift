import SwiftUI
import AVFoundation

struct CoughLogView: View {
    @Binding var navigationPath: [String]
    @StateObject private var store = SessionStore()
    @Environment(\.horizontalSizeClass) private var hSize

    private let dateFormatter: DateFormatter = {
        let f = DateFormatter()
        f.locale = Locale(identifier: "ja_JP")
        f.dateFormat = "yyyy/MM/dd HH:mm"
        return f
    }()

    var body: some View {
        VStack {
            Text("咳記録ログ画面")
                .font(.system(size: AppUI.titleFontSize(hSize: hSize), weight: .regular))
                .padding(.vertical, 12)
            
            Divider()
            
            let isCompact = (hSize == .compact)

            if store.records.isEmpty {
                Spacer()
                Text("保存済みの記録はまだありません。")
                    .font(.system(size: 20))
                    .foregroundColor(.secondary)
                Spacer()
            } else {
                ScrollView(isCompact ? [.vertical, .horizontal] : [.vertical]) {
                    Grid(alignment: .leading, horizontalSpacing: 60, verticalSpacing: 15) {

                        GridRow {
                            Text("保存日時").bold()
                            Text("ID").bold()
                            Text("施設").bold()
                            Text("性別").bold()
                            Text("年齢").bold()
                            Text("音声").bold()
                        }
                        .font(.system(size: AppUI.sentenceFontSize(hSize: hSize)))
                        .padding(.bottom, 5)

                        Divider().gridCellUnsizedAxes(.horizontal)

                        ForEach(store.records) { r in
                            GridRow {
                                Text(dateFormatter.string(from: r.payload.savedAt))
                                Text(r.payload.id.isEmpty ? "—" : r.payload.id)
                                Text(r.payload.facility.isEmpty ? "—" : r.payload.facility)
                                Text(r.payload.gender.isEmpty ? "—" : r.payload.gender)
                                Text(r.payload.age.map(String.init) ?? "—")

                                LogAudioPreviewButton(url: r.audioURL)
                            }

                            Divider().gridCellUnsizedAxes(.horizontal)
                        }
                    }
                    .font(.system(size: AppUI.sentenceFontSize(hSize: hSize)))
                    .padding()
                }
            }

            Spacer()

            Divider()
            
            Button(action: {
                navigationPath.removeAll()
            }) {
                Text("ホームへ戻る")
                    .frame(width: UIScreen.main.bounds.width / 2)
                    .frame(height: AppUI.buttonHeight(hSize: hSize))
                    .font(.system(size: AppUI.buttonFontSize(hSize: hSize)))
                    .padding(.horizontal)
                    .background(Color.gray.opacity(0.2))
                    .cornerRadius(10)
            }
            .padding()
        }
        .navigationBarBackButtonHidden(true)
        .onAppear { store.reload() }
    }
}

final class LogPlayerDelegateBox: NSObject, AVAudioPlayerDelegate {
    var onFinish: (() -> Void)?
    func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool) {
        onFinish?()
    }
}

private func prepareAudioSessionForPlayback() throws {
    let s = AVAudioSession.sharedInstance()
    try s.setCategory(.playback, options: [.duckOthers])
    try s.setActive(true)
}

struct LogAudioPreviewButton: View {
    let url: URL

    @State private var player: AVAudioPlayer?
    @State private var isPlaying = false
    @State private var delegateBox = LogPlayerDelegateBox()

    var body: some View {
        HStack(spacing: 12) {
            Button {
                toggle()
            } label: {
                HStack(spacing: 8) {
                    Image(systemName: isPlaying ? "pause.circle.fill" : "play.circle.fill")
                        .resizable()
                        .scaledToFit()
                        .frame(height: 26)
                    Text(isPlaying ? "停止" : "再生")
                        .font(.system(size: 14, weight: .semibold))
                    // 18かも！！！！！！！！！！！！！！！！！！！！！！！！！！！
                }
            }
            .buttonStyle(.plain)
        }
        .onDisappear { stop() }
    }

    private func toggle() {
        if isPlaying {
            pause()
            return
        }
        do {
            try prepareAudioSessionForPlayback()
            if let p = player {
                p.play()
                isPlaying = true
                return
            }
            let p = try AVAudioPlayer(contentsOf: url)
            p.prepareToPlay()
            delegateBox.onFinish = {
                DispatchQueue.main.async {
                    self.isPlaying = false
                }
            }
            p.delegate = delegateBox
            p.play()
            player = p
            isPlaying = true
        } catch {
            print("play error:", error)
        }
    }

    private func pause() {
        player?.pause()
        isPlaying = false
    }

    private func stop() {
        player?.stop()
        player = nil
        isPlaying = false
        try? AVAudioSession.sharedInstance().setActive(false, options: .notifyOthersOnDeactivation)
    }
}

#Preview {
    CoughLogView(navigationPath: .constant([]))
}
