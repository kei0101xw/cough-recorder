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
