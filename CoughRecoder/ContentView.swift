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
                Spacer()
                Text("咳記録アプリ")
                    .font(.system(size: 60))
                
                Spacer()
                
                HStack {
                    NavigationLink(destination: InputFormView()) {
                        VStack {
                            Spacer()
                            Text("録音する")
                                .font(.system(size: 50))
                                .bold()
                            Spacer()
                            Image(systemName: "mic.fill")
                                .resizable()
                                .scaledToFit()
                                .frame(height: 100)
                            Spacer()
                        }
                        .frame(width: 500, height: 400)
                        .padding()
                        .background(Color.startButton.opacity(0.1))
                        .foregroundColor(.startButton)
                        .overlay(
                            RoundedRectangle(cornerRadius: 10)
                                .stroke(Color.startButton, lineWidth: 10)
                        )
                        .cornerRadius(10)
                    }
                    .padding()
                    VStack {
                        NavigationLink(destination: CoughLogView()) {
                            VStack {
                                Text("咳記録ログ")
                                    .font(.system(size: 50))
                                    .bold()
                                Image(systemName: "list.bullet.rectangle.fill")
                                    .resizable()
                                    .scaledToFit()
                                    .frame(height: 60)
                            }
                            .frame(width: 500, height: 180)
                            .padding()
                            .background(Color.logButton.opacity(0.1))
                            .foregroundColor(.logButton)
                            .overlay(
                                RoundedRectangle(cornerRadius: 10)
                                    .stroke(Color.logButton, lineWidth: 10)
                            )
                            .cornerRadius(10)
                        }
                        NavigationLink(destination: SettingsView()) {
                            VStack {
                                Text("設定")
                                    .font(.system(size: 50))
                                    .bold()
                                Image(systemName: "gearshape.fill")
                                    .resizable()
                                    .scaledToFit()
                                    .frame(height: 60)
                            }
                            .frame(width: 500, height: 180)
                            .padding()
                            .background(Color.settingButton.opacity(0.1))
                            .foregroundColor(.blue)
                            .overlay(
                                RoundedRectangle(cornerRadius: 10)
                                    .stroke(Color.blue, lineWidth: 10)
                            )
                            .cornerRadius(10)
                        }
                    }
                }
                Spacer()
            }
        }
    }
}

#Preview {
    ContentView()
}
