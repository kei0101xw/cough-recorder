import SwiftUI

@main
struct CoughRecoderApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    @StateObject private var session = RecordingSession()
    @StateObject private var importer = ImportCoordinator.shared

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(session)
                .environmentObject(importer)
                .preferredColorScheme(.light)
        }
    }
}
