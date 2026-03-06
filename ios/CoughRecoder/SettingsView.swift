import SwiftUI

struct SettingsView: View {
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject var auth: AuthManager

    var body: some View {
        NavigationStack {
            Form {
                if auth.isAuthenticated {
                    Section(header: Text("アカウント")) {
                        Button(role: .destructive) {
                            auth.signOut()
                            dismiss()
                        } label: {
                            HStack {
                                Image(systemName: "rectangle.portrait.and.arrow.right")
                                Text("ログアウト")
                            }
                        }
                    }
                }

                Section(header: Text("アプリ情報")) {
                    HStack {
                        Text("バージョン")
                        Spacer()
                        Text(Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "-")
                            .foregroundStyle(.secondary)
                    }
                }
            }
            .navigationTitle("設定")
        }
    }
}

#Preview {
    SettingsView()
        .environmentObject(AuthManager.shared)
}
