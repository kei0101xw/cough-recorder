//
//  ConsentSheet.swift
//  CoughRecoder
//
//  Created by 原田佳祐 on 2025/09/09.
//

import SwiftUI

struct ConsentSheet: View {
    var onAgree: () -> Void

        var body: some View {
            ZStack {
                Color(.systemBackground).ignoresSafeArea()
                VStack(spacing: 24) {
                    Spacer()
                    VStack(alignment: .leading, spacing: 16) {
                        Text("ご利用にあたって")
                            .font(.title2.bold())
                        Text("このアプリで録音した咳の音声は、")
                            .font(.body)
                        VStack(alignment: .leading, spacing: 10) {
                            HStack(alignment: .top, spacing: 8) {
                                Text("•")
                                Text("端末に保存されます")
                            }
                            HStack(alignment: .top, spacing: 8) {
                                Text("•")
                                Text("研究目的のため、安全なサーバ（AWS）に送信されます")
                            }
                        }
                        .font(.body)
                        Divider()
                        Text("診断や治療に利用することはできません。")
                            .font(.body)
                        Text("同意の上で録音を開始してください。")
                            .font(.body)
                            .foregroundStyle(.secondary)
                    }
                    .frame(maxWidth: 640, alignment: .leading)
                    .padding(.horizontal, 24)
                    Button(action: onAgree) {
                        Text("同意して始める")
                            .font(.headline)
                            .frame(maxWidth: 640)
                            .frame(height: 56)
                            .background(Color.blue)
                            .foregroundColor(.white)
                            .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
                    }
                    .padding(.horizontal, 24)
                    Spacer()
                }
            }
        }
}
