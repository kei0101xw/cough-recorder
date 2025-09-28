import SwiftUI

@main
struct CoughRecoderApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    @StateObject private var session = RecordingSession()
    @StateObject private var importer = ImportCoordinator.shared
    @StateObject private var auth = AuthManager.shared

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(session)
                .environmentObject(importer)
                .environmentObject(auth) 
                .preferredColorScheme(.light)
        }
    }
}
