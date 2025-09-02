
import SwiftUI
import AVFoundation

struct RecordingReviewView: View {
    @Binding var navigationPath: [String]
    @EnvironmentObject var session: RecordingSession

    @State private var player: AVAudioPlayer?
    @State private var isPlaying = false
    @State private var errorMessage: String?
    @State private var showingErrorAlert = false

    var body: some View {
        VStack {
            Text("録音の確認")
                .font(.system(size: 60))
                .padding()

            Spacer()

            Button {
                togglePlayback()
            } label: {
                Image(systemName: isPlaying ? "pause.circle.fill" : "play.circle.fill")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 300, height: 300)
                    .foregroundColor(.startButton)
            }

            Spacer()

            Text("""
                 ・咳以外の音が入っていないか
                 ・咳が途中で切れていないか　などを確認してください。
                 """)
            .font(.system(size: 40))
            .padding()
            .background(Color.gray.opacity(0.1))
            .cornerRadius(10)

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
                    navigationPath.append("GenderAgeForm")
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
                player = try AVAudioPlayer(contentsOf: url)
                player?.prepareToPlay()
                player?.play()
                isPlaying = true
            } catch {
                errorMessage = error.localizedDescription
                showingErrorAlert = true
            }
        }
    }

    private func stopPlayback() {
        player?.stop()
        isPlaying = false
    }
}

#Preview {
    RecordingReviewView(navigationPath: .constant([]))
        .environmentObject(RecordingSession())
}
