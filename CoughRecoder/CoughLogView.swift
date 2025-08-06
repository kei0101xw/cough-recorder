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
        Text("咳記録ログ画面です")
    }
}

#Preview {
    CoughLogView(navigationPath: .constant([]))
}
