//
//  CoughRecoderApp.swift
//  CoughRecoder
//
//  Created by 原田佳祐 on 2025/08/05.
//

import SwiftUI

@main
struct CoughRecoderApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate  // ← 追加
    @StateObject private var session = RecordingSession()
    @StateObject private var importer = ImportCoordinator.shared     // ← 追加

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(session)
                .environmentObject(importer) // ← 追加
                .preferredColorScheme(.light)
        }
    }
}
