//
//  CurrentSymptomsFormView.swift
//  CoughRecoder
//
//  Created by 原田佳祐 on 2025/08/24.
//

import SwiftUI

struct CurrentSymptomsFormView: View {
    @Binding var navigationPath: [String]
    
    // 複数選択は Set で管理します（List(selection:) の必須要件）
    @State private var selectedSymptoms: Set<String> = []
    
    // 選択肢（必要に応じて増減してください）
    private let symptomOptions: [String] = [
        "なし",
        "体の痛み",
        "咳（乾いた咳）",
        "咳（湿った、粘液を伴う）",
        "発熱・寒気・発汗",
        "頭痛",
        "味覚・嗅覚障害",
        "鼻水",
        "息切れ",
        "喉の痛み"
    ]
    
    var body: some View {
        VStack(spacing: 0) {
            Text("現在の症状を選択してください")
                .font(.system(size: 35, weight: .regular))
                .padding(.vertical, 12)
            
            // List(selection:) を使うと複数選択が可能（編集モードを有効化）
            List(selection: $selectedSymptoms) {
                Section {
                    ForEach(symptomOptions, id: \.self) { symptom in
                        Text(symptom)
                            .font(.system(size: 24))
                            .padding(.vertical, 6)
                    }
                } header: {
                    Text("該当するものを全て選択してください")
                        .font(.system(size: 24))
                        .padding(EdgeInsets(top: 10, leading: 0, bottom: 10, trailing: 0))
                }
            }
            // 編集モードを常時アクティブにして複数選択を有効化
            .environment(\.editMode, .constant(.active))
            
            Spacer()
            
            HStack {
                Button(action: {
                    navigationPath.removeLast()
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
                    navigationPath.append("MedicalConditionForm")
                }) {
                    Text("次へ（選択中: \(selectedSymptoms.count) 件）")
                        .frame(maxWidth: .infinity)
                        .frame(height: 60)
                        .font(.system(size: 32, weight: .semibold))
                        .padding(.horizontal)
                        .background(selectedSymptoms.isEmpty ? Color.blue.opacity(0.4) : Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(10)
                }
                // 何も選択していない場合は無効化
                .disabled(selectedSymptoms.isEmpty)
            }
            .padding()
        }
        .navigationBarBackButtonHidden(true)
    }
}

#Preview {
    CurrentSymptomsFormView(navigationPath: .constant([]))
}
