//
//  CoughRecoderApp.swift
//  CoughRecoder
//
//  Created by 原田佳祐 on 2025/08/05.
//

import SwiftUI

@main
struct CoughRecoderApp: App {
    @StateObject private var session = RecordingSession()
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(session)
        }
    }
}
