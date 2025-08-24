//
//  InputFormView.swift
//  CoughRecoder
//
//  Created by 原田佳祐 on 2025/08/05.
//

import SwiftUI

struct PatientInfoFormView: View {
    @Binding var navigationPath: [String]
    
    @State var id: String = ""
    @State var facility: String = ""
    
    var body: some View {
        VStack {
            Text("記録をする人の情報を入力してください")
                .font(.system(size: 35))
            
            Form {
                Section(header: Text("参加者ID").font(.system(size: 30))) {
                    TextField("参加者IDを入力してください", text: $id)
                        .padding(.vertical, 10)
                        .frame(height: 70)
                        .font(.system(size: 30))
                }
                Section(header:
                            Text("施設").font(.system(size: 30))) {
                    TextField("施設を選んでください", text: $facility)
                        .padding(.vertical, 10)
                        .frame(height: 70)
                        .font(.system(size: 30))
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
                        .background((id.isEmpty || facility.isEmpty) ? Color.blue.opacity(0.4) : Color.blue)                        .foregroundColor(.white)
                        .cornerRadius(10)
                }
                .disabled(id.isEmpty || facility.isEmpty)
            }
            .padding()
        }
        .navigationBarBackButtonHidden(true)
    }
}


#Preview {
    PatientInfoFormView(navigationPath: .constant([]))
}
