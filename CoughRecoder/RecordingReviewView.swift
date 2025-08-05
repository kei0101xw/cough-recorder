//
//  RecordingReviewView.swift
//  CoughRecoder
//
//  Created by 原田佳祐 on 2025/08/05.
//

import SwiftUI

struct RecordingReviewView: View {
    @Environment(\.dismiss) var dismiss
    var body: some View {
        VStack {
            Text("録音の確認")
                .font(.system(size: 60))
                .padding()
            
            Spacer()
            
            Image(systemName: "play.circle.fill")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 300, height: 300)
                            .foregroundColor(.startButton)
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
                Button(action: {
                    dismiss()
                }) {
                    Text("やり直す")
                        .frame(maxWidth: .infinity)
                        .frame(height: 60)
                        .font(.system(size: 40))
                        .padding()
                        .background(Color.gray.opacity(0.2))
                        .cornerRadius(10)
                }
                
                NavigationLink(destination: RecordingView()) {
                    Text("録音完了")
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
    RecordingReviewView()
}
