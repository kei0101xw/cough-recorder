//
//  PreRecordingView.swift
//  CoughRecoder
//
//  Created by 原田佳祐 on 2025/08/05.
//

import SwiftUI

struct PreRecordingView: View {
    @Environment(\.dismiss) var dismiss
    var body: some View {
        VStack {
            Text("録音を開始します")
                .font(.system(size: 60))
                .padding()
            
            Text("""
                ・静かな環境でお願いします。
                ・「咳をしてみてください」などの、周辺からの話しかけは録音時はしないでください。
                ・次のカウントダウン中に「次の画面になったら咳をしましょうね」などと指示してください。
                """)
            .font(.system(size: 40))
            .padding()
            .background(Color.gray.opacity(0.1))
            .cornerRadius(10)
            
            Spacer()
            
            HStack {
                Button(action: {
                    dismiss()
                }) {
                    Text("戻る")
                        .frame(maxWidth: .infinity)
                        .frame(height: 60)
                        .font(.system(size: 40))
                        .padding()
                        .background(Color.gray.opacity(0.2))
                        .cornerRadius(10)
                }
                
                NavigationLink(destination: RecordingView()) {
                    Text("録音開始")
                        .frame(maxWidth: .infinity)
                        .frame(height: 60)
                        .font(.system(size: 40))
                        .padding()
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(10)
                }
            }
            .padding()
        }
        .navigationBarBackButtonHidden(true)
    }
}

#Preview {
    PreRecordingView()
}
