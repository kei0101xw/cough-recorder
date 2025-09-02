import SwiftUI

struct RecordingView: View {
    @Binding var navigationPath: [String]
    @EnvironmentObject var session: RecordingSession

    @StateObject private var audioRecorder = AudioRecorder()

    @State private var countdown: Int = 3
    @State private var showRecordingUI = false
    @State private var micPulse = false
    @State private var errorMessage: String?
    @State private var showingErrorAlert = false
    @State private var finishing = false

    var body: some View {
        VStack {
            if showRecordingUI {
                Spacer()
                Text("録音中")
                    .font(.system(size: 60))
                    .foregroundColor(.white)
                    .padding(32)
                    .background(Color.red)
                    .cornerRadius(100)

                Spacer()
                Image(systemName: "mic.fill")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 200, height: 200)
                    .foregroundColor(.red)
                    .scaleEffect(micPulse ? 1.1 : 1.0)
                    .animation(.easeInOut(duration: 1.0).repeatForever(autoreverses: true), value: micPulse)
                Spacer()

                HStack {
                    Button {
                        audioRecorder.discardAndDeleteFile()
                        session.recordingURL = nil
                        navigationPath.removeLast()
                    } label: {
                        Text("やり直し")
                            .frame(maxWidth: .infinity, minHeight: 60)
                            .font(.system(size: 32))
                            .padding(.horizontal)
                            .background(Color.gray.opacity(0.2))
                            .cornerRadius(10)
                    }

                    Button {
                        guard !finishing else { return }
                        finishing = true
                        audioRecorder.stopRecording { url in
                            DispatchQueue.main.async {
                                finishing = false
                                if let url {
                                    session.recordingURL = url
                                    navigationPath.append("RecordingReview")
                                } else {
                                    errorMessage = "録音の保存に失敗しました。もう一度お試しください。"
                                    showingErrorAlert = true
                                }
                            }
                        }
                    } label: {
                        Text(finishing ? "処理中…" : "録音完了")
                            .frame(maxWidth: .infinity, minHeight: 60)
                            .font(.system(size: 32))
                            .padding(.horizontal)
                            .background(finishing ? Color.gray : Color.blue)
                            .foregroundColor(.white)
                            .cornerRadius(10)
                    }
                }
                .padding()

            } else {
                Spacer()
                Text("カウントダウンが終了すると自動で録音が開始されます")
                    .font(.system(size: 45))
                Spacer()
                Text("\(countdown)")
                    .font(.system(size: 200))
                    .bold()
                    .frame(width: 400, height: 400)
                    .background(Color.white)
                    .clipShape(Circle())
                    .overlay(Circle().stroke(Color.blue, lineWidth: 5))
                Spacer()
            }
        }
        .onAppear { startCountdown() }
        .navigationBarBackButtonHidden(true)
        .alert("録音エラー", isPresented: $showingErrorAlert) {
            Button("OK") { navigationPath.removeLast() }
        } message: {
            Text(errorMessage ?? "不明なエラーです")
        }
    }

    private func startCountdown() {
        Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { timer in
            if countdown > 1 {
                countdown -= 1
            } else {
                timer.invalidate()
                audioRecorder.startRecording { result in
                    DispatchQueue.main.async {
                        switch result {
                        case .success:
                            showRecordingUI = true
                            startMicAnimation()
                        case .failure(let err):
                            errorMessage = err.localizedDescription
                            showingErrorAlert = true
                        }
                    }
                }
            }
        }
    }

    private func startMicAnimation() {
        Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { _ in
            micPulse.toggle()
        }
    }
}

#Preview {
    RecordingView(navigationPath: .constant([]))
        .environmentObject(RecordingSession())
}
