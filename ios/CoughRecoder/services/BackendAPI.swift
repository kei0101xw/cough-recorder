import Foundation

enum BackendAPI {
    private static let baseURLKey = "BACKEND_BASE_URL"

    static var baseURL: URL {
        guard
            let raw = Bundle.main.object(forInfoDictionaryKey: baseURLKey) as? String,
            !raw.isEmpty,
            let url = URL(string: raw)
        else {
            fatalError("\(baseURLKey) is missing or invalid in Info.plist")
        }
        return url
    }

    static func url(path: String) -> URL {
        let normalizedPath: String
        if path.hasPrefix("/") {
            normalizedPath = String(path.dropFirst())
        } else {
            normalizedPath = path
        }
        return baseURL.appendingPathComponent(normalizedPath)
    }

    enum Auth {
        static let tokenPath = "/api/token/"
        static let refreshPath = "/api/token/refresh/"
        static let blacklistPath = "/api/token/blacklist/"

        static var tokenURL: URL { BackendAPI.url(path: tokenPath) }
        static var refreshURL: URL { BackendAPI.url(path: refreshPath) }
        static var blacklistURL: URL { BackendAPI.url(path: blacklistPath) }
    }

    enum Resources {
        static let patientsPath = "/api/patients/"
        static let recordingsPath = "/api/recordings/"
        static let facilitiesPath = "/api/facilities/"
        static let conditionsPath = "/api/conditions/"
        static let symptomsPath = "/api/symptoms/"
        static let dementiasPath = "/api/dementias/"

        static var patientsURL: URL { BackendAPI.url(path: patientsPath) }
        static var recordingsURL: URL { BackendAPI.url(path: recordingsPath) }
        static var facilitiesURL: URL { BackendAPI.url(path: facilitiesPath) }
        static var conditionsURL: URL { BackendAPI.url(path: conditionsPath) }
        static var symptomsURL: URL { BackendAPI.url(path: symptomsPath) }
        static var dementiasURL: URL { BackendAPI.url(path: dementiasPath) }
    }
}
