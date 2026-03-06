import SwiftUI
import AVFoundation

struct RecordingReviewView: View {
    @Binding var navigationPath: [String]
    @EnvironmentObject var session: RecordingSession
    @Environment(\.horizontalSizeClass) private var hSize

    @State private var player: AVAudioPlayer?
    @State private var isPlaying = false
    @State private var errorMessage: String?
    @State private var showingErrorAlert = false
    @State private var delegateBox = AudioPlayerDelegateBox()
    @State private var showRedoAlert = false

    var body: some View {
        VStack {
            Text("録音の確認")
                .font(.system(size: AppUI.titleFontSize(hSize: hSize), weight: .regular))
                .padding(.vertical, 12)

            Divider()

            Spacer()

            Button {
                togglePlayback()
            } label: {
                Image(systemName: isPlaying ? "pause.circle.fill" : "play.circle.fill")
                    .resizable()
                    .scaledToFit()
                    .frame(width: Layout.imageHeight(hSize), height: Layout.imageHeight(hSize))
                    .foregroundColor(.red)
            }

            Spacer()

            Text("以下の項目をご確認ください。")
                .font(.system(size: Layout.fontSize(hSize)))

            VStack(alignment: .leading) {
                HStack {
                    NumberCircle(number: 1)
                    Text("咳以外の音が入っていないか")
                        .font(.system(size: Layout.fontSize(hSize)))
                }
                HStack {
                    NumberCircle(number: 2)
                    Text("咳が途中で切れていないか")
                        .font(.system(size: Layout.fontSize(hSize)))
                }
            }
            .padding()

            Spacer()
            Divider()
            HStack {
                Button {
                    showRedoAlert = true
                } label: {
                    Text("やり直す")
                        .frame(maxWidth: .infinity)
                        .frame(height: AppUI.buttonHeight(hSize: hSize))
                        .font(.system(size: AppUI.buttonFontSize(hSize: hSize)))
                        .padding(.horizontal)
                        .background(Color.gray.opacity(0.2))
                        .cornerRadius(10)
                }

                Button {
                    stopPlayback()
                    navigationPath.append("PatientInfoForm")
                } label: {
                    Text("録音完了")
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
            .alert("録音をやり直しますか？", isPresented: $showRedoAlert) {
                Button("閉じる", role: .cancel) { }
                Button("やり直す", role: .destructive) {
                    performRedo()
                }
            } message: {
                Text("現在の録音は削除されます。元に戻すことはできません。")
            }
        }
        .navigationBarBackButtonHidden(true)
        .alert("再生エラー", isPresented: $showingErrorAlert) {
            Button("OK", role: .cancel) { }
        } message: {
            Text(errorMessage ?? "不明なエラーです")
        }
        .onDisappear {
            stopPlayback()
        }
    }

    private func togglePlayback() {
        guard let url = session.recordingURL else {
            errorMessage = "録音ファイルが見つかりません。"
            showingErrorAlert = true
            return
        }
        if isPlaying {
            stopPlayback()
        } else {
            do {
                let p = try AVAudioPlayer(contentsOf: url)
                p.prepareToPlay()

                delegateBox.onFinish = {
                    DispatchQueue.main.async {
                        self.isPlaying = false
                        self.player = nil
                    }
                }
                p.delegate = delegateBox

                p.play()
                player = p
                isPlaying = true
            } catch {
                errorMessage = error.localizedDescription
                showingErrorAlert = true
            }
        }
    }

    private func stopPlayback() {
        player?.stop()
        player = nil
        isPlaying = false
    }

    private func performRedo() {
        stopPlayback()
        if let url = session.recordingURL {
            try? FileManager.default.removeItem(at: url)
        }
        session.recordingURL = nil
        if navigationPath.count >= 2 {
            navigationPath.removeLast(2)
        } else {
            navigationPath.removeAll()
        }
    }
}

extension RecordingReviewView {
    enum Layout {
        static func imageHeight(_ hSize: UserInterfaceSizeClass?) -> CGFloat {
            (hSize == .compact) ? 200 : 300
        }
        static func fontSize(_ hSize: UserInterfaceSizeClass?) -> CGFloat {
            (hSize == .compact) ? 17 : 25
        }
    }
}

#Preview {
    RecordingReviewView(navigationPath: .constant([]))
        .environmentObject(RecordingSession())
}
