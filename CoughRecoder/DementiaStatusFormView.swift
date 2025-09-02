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

    private let options: [String] = ["なし",  "診断されてはいないが、中・低度の認知症の症状が見られる", "診断された認知症あり"]

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
                    navigationPath.removeLast()
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
                .disabled(session.dementiaStatus.isEmpty) // 未選択でも保存OKにするなら削除
            }
            .padding()
        }
        .navigationBarBackButtonHidden(true)
        .alert(alertTitle, isPresented: $showingAlert) {
            Button("OK") {
                if alertTitle == "保存しました" {
                    session.sessionReset()
                    navigationPath.removeAll()
                }
            }
        } message: {
            Text(alertMessage)
        }
    }

    private func handleSave() {
        guard session.recordingURL != nil else {
            alertTitle = "未録音です"
            alertMessage = "録音データが見つかりません。録音を完了してから保存してください。"
            showingAlert = true
            return
        }

        do {
            let dir = try AppFileStore.shared.saveSession(session)
            alertTitle = "保存しました"
            alertMessage = "アプリ内に保存しました：\n\(dir.path)\n（Filesアプリ > このiPhone内 > CoughRecoder > Sessions）"
            showingAlert = true
        } catch {
            alertTitle = "保存に失敗しました"
            alertMessage = error.localizedDescription
            showingAlert = true
        }
    }
}

#Preview {
    DementiaStatusFormView(navigationPath: .constant([]))
        .environmentObject(RecordingSession())
}
