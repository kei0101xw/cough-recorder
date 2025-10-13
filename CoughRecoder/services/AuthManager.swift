import Foundation
import Combine

struct SupabaseSession: Codable {
    let accessToken: String
    let refreshToken: String
    let expiresAt: Date

    // 30秒前倒しで期限切れ判定（余裕を持ってリフレッシュ）
    var isExpired: Bool { Date() >= expiresAt.addingTimeInterval(-30) }
}

private enum AuthError: Error {
    case invalidRefresh
}

@MainActor
final class AuthManager: ObservableObject {
    static let shared = AuthManager()

    private static var instanceCount = 0

    @Published private(set) var session: SupabaseSession? {
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
           let s = try? JSONDecoder().decode(SupabaseSession.self, from: data) {
            self.session = s
            print("AuthManager: restored session (expiresAt=\(s.expiresAt))")
        } else {
            self.session = nil
            print("AuthManager: no session in keychain")
        }
    }

    // MARK: - Public API

    func clearError() { lastError = nil }

    /// メール/パスワードでログインしてセッションを保存
    func signIn(email: String, password: String) {
        Task {
            self.lastError = nil
            do {
                let s = try await supabasePasswordGrant(email: email, password: password)
                save(session: s)
            } catch {
                // 認証失敗時はエラーメッセージを出してセッションはクリア
                self.lastError = "ユーザーIDまたはパスワードが違います"
                self.session = nil
                KeychainHelper.delete(keychainKey)
            }
        }
    }

    /// 明示ログアウト
    func signOut() {
        session = nil
        lastError = nil
        KeychainHelper.delete(keychainKey)
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
                s = try await supabaseRefresh(refreshToken: s.refreshToken)
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

    // MARK: - Private

    private func save(session: SupabaseSession) {
        self.session = session
        self.lastError = nil
        if let data = try? JSONEncoder().encode(session) {
            _ = KeychainHelper.set(data, for: keychainKey)
        }
    }

    // MARK: - Supabase REST

    /// POST { email, password } -> /auth/v1/token?grant_type=password
    private func supabasePasswordGrant(email: String, password: String) async throws -> SupabaseSession {
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

    /// POST { refresh_token } -> /auth/v1/token?grant_type=refresh_token
    /// 400/401 はトークン無効とみなして AuthError.invalidRefresh を投げる
    private func supabaseRefresh(refreshToken: String) async throws -> SupabaseSession {
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
        let expiry = Date().addingTimeInterval(TimeInterval(r.expires_in))
        return SupabaseSession(accessToken: r.access_token,
                               refreshToken: r.refresh_token,
                               expiresAt: expiry)
    }
}
