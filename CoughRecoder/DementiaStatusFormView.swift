//  DementiaStatusFormView.swift
//  CoughRecoder
//
//  Created by 原田佳祐 on 2025/09/03.
//

import SwiftUI

struct DementiaStatusFormView: View {
    @Binding var navigationPath: [String]
    @EnvironmentObject var session: RecordingSession

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
                .font(.system(size: 30, weight: .regular))
                .padding(.vertical, 12)

            Form {
                Picker("認知症の有無", selection: $session.dementiaStatus) {
                    ForEach(options, id: \.self) { option in
                        Text(option).tag(option)
                    }
                }
                .pickerStyle(.inline)
                .padding(.vertical, 10)
                .frame(height: 50)
                .font(.system(size: 24))
            }

            Spacer()

            HStack {
                Button {
                    if !navigationPath.isEmpty { navigationPath.removeLast() }
                } label: {
                    Text("戻る")
                        .frame(maxWidth: .infinity)
                        .frame(height: 60)
                        .font(.system(size: 32))
                        .padding(.horizontal)
                        .background(Color.gray.opacity(0.2))
                        .cornerRadius(10)
                }

                Button(action: handleSave) {
                    Text("送信して保存する")
                        .frame(maxWidth: .infinity)
                        .frame(height: 60)
                        .font(.system(size: 32, weight: .semibold))
                        .padding(.horizontal)
                        .background(session.dementiaStatus.isEmpty ? Color.blue.opacity(0.4) : Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(10)
                }
                .disabled(session.dementiaStatus.isEmpty)
            }
            .padding()
        }
        .navigationBarBackButtonHidden(true)
        .alert(alertTitle, isPresented: $showingAlert) {
            Button("OK") {
                if shouldResetOnDismiss {
                    session.sessionReset()
                    navigationPath.removeAll()
                }
            }
        } message: {
            Text(alertMessage)
        }
    }

    @MainActor
    private func handleSave() {
        // 録音必須チェック
        guard session.recordingURL != nil else {
            alertTitle = "未録音です"
            alertMessage = "録音データが見つかりません。録音を完了してから保存してください。"
            shouldResetOnDismiss = false
            showingAlert = true
            return
        }

        // ローカル保存
        do {
            _ = try AppFileStore.shared.saveSession(session)
        } catch {
            alertTitle = "保存に失敗しました"
            alertMessage = error.localizedDescription
            shouldResetOnDismiss = false
            showingAlert = true
            return
        }

        // ネット送信
        isUploading = true
        shouldResetOnDismiss = false

        Task {
            defer { Task { @MainActor in isUploading = false } }
            do {
                let msg = try await APIClient.upload(session: session)
                await MainActor.run {
                    alertTitle = "保存に成功しました！"
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
