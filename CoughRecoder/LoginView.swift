import SwiftUI

struct LoginView: View {
    @Binding var navigationPath: [String]
    @EnvironmentObject var auth: AuthManager
    @Environment(\.horizontalSizeClass) private var hSize

    @State private var email = ""
    @State private var password = ""
    @FocusState private var focusField: Field?
    enum Field { case email, pass }

    var body: some View {
        VStack(spacing: 0) {
            Text("ログインしてください")
                .font(.system(size: AppUI.titleFontSize(hSize: hSize), weight: .regular))
                .padding(.vertical, 12)

            Form {
                Section(header:
                    Text("メールアドレス")
                        .font(.system(size: AppUI.sectionHeaderFontSize(hSize: hSize)))
                ) {
                    TextField("メールアドレス", text: $email)
                        .keyboardType(.emailAddress)
                        .textInputAutocapitalization(.none)
                        .autocorrectionDisabled()
                        .textContentType(.username)
                        .frame(height: AppUI.fieldHeight(hSize: hSize))
                        .font(.system(size: AppUI.fieldFontSize(hSize: hSize)))
                }

                Section(header:
                    Text("パスワード")
                        .font(.system(size: AppUI.sectionHeaderFontSize(hSize: hSize)))
                ) {
                    SecureField("パスワード", text: $password)
                        .textContentType(.password)
                        .frame(height: AppUI.fieldHeight(hSize: hSize))
                        .font(.system(size: AppUI.fieldFontSize(hSize: hSize)))
                }
            }

            if let err = auth.lastError {
                Text(err)
                    .foregroundColor(.red)
                    .padding(.top, 8)
            }

            Spacer()

            HStack {
                Button {
                    navigationPath.removeAll()
                } label: {
                    Text("ホームへ戻る")
                        .frame(maxWidth: .infinity)
                        .frame(height: AppUI.buttonHeight(hSize: hSize))
                        .font(.system(size: AppUI.buttonFontSize(hSize: hSize)))
                        .background(Color.gray.opacity(0.2))
                        .cornerRadius(10)
                }

                Button {
                    auth.signIn(
                        email: email.trimmingCharacters(in: .whitespaces),
                        password: password
                    )
                } label: {
                    Text("ログイン")
                        .frame(maxWidth: .infinity)
                        .frame(height: AppUI.buttonHeight(hSize: hSize))
                        .font(.system(size: AppUI.buttonFontSize(hSize: hSize)))
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
