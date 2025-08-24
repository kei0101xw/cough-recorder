//
//  GenderAgeForm.swift
//  CoughRecoder
//
//  Created by 原田佳祐 on 2025/08/23.
//

import SwiftUI

struct GenderAgeFormView: View {
    @Binding var navigationPath: [String]
    
    @State var gender: String = ""
    @State var age: Int? = nil
    
    private var ageBindingForStepper: Binding<Int> {
            Binding(
                get: { age ?? 0 },
                set: { age = $0 }
            )
        }

        // TextField 用：文字列 <-> Int? を相互変換する Binding<String>
        private var ageTextBinding: Binding<String> {
            Binding(
                get: { age.map(String.init) ?? "" }, // nil のときは空文字
                set: { input in
                    // 空文字なら nil、数字なら Int、範囲外や不正入力は無視
                    if input.isEmpty {
                        age = nil
                    } else if let v = Int(input), (0...120).contains(v) {
                        age = v
                    }
                    // それ以外（数字以外）は変更しない
                }
            )
        }
    
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
                .frame(height: 50)
                .font(.system(size: 24))
                
                Section(header:
                            Text("年齢を入力してください").font(.system(size: 30))) {
                    HStack {
                        TextField("年齢を入力してください", value: $age, format: .number)
                            .keyboardType(.numberPad)
                            .padding(.vertical, 10)
                            .frame(height: 70)
                            .font(.system(size: 24))
                        
                        Stepper("", value: ageBindingForStepper, in: 0...120, step: 1)
                            .labelsHidden()
                    }
                    
                }
            }
            
            Spacer()
            
            HStack {
                Button(action: {
                    navigationPath.removeLast() // 前の画面に戻る
                }) {
                    Text("戻る")
                        .frame(maxWidth: .infinity)
                        .frame(height: 60)
                        .font(.system(size: 32))
                        .padding(.horizontal)
                        .background(Color.gray.opacity(0.2))
                        .cornerRadius(10)
                }
                Button(action: {
                    navigationPath.append("CurrentSymptomsForm")
                }) {
                    Text("次へ")
                        .frame(maxWidth: .infinity)
                        .frame(height: 60)
                        .font(.system(size: 32))
                        .padding(.horizontal)
                        .background((gender.isEmpty || age == nil) ? Color.blue.opacity(0.4) : Color.blue)                        .foregroundColor(.white)
                        .foregroundColor(.white)
                        .cornerRadius(10)
                }
                .disabled(gender.isEmpty || age == nil)
            }
            .padding()
        }
        .navigationBarBackButtonHidden(true)
    }
}

#Preview {
    GenderAgeFormView(navigationPath: .constant([]))
}
