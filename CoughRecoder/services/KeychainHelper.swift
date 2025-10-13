import Foundation
import Security

enum KeychainHelper {
    private static let service = Bundle.main.bundleIdentifier.map { "\($0).auth" } ?? "app.auth"

    // -------------- Public --------------

    static func set(_ data: Data, for key: String) -> Bool {
        let q: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: service,
            kSecAttrAccount as String: key,
            kSecValueData as String: data,
            kSecAttrAccessible as String: kSecAttrAccessibleAfterFirstUnlock
        ]
        SecItemDelete(q as CFDictionary) // 同一キーを消してから
        let status = SecItemAdd(q as CFDictionary, nil)
        return status == errSecSuccess
    }

    static func get(_ key: String) -> Data? {
        // まず “service あり” で検索
        if let data = getWithService(key) { return data }

        // 互換: 過去に “service なし” で保存していた場合はそちらも探す
        if let legacy = getLegacyWithoutService(key) {
            // 見つかったら新形式で保存し直し（移行）
            _ = set(legacy, for: key)
            // レガシーを掃除
            deleteLegacyWithoutService(key)
            return legacy
        }
        return nil
    }

    static func delete(_ key: String) {
        let q: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: service,
            kSecAttrAccount as String: key
        ]
        SecItemDelete(q as CFDictionary)
        // 念のためレガシーも削除
        deleteLegacyWithoutService(key)
    }

    // -------------- Private --------------

    private static func getWithService(_ key: String) -> Data? {
        let q: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: service,
            kSecAttrAccount as String: key,
            kSecReturnData as String: true,
            kSecMatchLimit as String: kSecMatchLimitOne
        ]
        var item: CFTypeRef?
        let status = SecItemCopyMatching(q as CFDictionary, &item)
        guard status == errSecSuccess else { return nil }
        return item as? Data
    }

    // レガシー（service 無し）
    private static func getLegacyWithoutService(_ key: String) -> Data? {
        let q: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrAccount as String: key,
            kSecReturnData as String: true,
            kSecMatchLimit as String: kSecMatchLimitOne
        ]
        var item: CFTypeRef?
        let status = SecItemCopyMatching(q as CFDictionary, &item)
        guard status == errSecSuccess else { return nil }
        return item as? Data
    }

    private static func deleteLegacyWithoutService(_ key: String) {
        let q: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrAccount as String: key
        ]
        SecItemDelete(q as CFDictionary)
    }
}
