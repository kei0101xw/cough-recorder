import Foundation

@MainActor
final class ImportCoordinator: ObservableObject {
    static let shared = ImportCoordinator()
    @Published var lastImportedURL: URL?

    private init() {}

    func handleIncomingFile(url: URL) {
        let needStop = url.startAccessingSecurityScopedResource()
        defer { if needStop { url.stopAccessingSecurityScopedResource() } }

        do {
            let docs = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
            let sessionsDir = docs.appendingPathComponent("Sessions", isDirectory: true)
            try FileManager.default.createDirectory(at: sessionsDir, withIntermediateDirectories: true)

            let ext = url.pathExtension.isEmpty ? "m4a" : url.pathExtension
            let base = "imported_\(Int(Date().timeIntervalSince1970)).\(ext)"
            let dst = sessionsDir.appendingPathComponent(base)

            try? FileManager.default.removeItem(at: dst)
            try FileManager.default.copyItem(at: url, to: dst)

            self.lastImportedURL = dst
        } catch {
            print("Import error:", error)
            self.lastImportedURL = nil
        }
    }
}
