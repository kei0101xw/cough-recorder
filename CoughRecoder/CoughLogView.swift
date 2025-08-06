//
//  CoughLogView.swift
//  CoughRecoder
//
//  Created by 原田佳祐 on 2025/08/05.
//

import SwiftUI

struct CoughLogView: View {
    @Binding var navigationPath: [String]
    
    var body: some View {
        VStack {
            Spacer()
            Text("咳記録ログ画面")
                .font(.system(size: 40))
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
