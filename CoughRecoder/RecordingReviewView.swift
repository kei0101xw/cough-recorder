import SwiftUI
import AVFoundation

struct RecordingReviewView: View {
    @Binding var navigationPath: [String]
    @EnvironmentObject var session: RecordingSession

    @State private var player: AVAudioPlayer?
    @State private var isPlaying = false
    @State private var errorMessage: String?
    @State private var showingErrorAlert = false
    @State private var delegateBox = AudioPlayerDelegateBox() // ★ 強参照で保持

    var body: some View {
        VStack {
            Text("録音の確認")
                .font(.system(size: 30, weight: .regular))
                .padding(.vertical, 12)
            
            Divider()

            Spacer()

            Button {
                togglePlayback()
            } label: {
                Image(systemName: isPlaying ? "pause.circle.fill" : "play.circle.fill")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 300, height: 300)
                    .foregroundColor(.red)
            }

            Spacer()
            
            Text("以下の項目をご確認ください。")
                .font(.system(size: 25))
            
            VStack(alignment: .leading) {
                HStack {
                    NumberCircle(number: 1)
                    Text("咳以外の音が入っていないか")
                        .font(.system(size: 25))
                }
                HStack {
                    NumberCircle(number: 2)
                    Text("咳が途中で切れていないか")
                        .font(.system(size: 25))
                }
            }
            .padding()

            Spacer()

            HStack {
                Button {
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
                } label: {
                    Text("やり直す")
                        .frame(maxWidth: .infinity, minHeight: 60)
                        .font(.system(size: 32))
                        .padding(.horizontal)
                        .background(Color.gray.opacity(0.2))
                        .cornerRadius(10)
                }

                Button {
                    stopPlayback()
                    navigationPath.append("PatientInfoForm")
                } label: {
                    Text("録音完了")
                        .frame(maxWidth: .infinity, minHeight: 60)
                        .font(.system(size: 32))
                        .padding(.horizontal)
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(10)
                }
            }
            .padding()
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

                // ★ 再生終了でUIを戻す
                delegateBox.onFinish = {
                    DispatchQueue.main.async {
                        self.isPlaying = false
                        self.player = nil
                        // 必要なら頭出し: p?.currentTime = 0
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
        player = nil          // ★ 明示的に破棄
        isPlaying = false
    }
}

#Preview {
    RecordingReviewView(navigationPath: .constant([]))
        .environmentObject(RecordingSession())
}
