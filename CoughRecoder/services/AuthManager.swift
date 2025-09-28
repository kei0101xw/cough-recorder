import Foundation
import Combine

struct SupabaseSession: Codable {
    let accessToken: String
    let refreshToken: String
    let expiresAt: Date

    var isExpired: Bool { Date() >= expiresAt.addingTimeInterval(-30) }
}

final class AuthManager: ObservableObject {
    static let shared = AuthManager()

    @Published private(set) var isAuthenticated = false
    @Published var lastError: String?
    
    @MainActor
    func clearError() { lastError = nil }

    private let keychainKey = "cr.auth.session.v1"
    private var currentSession: SupabaseSession? {
        didSet { isAuthenticated = (currentSession != nil) }
    }

    private init() {
        // セッション復元
        if let data = KeychainHelper.get(keychainKey),
           let s = try? JSONDecoder().decode(SupabaseSession.self, from: data) {
            self.currentSession = s
        } else {
            self.currentSession = nil
        }
    }

    // MARK: - Public API

    func signIn(email: String, password: String) {
        Task { @MainActor in
            self.lastError = nil
            do {
                let s = try await supabasePasswordGrant(email: email, password: password)
                save(session: s)
            } catch {
                self.lastError = "ユーザーIDまたはパスワードが違います"
                self.currentSession = nil
                KeychainHelper.delete(keychainKey)
            }
        }
    }

    func signOut() {
        currentSession = nil
        lastError = nil
        KeychainHelper.delete(keychainKey)
    }

    /// アプリ復帰時などに呼ぶ。期限切れが近ければリフレッシュ。
    func refreshIfNeeded() {
        Task { @MainActor in
            guard var s = currentSession else { return }
            if !s.isExpired { return }
            do {
                s = try await supabaseRefresh(refreshToken: s.refreshToken)
                save(session: s)
            } catch {
                // リフレッシュ失敗 → セッション破棄
                self.currentSession = nil
                KeychainHelper.delete(keychainKey)
            }
        }
    }

    /// API呼び出しで Bearer を付けたい時に使う
    func withAccessToken(_ block: (String) -> Void) {
        guard let s = currentSession, !s.isExpired else { return }
        block(s.accessToken)
    }

    // MARK: - Private

    @MainActor
    private func save(session: SupabaseSession) {
        self.currentSession = session
        self.lastError = nil  
        if let data = try? JSONEncoder().encode(session) {
            _ = KeychainHelper.set(data, for: keychainKey)
        }
    }

    // --- Supabase REST ---

    private func supabasePasswordGrant(email: String, password: String) async throws -> SupabaseSession {
        // POST { email, password } to /auth/v1/token?grant_type=password
        var url = SupabaseConfig.projectURL
        url.append(path: "/auth/v1/token")
        var comp = URLComponents(url: url, resolvingAgainstBaseURL: false)!
        comp.queryItems = [URLQueryItem(name: "grant_type", value: "password")]
        let endpoint = comp.url!

        struct Req: Codable { let email: String; let password: String }
        struct Resp: Codable {
            let access_token: String
            let refresh_token: String
            let expires_in: Int // 秒
            // ほかにも user など来るが今回は未使用
        }

        var req = URLRequest(url: endpoint)
        req.httpMethod = "POST"
        req.addValue("application/json", forHTTPHeaderField: "Content-Type")
        req.addValue(SupabaseConfig.anonKey, forHTTPHeaderField: "apikey")
        req.httpBody = try JSONEncoder().encode(Req(email: email, password: password))

        let (data, resp) = try await URLSession.shared.data(for: req)
        guard let http = resp as? HTTPURLResponse, (200..<300).contains(http.statusCode)
        else { throw URLError(.userAuthenticationRequired) }

        let r = try JSONDecoder().decode(Resp.self, from: data)
        let expiry = Date().addingTimeInterval(TimeInterval(r.expires_in))
        return SupabaseSession(accessToken: r.access_token,
                               refreshToken: r.refresh_token,
                               expiresAt: expiry)
    }

    private func supabaseRefresh(refreshToken: String) async throws -> SupabaseSession {
        // POST { refresh_token } to /auth/v1/token?grant_type=refresh_token
        var url = SupabaseConfig.projectURL
        url.append(path: "/auth/v1/token")
        var comp = URLComponents(url: url, resolvingAgainstBaseURL: false)!
        comp.queryItems = [URLQueryItem(name: "grant_type", value: "refresh_token")]
        let endpoint = comp.url!

        struct Req: Codable { let refresh_token: String }
        struct Resp: Codable {
            let access_token: String
            let refresh_token: String
            let expires_in: Int
        }

        var req = URLRequest(url: endpoint)
        req.httpMethod = "POST"
        req.addValue("application/json", forHTTPHeaderField: "Content-Type")
        req.addValue(SupabaseConfig.anonKey, forHTTPHeaderField: "apikey")
        req.httpBody = try JSONEncoder().encode(Req(refresh_token: refreshToken))

        let (data, resp) = try await URLSession.shared.data(for: req)
        guard let http = resp as? HTTPURLResponse, (200..<300).contains(http.statusCode)
        else { throw URLError(.userAuthenticationRequired) }

        let r = try JSONDecoder().decode(Resp.self, from: data)
        let expiry = Date().addingTimeInterval(TimeInterval(r.expires_in))
        return SupabaseSession(accessToken: r.access_token,
                               refreshToken: r.refresh_token,
                               expiresAt: expiry)
    }
}
