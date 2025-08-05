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
                    .font(.largeTitle)
                    .padding()
                NavigationLink(destination: InputFormView()) {
                    Text("スタート")
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
