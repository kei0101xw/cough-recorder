//
//  MedicalConditionView.swift
//  CoughRecoder
//
//  Created by 原田佳祐 on 2025/08/24.
//

import SwiftUI

struct MedicalConditionFormView: View {
    @Binding var navigationPath: [String]
    
    @State private var selectedCondition: Set<String> = []
    
    private let conditionOptions: [String] = [
        "なし（健康）",
        "インフルエンザA型",
        "インフルエンザB型",
        "新型コロナ",
        "風邪",
        "肺炎（間質性肺炎、誤嚥性肺炎、マイコプラズマ肺炎を含む）",
        "気管支炎",
        "結核",
        "COPD・肺気腫",
        "喘息"
    ]
    
    var body: some View {
        VStack(spacing: 0) {
            Text("現在、以下の病状はありますか？")
                .font(.system(size: 35, weight: .regular))
                .padding(.vertical, 12)
            
            List(selection: $selectedCondition) {
                Section {
                    ForEach(conditionOptions, id: \.self) { symptom in
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
                    navigationPath.removeAll()
                }) {
                    Text("送信する（選択中: \(selectedCondition.count) 件）")
                        .frame(maxWidth: .infinity)
                        .frame(height: 60)
                        .font(.system(size: 32, weight: .semibold))
                        .padding(.horizontal)
                        .background(selectedCondition.isEmpty ? Color.blue.opacity(0.4) : Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(10)
                }
                .disabled(selectedCondition.isEmpty)
            }
            .padding()
        }
        .navigationBarBackButtonHidden(true)
    }
}

#Preview {
    MedicalConditionFormView(navigationPath: .constant([]))
}
