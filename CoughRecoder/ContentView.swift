//
//  ContentView.swift
//  CoughRecoder
//
//  Created by 原田佳祐 on 2025/08/05.
//

import SwiftUI

struct ContentView: View {
    var body: some View {
        NavigationStack {
            VStack {
                Text("咳記録アプリ")
                    .font(.system(size: 60))
                    .padding()
                NavigationLink(destination: InputFormView()) {
                    Text("スタート")
                        .padding()
                        .font(.system(size: 40))
                        .frame(width: 300)
                        .foregroundColor(.white)
                        .background(Color.blue)
                        .cornerRadius(10)
                }
                .padding()
                
                HStack {
                    NavigationLink(destination: SettingsView()) {
                        Text("設定")
                    }
                    NavigationLink(destination: CoughLogView()) {
                        Text("咳記録ログ")
                    }
                }
            }
        }
    }
}

#Preview {
    ContentView()
}
