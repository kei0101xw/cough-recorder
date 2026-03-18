import SwiftUI

private struct PatientCreateRequest: Codable {
    let researchID: String?
    let patientCode: String
    let biologicalSex: String
    let birthDate: String

    enum CodingKeys: String, CodingKey {
        case researchID = "research_id"
        case patientCode = "patient_code"
        case biologicalSex = "biological_sex"
        case birthDate = "birth_date"
    }
}

enum PatientRegistrationError: Error, LocalizedError {
    case unauthorized
    case invalidResponse
    case httpStatus(Int)
    case validation(String)

    var errorDescription: String? {
        switch self {
        case .unauthorized:
            return "ログイン情報を確認してください。"
        case .invalidResponse:
            return "サーバーの応答が不正です。"
        case .validation(let message):
            return message
        case .httpStatus(let code):
            return "患者登録に失敗しました (HTTP \(code))"
        }
    }
}

struct PatientRegistrationView: View {
    @Binding var navigationPath: [String]
    @EnvironmentObject var auth: AuthManager
    @Environment(\.horizontalSizeClass) private var hSize

    @State private var researchID = ""
    @State private var patientCode = ""
    @State private var biologicalSex = "male"
    @State private var birthDate = Date()
    @State private var isSubmitting = false
    @State private var errorMessage: String?

    private let sexOptions: [(label: String, value: String)] = [
        ("男性", "man"),
        ("女性", "woman"),
        ("その他", "other")
    ]

    var body: some View {
        VStack(spacing: 0) {
            Text("患者登録")
                .font(.system(size: AppUI.titleFontSize(hSize: hSize), weight: .regular))
                .padding(.vertical, 12)

            Form {
                Section(header: Text("研究ID").font(.system(size: AppUI.sectionHeaderFontSize(hSize: hSize)))) {
                    TextField("研究IDを入力してください（任意）", text: $researchID)
                        .padding(.vertical, 10)
                        .frame(height: AppUI.fieldHeight(hSize: hSize))
                        .font(.system(size: AppUI.fieldFontSize(hSize: hSize)))
                        .textInputAutocapitalization(.none)
                        .autocorrectionDisabled()
                }

                Section(header: Text("患者番号").font(.system(size: AppUI.sectionHeaderFontSize(hSize: hSize)))) {
                    TextField("患者番号を入力してください", text: $patientCode)
                        .padding(.vertical, 10)
                        .frame(height: AppUI.fieldHeight(hSize: hSize))
                        .font(.system(size: AppUI.fieldFontSize(hSize: hSize)))
                        .textInputAutocapitalization(.none)
                        .autocorrectionDisabled()
                }

                Section(header: Text("性別").font(.system(size: AppUI.sectionHeaderFontSize(hSize: hSize)))) {
                    Picker("", selection: $biologicalSex) {
                        ForEach(sexOptions, id: \.value) { option in
                            Text(option.label).tag(option.value)
                        }
                    }
                    .labelsHidden()
                    .pickerStyle(.inline)
                    .font(.system(size: AppUI.fieldFontSize(hSize: hSize)))
                    .frame(height: AppUI.pickFormHeight(hSize: hSize), alignment: .leading)
                    .padding(.vertical, 5)
                }

                Section(header: Text("誕生日").font(.system(size: AppUI.sectionHeaderFontSize(hSize: hSize)))) {
                    DatePicker(
                        "誕生日を選択してください",
                        selection: $birthDate,
                        in: ...Date(),
                        displayedComponents: .date
                    )
                    .datePickerStyle(.wheel)
                    .font(.system(size: AppUI.fieldFontSize(hSize: hSize)))
                    .labelsHidden()
                }
            }

            if let errorMessage {
                Text(errorMessage)
                    .font(.system(size: AppUI.sentenceFontSize(hSize: hSize)))
                    .foregroundColor(.red)
                    .padding(.horizontal, 16)
                    .padding(.top, 8)
            }

            Spacer()

            HStack {
                Button {
                    if !navigationPath.isEmpty {
                        navigationPath.removeLast()
                    }
                } label: {
                    Text("戻る")
                        .frame(maxWidth: .infinity)
                        .frame(height: AppUI.buttonHeight(hSize: hSize))
                        .font(.system(size: AppUI.buttonFontSize(hSize: hSize)))
                        .padding(.horizontal)
                        .background(Color.gray.opacity(0.2))
                        .cornerRadius(10)
                }
                .disabled(isSubmitting)

                Button {
                    Task {
                        await registerPatient()
                    }
                } label: {
                    Text(isSubmitting ? "登録中..." : "登録する")
                        .frame(maxWidth: .infinity)
                        .frame(height: AppUI.buttonHeight(hSize: hSize))
                        .font(.system(size: AppUI.buttonFontSize(hSize: hSize), weight: .semibold))
                        .padding(.horizontal)
                        .background(isFormValid && !isSubmitting ? Color.blue : Color.blue.opacity(0.4))
                        .foregroundColor(.white)
                        .cornerRadius(10)
                }
                .disabled(!isFormValid || isSubmitting)
            }
            .padding()
        }
        .navigationBarBackButtonHidden(true)
    }

    private var isFormValid: Bool {
        !patientCode.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }

    @MainActor
    private func registerPatient() async {
        isSubmitting = true
        errorMessage = nil

        do {
            try await createPatient()
            NotificationCenter.default.post(name: .patientDidRegister, object: nil)
            if !navigationPath.isEmpty {
                navigationPath.removeLast()
            }
        } catch {
            errorMessage = (error as? LocalizedError)?.errorDescription ?? error.localizedDescription
        }

        isSubmitting = false
    }

    private func createPatient() async throws {
        let token: String
        do {
            token = try await auth.validAccessToken()
        } catch {
            throw PatientRegistrationError.unauthorized
        }

        let trimmedResearchID = researchID.trimmingCharacters(in: .whitespacesAndNewlines)
        let requestBody = PatientCreateRequest(
            researchID: trimmedResearchID.isEmpty ? nil : trimmedResearchID,
            patientCode: patientCode.trimmingCharacters(in: .whitespacesAndNewlines),
            biologicalSex: biologicalSex,
            birthDate: Self.birthDateFormatter.string(from: birthDate)
        )

        var request = URLRequest(url: BackendAPI.Resources.patientsURL)
        request.httpMethod = "POST"
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("application/json", forHTTPHeaderField: "Accept")
        request.httpBody = try JSONEncoder().encode(requestBody)

        let (data, response) = try await URLSession.shared.data(for: request)
        guard let httpResponse = response as? HTTPURLResponse else {
            throw PatientRegistrationError.invalidResponse
        }

        if httpResponse.statusCode == 400 {
            if let message = extractValidationMessage(from: data) {
                throw PatientRegistrationError.validation(message)
            }
        }

        guard (200..<300).contains(httpResponse.statusCode) else {
            throw PatientRegistrationError.httpStatus(httpResponse.statusCode)
        }
    }

    private func extractValidationMessage(from data: Data) -> String? {
        if let object = try? JSONSerialization.jsonObject(with: data) as? [String: Any] {
            let messages = object.flatMap { key, value -> [String] in
                if let values = value as? [String] {
                    return values.map { "\(key): \($0)" }
                }
                if let value = value as? String {
                    return ["\(key): \(value)"]
                }
                return []
            }

            if !messages.isEmpty {
                return messages.joined(separator: "\n")
            }
        }

        if let text = String(data: data, encoding: .utf8), !text.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            return text
        }

        return nil
    }

    private static let birthDateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.calendar = Calendar(identifier: .gregorian)
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.dateFormat = "yyyy-MM-dd"
        return formatter
    }()
}

#Preview {
    PatientRegistrationView(navigationPath: .constant(["Patient", "PatientRegistration"]))
        .environmentObject(AuthManager.shared)
}
