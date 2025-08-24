//
//  MedicalConditionView.swift
//  CoughRecoder
//
//  Created by 原田佳祐 on 2025/08/24.
//

import SwiftUI

struct MedicalConditionFormView: View {
    @Binding var navigationPath: [String]
    
    @State var gender: String = ""
    @State var age: Int = 0
    
    var body: some View {
        VStack {
            Text("あなたの情報を入力してください")
                .font(.system(size: 35))
            
            Form {
                Picker("性別を選択してください", selection: $gender) {
                    Text("男性").tag("男性")
                    Text("女性").tag("女性")
                    Text("その他").tag("その他")
                }
                .pickerStyle(.inline)
                .padding(.vertical, 10)
                .frame(height: 70)
                .font(.system(size: 30))
                
                Section(header:
                            Text("年齢を入力してください").font(.system(size: 30))) {
                    HStack {
                        TextField("年齢を入力してください", value: $age, format: .number)
                            .keyboardType(.numberPad)
                            .padding(.vertical, 10)
                            .frame(height: 70)
                            .font(.system(size: 30))
                        
                        Stepper("", value: $age, in: 0...120, step: 1)
                            .labelsHidden()
                    }
                    
                }
            }
            
            Spacer()
            
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
    MedicalConditionFormView(navigationPath: .constant([]))
}
