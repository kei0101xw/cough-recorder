import Foundation

enum SupabaseConfig {
    static var projectURL: URL {
        guard
            let s = Bundle.main.object(
                forInfoDictionaryKey: "SUPABASE_URL"
            ) as? String,
            let u = URL(string: s)
        else {
            fatalError("SUPABASE_URL が Info.plist にありません")
        }
        return u
    }
    static var anonKey: String {
        guard let k = Bundle.main.object(forInfoDictionaryKey: "SUPABASE_ANON_KEY") as? String else {
            fatalError("SUPABASE_ANON_KEY が Info.plist にありません")
        }
        return k
    }
}
