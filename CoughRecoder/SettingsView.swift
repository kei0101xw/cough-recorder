//
//  SettingsView.swift
//  CoughRecoder
//
//  Created by 原田佳祐 on 2025/08/05.
//

import SwiftUI

struct SettingsView: View {
    @Binding var navigationPath: [String]
    
    var body: some View {
        Text("設定画面です")
    }
}

#Preview {
    SettingsView(navigationPath: .constant([]))
}
