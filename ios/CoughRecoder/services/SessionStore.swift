import Foundation

struct SessionRecord: Identifiable {
    let id = UUID()
    let payload: SessionPayload
    let audioURL: URL
    let jsonURL: URL
}

final class SessionStore: ObservableObject {
    @Published var records: [SessionRecord] = []

    func reload() {
        var loaded: [SessionRecord] = []

        let fm = FileManager.default
        guard let docs = fm.urls(for: .documentDirectory, in: .userDomainMask).first else { return }
        let sessionDir = docs.appendingPathComponent("Sessions", isDirectory: true)

        guard let items = try? fm.contentsOfDirectory(at: sessionDir, includingPropertiesForKeys: nil) else {
            DispatchQueue.main.async { self.records = [] }
            return
        }

        for url in items where url.pathExtension.lowercased() == "json" {
            do {
                let data = try Data(contentsOf: url)
                let payload = try JSONDecoder().decode(SessionPayload.self, from: data)
                let audioURL = sessionDir.appendingPathComponent(payload.audioFileName)

                if fm.fileExists(atPath: audioURL.path) {
                    loaded.append(SessionRecord(payload: payload, audioURL: audioURL, jsonURL: url))
                }
            } catch {
                continue
            }
        }

        loaded.sort { $0.payload.savedAt > $1.payload.savedAt }

        DispatchQueue.main.async {
            self.records = loaded
        }
    }
}
