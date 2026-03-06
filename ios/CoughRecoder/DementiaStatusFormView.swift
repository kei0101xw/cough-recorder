import SwiftUI

struct DementiaStatusFormView: View {
    @Binding var navigationPath: [String]
    @EnvironmentObject var session: RecordingSession
    @Environment(\.horizontalSizeClass) private var hSize

    @State private var showingAlert = false
    @State private var alertTitle = ""
    @State private var alertMessage = ""
    @State private var shouldResetOnDismiss = false
    @State private var isUploading = false

    private let options: [String] = [
        "なし",
        "診断されてはいないが、中・低度の認知症の症状が見られる",
        "診断された認知症あり"
    ]

    var body: some View {
        VStack(spacing: 0) {
            Text("認知症の有無を選択してください")
                .font(.system(size: AppUI.titleFontSize(hSize: hSize), weight: .regular))
                .padding(.vertical, 12)

            Form {
                Picker("認知症の有無", selection: $session.dementiaStatus) {
                    ForEach(options, id: \.self) { option in
                        Text(option).tag(option)
                    }
                }
                .pickerStyle(.inline)
                .padding(.vertical, 10)
                .font(.system(size: AppUI.fieldFontSize(hSize: hSize)))
                .frame(height: AppUI.pickFormHeight(hSize: hSize), alignment: .leading)
            }

            Spacer()

            HStack {
                Button {
                    if !navigationPath.isEmpty { navigationPath.removeLast() }
                } label: {
                    Text("戻る")
                        .frame(maxWidth: .infinity)
                        .frame(height: AppUI.buttonHeight(hSize: hSize))
                        .font(.system(size: AppUI.buttonFontSize(hSize: hSize)))
                        .padding(.horizontal)
                        .background(Color.gray.opacity(0.2))
                        .cornerRadius(10)
                }
                .disabled(isUploading) // 送信中は戻るも無効化（任意）

                Button(action: handleSave) {
                    Group {
                        if isUploading {
                            HStack(spacing: 8) {
                                ProgressView()
                                Text("送信中…")
                            }
                        } else {
                            Text("送信して保存する")
                        }
                    }
                    .frame(maxWidth: .infinity)
                    .frame(height: AppUI.buttonHeight(hSize: hSize))
                    .font(.system(size: AppUI.buttonFontSize(hSize: hSize), weight: .semibold))
                    .padding(.horizontal)
                    .background((session.dementiaStatus.isEmpty || isUploading) ? Color.blue.opacity(0.4) : Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(10)
                }
                .disabled(session.dementiaStatus.isEmpty || isUploading)
                .allowsHitTesting(!isUploading)
            }
            .padding()
        }
        .navigationBarBackButtonHidden(true)
        .alert(alertTitle, isPresented: $showingAlert) {
            Button("OK") {
                if shouldResetOnDismiss {
                    navigationPath.append("ThankYou")
                }
            }
        } message: {
            Text(alertMessage)
        }
    }

    @MainActor
    private func handleSave() {
        if isUploading { return }

        guard session.recordingURL != nil else {
            alertTitle = "未録音です"
            alertMessage = "録音データが見つかりません。録音を完了してから保存してください。"
            shouldResetOnDismiss = false
            showingAlert = true
            return
        }

        do {
            _ = try AppFileStore.shared.saveSession(session)
        } catch {
            alertTitle = "保存に失敗しました"
            alertMessage = error.localizedDescription
            shouldResetOnDismiss = false
            showingAlert = true
            return
        }

        isUploading = true
        shouldResetOnDismiss = false

        Task {
            defer {
                Task { @MainActor in
                    isUploading = false
                }
            }
            do {
                let msg = try await APIClient.upload(session: session)
                await MainActor.run {
                    alertTitle = "保存・送信に成功しました！"
                    alertMessage = msg
                    session.startCooldown(seconds: 20)
                    shouldResetOnDismiss = true
                    showingAlert = true
                }
            } catch {
                await MainActor.run {
                    alertTitle = "保存に失敗しました"
                    alertMessage = error.localizedDescription
                    shouldResetOnDismiss = false
                    showingAlert = true
                }
            }
        }
    }
}

#Preview {
    DementiaStatusFormView(navigationPath: .constant([]))
        .environmentObject(RecordingSession())
}
