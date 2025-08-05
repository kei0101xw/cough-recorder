//
//  CountdownView.swift
//  CoughRecoder
//
//  Created by 原田佳祐 on 2025/08/05.
//

import SwiftUI

struct RecordingView: View {
    @Environment(\.dismiss) var dismiss
    
    @State private var countdown: Int = 3
    @State private var showRecordingUI = false
    let audioRecorder = AudioRecorder() // 録音処理クラスを使う
    
    var body: some View {
        VStack {
            if showRecordingUI {
                Spacer()
                Text("録音中")
                    .font(.system(size: 60))
                    .padding()
                Spacer()
                HStack {
                    Button(action: {
                        dismiss()
                    }) {
                        Text("やり直し")
                            .frame(maxWidth: .infinity)
                            .frame(height: 60)
                            .font(.system(size: 40))
                            .padding()
                            .background(Color.gray.opacity(0.2))
                            .cornerRadius(10)
                    }
                    Button("録音完了") {
                        audioRecorder.stopRecording()
                    }
                    .frame(maxWidth: .infinity)
                    .frame(height: 60)
                    .font(.system(size: 40))
                    .padding()
                    .background(Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(10)
                }
                
                
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
                    .overlay(
                        Circle()
                            .stroke(Color.blue, lineWidth: 5)
                    )
                Spacer()
            }
        }
        .onAppear {
            startCountdown()
        }
        .navigationBarBackButtonHidden(true)
    }
    
    
    func startCountdown() {
        Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { timer in
            if countdown > 1 {
                countdown -= 1
            } else {
                timer.invalidate()
                showRecordingUI = true // カウント終了後に自動画面変化
            }
        }
    }
}

#Preview {
    RecordingView()
}
