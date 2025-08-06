//
//  InputFormView.swift
//  CoughRecoder
//
//  Created by 原田佳祐 on 2025/08/05.
//

import SwiftUI

struct InputFormView: View {
    @Binding var navigationPath: [String]
    
    @State var name: String = ""
    @State var hospital: String = ""
    @State var language: String = ""
    @State var disease: String = ""
    
    var body: some View {
        VStack {
            Text("今から記録する人の情報を入力")
                .font(.system(size: 50))
                .padding()
            
            Form {
                Section(header: Text("基本情報").font(.system(size: 30))) {
                    TextField("名前", text: $name)
                        .padding(.vertical, 10)
                        .frame(height: 70)
                        .font(.system(size: 30))
                    TextField("病院名", text: $hospital)
                        .padding(.vertical, 10)
                        .frame(height: 70)
                        .font(.system(size: 30))
                    TextField("言語", text: $language)
                        .padding(.vertical, 10)
                        .frame(height: 70)
                        .font(.system(size: 30))
                    TextField("病気", text: $disease)
                        .padding(.vertical, 10)
                        .frame(height: 70)
                        .font(.system(size: 30))
                }
            }
            
            HStack {
                Button(action: {
                    navigationPath.removeLast() // 前の画面に戻る
                }) {
                    Text("ホームへ戻る")
                        .frame(maxWidth: .infinity)
                        .frame(height: 60)
                        .font(.system(size: 40))
                        .padding()
                        .background(Color.gray.opacity(0.2))
                        .cornerRadius(10)
                }
                Button(action: {
                    navigationPath.append("PreRecording")
                }) {
                    Text("次へ")
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
    InputFormView(navigationPath: .constant([]))
}
