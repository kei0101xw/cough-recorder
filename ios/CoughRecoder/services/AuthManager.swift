import Foundation

struct BackendSession: Codable {
    let accessToken: String
    let refreshToken: String
    let expiresAt: Date

    // 30秒前倒しで期限切れ判定（余裕を持ってリフレッシュ）
    var isExpired: Bool { Date() >= expiresAt.addingTimeInterval(-30) }
}

private enum AuthError: Error {
    case invalidRefresh
    case invalidCredentials
    case invalidResponse
}

@MainActor
final class AuthManager: ObservableObject {
    static let shared = AuthManager()

    private static var instanceCount = 0

    @Published private(set) var session: BackendSession? {
        didSet {
            isAuthenticated = (session != nil)
        }
    }
    @Published private(set) var isAuthenticated: Bool = false
    @Published var lastError: String?

    private let keychainKey = "cr.auth.session.v1"

    private init() {
        Self.instanceCount += 1
        print("AuthManager.init — instanceCount=\(Self.instanceCount) ptr=\(Unmanaged.passUnretained(self).toOpaque())")

        if let data = KeychainHelper.get(keychainKey),
           let s = try? JSONDecoder().decode(BackendSession.self, from: data) {
            self.session = s
            print("AuthManager: restored session (expiresAt=\(s.expiresAt))")
        } else {
            self.session = nil
            print("AuthManager: no session in keychain")
        }
    }

    // MARK: - Public API

    func clearError() { lastError = nil }

    /// ユーザーID/パスワードでログインしてセッションを保存
    func signIn(username: String, password: String) {
        Task {
            self.lastError = nil
            do {
                let s = try await obtainToken(username: username, password: password)
                save(session: s)
            } catch AuthError.invalidCredentials {
                self.lastError = "ユーザーIDまたはパスワードが違います"
                self.session = nil
                KeychainHelper.delete(keychainKey)
            } catch {
                self.lastError = "接続に失敗しました。時間をおいて再度お試しください。"
            }
        }
    }

    /// 明示ログアウト
    func signOut() {
        let currentRefreshToken = session?.refreshToken
        session = nil
        lastError = nil
        KeychainHelper.delete(keychainKey)

        if let refreshToken = currentRefreshToken {
            Task {
                try? await blacklist(refreshToken: refreshToken)
            }
        }
    }

    /// アプリ復帰時などに呼ぶ。期限切れが近ければリフレッシュ。
    /// ネットワーク一時失敗ではセッションを消さない（400/401のみ完全ログアウト）
    func refreshIfNeeded() {
        guard var s = session else {
            print("refreshIfNeeded: no session")
            return
        }
        let expired = s.isExpired
        print("refreshIfNeeded: expired=\(expired) now=\(Date()) expiresAt=\(s.expiresAt)")
        guard expired else { return }

        Task {
            do {
                s = try await refreshToken(s.refreshToken)
                print("refreshIfNeeded: refresh OK -> new expiresAt=\(s.expiresAt)")
                save(session: s)
            } catch AuthError.invalidRefresh {
                print("refreshIfNeeded: 400/401 -> signOut()")
                signOut()
            } catch {
                print("refreshIfNeeded: transient error \(error) -> keep session")
                // 一時的失敗はセッションを保持して次回に再試行
                self.lastError = "接続に失敗しました。時間をおいて再度お試しください。"
            }
        }
    }

    /// API 呼び出しで Bearer を付けたい時に使う
    func withAccessToken(_ block: (String) -> Void) {
        guard let s = session, !s.isExpired else { return }
        block(s.accessToken)
    }

    /// 必要ならアクセストークンを直接取得（任意利用）
    func currentAccessToken() -> String? {
        guard let s = session, !s.isExpired else { return nil }
        return s.accessToken
    }

    /// 期限切れなら更新して、有効なアクセストークンを返す
    func validAccessToken() async throws -> String {
        guard var s = session else {
            throw AuthError.invalidRefresh
        }

        if s.isExpired {
            s = try await refreshToken(s.refreshToken)
            save(session: s)
        }

        return s.accessToken
    }

    // MARK: - Private

    private func save(session: BackendSession) {
        self.session = session
        self.lastError = nil
        if let data = try? JSONEncoder().encode(session) {
            _ = KeychainHelper.set(data, for: keychainKey)
        }
    }

    // MARK: - Django SimpleJWT REST

    /// POST { username, password } -> /api/token/
    private func obtainToken(username: String, password: String) async throws -> BackendSession {
        struct Req: Codable { let username: String; let password: String }
        struct Resp: Codable { let access: String; let refresh: String }

        var req = URLRequest(url: BackendAPI.Auth.tokenURL)
        req.httpMethod = "POST"
        req.addValue("application/json", forHTTPHeaderField: "Content-Type")
        req.httpBody = try JSONEncoder().encode(Req(username: username, password: password))

        let (data, resp) = try await URLSession.shared.data(for: req)
        guard let http = resp as? HTTPURLResponse else {
            throw AuthError.invalidResponse
        }
        if http.statusCode == 401 {
            throw AuthError.invalidCredentials
        }
        guard (200..<300).contains(http.statusCode) else {
            throw URLError(.badServerResponse)
        }

        let r = try JSONDecoder().decode(Resp.self, from: data)
        let expiry = Self.expiryDate(fromJWT: r.access) ?? Date().addingTimeInterval(60 * 5)
        return BackendSession(accessToken: r.access,
                               refreshToken: r.refresh,
                               expiresAt: expiry)
    }

    /// POST { refresh } -> /api/token/refresh/
    /// 400/401 はトークン無効とみなして AuthError.invalidRefresh を投げる
    private func refreshToken(_ refreshToken: String) async throws -> BackendSession {
        struct Req: Codable { let refresh: String }
        struct Resp: Codable {
            let access: String
            let refresh: String?
        }

        var req = URLRequest(url: BackendAPI.Auth.refreshURL)
        req.httpMethod = "POST"
        req.addValue("application/json", forHTTPHeaderField: "Content-Type")
        req.httpBody = try JSONEncoder().encode(Req(refresh: refreshToken))

        let (data, resp) = try await URLSession.shared.data(for: req)
        guard let http = resp as? HTTPURLResponse else {
            print("refresh: no HTTPURLResponse")
            throw URLError(.badServerResponse)
        }
        print("refresh: HTTP \(http.statusCode)")

        if !(200..<300).contains(http.statusCode) {
            if http.statusCode == 400 || http.statusCode == 401 {
                throw AuthError.invalidRefresh
            } else {
                // 一時的な障害等は上位でリトライ運用に回す
                throw URLError(.cannotConnectToHost)
            }
        }

        let r = try JSONDecoder().decode(Resp.self, from: data)
        let expiry = Self.expiryDate(fromJWT: r.access) ?? Date().addingTimeInterval(60 * 5)
        return BackendSession(accessToken: r.access,
                               refreshToken: r.refresh ?? refreshToken,
                               expiresAt: expiry)
    }

    /// POST { refresh } -> /api/token/blacklist/
    private func blacklist(refreshToken: String) async throws {
        struct Req: Codable { let refresh: String }

        var req = URLRequest(url: BackendAPI.Auth.blacklistURL)
        req.httpMethod = "POST"
        req.addValue("application/json", forHTTPHeaderField: "Content-Type")
        req.httpBody = try JSONEncoder().encode(Req(refresh: refreshToken))

        _ = try await URLSession.shared.data(for: req)
    }

    private static func expiryDate(fromJWT jwt: String) -> Date? {
        let segments = jwt.split(separator: ".")
        guard segments.count >= 2 else { return nil }
        guard let payload = decodeBase64URL(String(segments[1])) else { return nil }
        guard let object = try? JSONSerialization.jsonObject(with: payload) as? [String: Any],
              let exp = object["exp"] as? TimeInterval
        else { return nil }

        return Date(timeIntervalSince1970: exp)
    }

    private static func decodeBase64URL(_ value: String) -> Data? {
        var base64 = value
            .replacingOccurrences(of: "-", with: "+")
            .replacingOccurrences(of: "_", with: "/")

        let pad = base64.count % 4
        if pad > 0 {
            base64.append(String(repeating: "=", count: 4 - pad))
        }
        return Data(base64Encoded: base64)
    }
}
