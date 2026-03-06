import SwiftUI

struct RecordingView: View {
    @Binding var navigationPath: [String]
    @EnvironmentObject var session: RecordingSession
    @Environment(\.horizontalSizeClass) private var hSize

    @StateObject private var audioRecorder = AudioRecorder()

    @State private var countdown: Int = 3
    @State private var showRecordingUI = false
    @State private var errorMessage: String?
    @State private var showingErrorAlert = false
    @State private var finishing = false
    @State private var elapsedSeconds: Int = 0
    @State private var elapsedTimer: Timer? = nil

    // 録音開始から完了できるまでの最低秒数
    private let minSecondsBeforeFinish = 5
    
    private var canFinish: Bool { elapsedSeconds >= minSecondsBeforeFinish && !finishing }
    private var remainingToFinish: Int { max(0, minSecondsBeforeFinish - elapsedSeconds) }

    var body: some View {
        VStack {
            if showRecordingUI {
                Spacer()
                Text("録音中")
                    .font(.system(size: Layout.redordingFontSize(hSize)))
                    .foregroundColor(.white)
                    .padding(32)
                    .background(Color.red)
                    .cornerRadius(100)
                
                Spacer()

                Text(formattedElapsed(elapsedSeconds))
                    .font(.system(size: AppUI.titleFontSize(hSize: hSize)))

                Spacer()
                
                WaveformView(levels: audioRecorder.levels)
                    .frame(height: 180)
                    .padding(.horizontal, 24)
                    .animation(.easeOut(duration: 0.15), value: audioRecorder.levels)
                Spacer()
                Divider()

                HStack {
                    Button {
                        audioRecorder.discardAndDeleteFile()
                        session.recordingURL = nil
                        navigationPath.removeLast()
                    } label: {
                        Text("やり直し")
                            .frame(maxWidth: .infinity)
                            .frame(height: AppUI.buttonHeight(hSize: hSize))
                            .font(.system(size: AppUI.buttonFontSize(hSize: hSize)))
                            .padding(.horizontal)
                            .background(Color.gray.opacity(0.2))
                            .cornerRadius(10)
                    }

                    Button {
                        guard canFinish else { return }
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
                        Text(
                            finishing
                            ? "処理中…"
//                            : (canFinish ? "録音完了" : "録音完了（あと\(remainingToFinish)秒）")
                            : "録音完了"
                        )
                        .frame(maxWidth: .infinity)
                        .frame(height: AppUI.buttonHeight(hSize: hSize))
                        .font(.system(size: AppUI.buttonFontSize(hSize: hSize)))
                        .padding(.horizontal)
                        .background(canFinish ? Color.blue : Color.gray)
                        .foregroundColor(.white)
                        .cornerRadius(10)
                    }
                    .disabled(!canFinish)
                }
                .padding()

            } else {
                Spacer()
                Text("カウントダウンが終了すると自動で録音が開始されます")
                    .font(.system(size: AppUI.titleFontSize(hSize: hSize)))
                    .padding(.horizontal, Layout.horizontalPadding(hSize))
                Spacer()
                Text("\(countdown)")
                    .font(.system(size: Layout.countDownFontSize(hSize)))
                    .bold()
                    .frame(width: Layout.imageHeight(hSize), height: Layout.imageHeight(hSize))
                    .background(Color.white)
                    .clipShape(Circle())
                    .overlay(Circle().stroke(Color.blue, lineWidth: 5))
                Spacer()
            }
        }
        .onAppear { startCountdown() }
        .onDisappear { stopElapsedTimer() }
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
                            elapsedSeconds = 0
                            showRecordingUI = true
                            startElapsedTimer()
                        case .failure(let err):
                            errorMessage = err.localizedDescription
                            showingErrorAlert = true
                        }
                    }
                }
            }
        }
    }
    
    private func startElapsedTimer() {
        stopElapsedTimer()
        elapsedTimer = Timer
            .scheduledTimer(withTimeInterval: 1.0, repeats: true) { _ in
                elapsedSeconds += 1
            }
    }
    
    private func stopElapsedTimer() {
        elapsedTimer?.invalidate()
        elapsedTimer = nil
    }
    
    private func formattedElapsed(_ seconds: Int) -> String {
        let m = seconds / 60
        let s = seconds % 60
        return String(format: "%02d:%02d", m, s)
    }
}

extension RecordingView {
    enum Layout {
        static func imageHeight(_ hSize: UserInterfaceSizeClass?) -> CGFloat {
            (hSize == .compact) ? 200 : 400
        }
        static func horizontalPadding(_ hSize: UserInterfaceSizeClass?) -> CGFloat {
            (hSize == .compact) ? 50 : 0
        }
        static func countDownFontSize(_ hSize: UserInterfaceSizeClass?) -> CGFloat {
            (hSize == .compact) ? 100 : 200
        }
        static func redordingFontSize(_ hSize: UserInterfaceSizeClass?) -> CGFloat {
            (hSize == .compact) ? 30 : 60
        }
    }
}

#Preview {
    RecordingView(navigationPath: .constant([]))
        .environmentObject(RecordingSession())
}
