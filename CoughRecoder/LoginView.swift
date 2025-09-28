import SwiftUI

struct LoginView: View {
    @Binding var navigationPath: [String]
    @EnvironmentObject var auth: AuthManager
    @State private var email = ""
    @State private var password = ""
    @FocusState private var focusField: Field?
    enum Field { case email, pass }

    var body: some View {
        VStack(spacing: 0) {
            Text("ログインしてください")
                .font(.system(size: 30, weight: .regular))
                .padding(.vertical, 12)

            Form {
                Section(header: Text("メールアドレス").font(.system(size: 30))) {
                    TextField("メールアドレス", text: $email)
                        .keyboardType(.emailAddress)
                        .textInputAutocapitalization(.none)
                        .autocorrectionDisabled()
                        .textContentType(.username)
                        .padding(.vertical, 10)
                        .frame(height: 70)
                        .font(.system(size: 25))
                }
                Section(header: Text("パスワード").font(.system(size: 30))) {
                    SecureField("パスワード", text: $password)
                        .textContentType(.password)
                        .padding(.vertical, 10)
                        .frame(height: 70)
                        .font(.system(size: 25))
                }
            }

            if let err = auth.lastError {
                Text(err).foregroundColor(.red).padding(.top, 8)
            }

            Spacer()

            HStack {
                Button {
                    navigationPath.removeAll()
                } label: {
                    Text("ホームへ戻る")
                        .frame(maxWidth: .infinity)
                        .frame(height: 60)
                        .font(.system(size: 32))
                        .background(Color.gray.opacity(0.2))
                        .cornerRadius(10)
                }

                Button {
                    auth.signIn(email: email.trimmingCharacters(in: .whitespaces),
                                password: password)
                } label: {
                    Text("ログイン")
                        .frame(maxWidth: .infinity)
                        .frame(height: 60)
                        .font(.system(size: 32))
                        .foregroundColor(.white)
                        .background((!email.isEmpty && !password.isEmpty) ? Color.blue : Color.blue.opacity(0.4))
                        .cornerRadius(10)
                }
                .disabled(email.isEmpty || password.isEmpty)
            }
            .padding()
        }
        .onAppear {
            auth.clearError()
            focusField = .email
        }
        .navigationBarBackButtonHidden(true)
    }
}

#Preview {
    LoginView(navigationPath: .constant([]))
        .environmentObject(AuthManager.shared)
}
