//
//  AppDelegate.swift
//  CoughRecoder
//
//  Created by 原田佳祐 on 2025/09/09.
//

import UIKit

final class AppDelegate: NSObject, UIApplicationDelegate {
    func application(_ app: UIApplication,
                     open url: URL,
                     options: [UIApplication.OpenURLOptionsKey : Any] = [:]) -> Bool {
        Task { @MainActor in
            ImportCoordinator.shared.handleIncomingFile(url: url)
        }
        return true
    }
}
