//
//  CoughLogView.swift
//  CoughRecoder
//
//  Created by 原田佳祐 on 2025/08/05.
//

import SwiftUI

struct CoughLogView: View {
    @Binding var navigationPath: [String]
    
    struct CoughLog: Identifiable {
        let id = UUID()
        let date: String
        let name: String
        let hospital: String
        let language: String
        let disease: String
        let file: String
        let upload: String
    }
    
    let logs: [CoughLog] = [
        CoughLog(date: "2025/08/07 10:00", name: "田中太郎", hospital: "九大病院", language: "日本語", disease: "喘息", file: "cough1.wav", upload: "済"),
        CoughLog(date: "2025/08/07 11:20", name: "山田花子", hospital: "九大病院", language: "英語", disease: "コロナ", file: "cough2.wav", upload: "未"),
        CoughLog(date: "2025/08/07 11:20", name: "山田花子", hospital: "九大病院", language: "英語", disease: "コロナ", file: "cough2.wav", upload: "未"),
        CoughLog(date: "2025/08/07 11:20", name: "山田花子", hospital: "九大病院", language: "英語", disease: "コロナ", file: "cough2.wav", upload: "未"),
        CoughLog(date: "2025/08/07 11:20", name: "山田花子", hospital: "九大病院", language: "英語", disease: "コロナ", file: "cough2.wav", upload: "未"),
        CoughLog(date: "2025/08/07 11:20", name: "山田花子", hospital: "九大病院", language: "英語", disease: "コロナ", file: "cough2.wav", upload: "未"),
        CoughLog(date: "2025/08/07 11:20", name: "山田花子", hospital: "九大病院", language: "英語", disease: "コロナ", file: "cough2.wav", upload: "未"),
        CoughLog(date: "2025/08/07 11:20", name: "山田花子", hospital: "九大病院", language: "英語", disease: "コロナ", file: "cough2.wav", upload: "未"),
        CoughLog(date: "2025/08/07 11:20", name: "山田花子", hospital: "九大病院", language: "英語", disease: "コロナ", file: "cough2.wav", upload: "未"),
        CoughLog(date: "2025/08/07 11:20", name: "山田花子", hospital: "九大病院", language: "英語", disease: "コロナ", file: "cough2.wav", upload: "未"),
        CoughLog(date: "2025/08/07 11:20", name: "山田花子", hospital: "九大病院", language: "英語", disease: "コロナ", file: "cough2.wav", upload: "未"),
        CoughLog(date: "2025/08/07 11:20", name: "山田花子", hospital: "九大病院", language: "英語", disease: "コロナ", file: "cough2.wav", upload: "未"),
        CoughLog(date: "2025/08/07 11:20", name: "山田花子", hospital: "九大病院", language: "英語", disease: "コロナ", file: "cough2.wav", upload: "未"),
        CoughLog(date: "2025/08/07 11:20", name: "山田花子", hospital: "九大病院", language: "英語", disease: "コロナ", file: "cough2.wav", upload: "未"),
        CoughLog(date: "2025/08/07 11:20", name: "山田花子", hospital: "九大病院", language: "英語", disease: "コロナ", file: "cough2.wav", upload: "未"),
        CoughLog(date: "2025/08/07 11:20", name: "山田花子", hospital: "九大病院", language: "英語", disease: "コロナ", file: "cough2.wav", upload: "未"),
    ]
    
    var body: some View {
        VStack {
            Text("咳記録ログ画面")
                .font(.system(size: 40))
                .padding(.top)
            
            ScrollView([.horizontal, .vertical]) {
                Grid(alignment: .leading, horizontalSpacing: 60, verticalSpacing: 15) {
                    
                    // 見出し行
                    GridRow {
                        Text("日時").bold()
                        Text("名前").bold()
                        Text("病院").bold()
                        Text("言語").bold()
                        Text("病気").bold()
                        Text("ファイル").bold()
                        Text("アップ").bold()
                    }
                    .font(.system(size: 25))
                    .padding(.bottom, 5)
                    
                    Divider()
                        .gridCellUnsizedAxes(.horizontal)
                    
                    // データ行
                    ForEach(logs) { log in
                        GridRow {
                            Text(log.date)
                            Text(log.name)
                            Text(log.hospital)
                            Text(log.language)
                            Text(log.disease)
                            Text(log.file)
                            Text(log.upload)
                        }
                        
                        Divider()
                            .gridCellUnsizedAxes(.horizontal)
                    }
                    .font(.system(size: 25))
                }
                .padding()
            }
            
            Spacer()
            
            Button(action: {
                navigationPath.removeAll()
            }) {
                Text("ホームへ戻る")
                    .frame(width: UIScreen.main.bounds.width / 2)
                    .frame(height: 60)
                    .font(.system(size: 40))
                    .padding()
                    .background(Color.gray.opacity(0.2))
                    .cornerRadius(10)
            }
            .padding()
        }
        .navigationBarBackButtonHidden(true)
    }
}

#Preview {
    CoughLogView(navigationPath: .constant([]))
}
