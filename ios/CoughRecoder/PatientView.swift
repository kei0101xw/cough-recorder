import SwiftUI

extension Notification.Name {
    static let patientDidRegister = Notification.Name("patientDidRegister")
}

struct Patient: Codable, Identifiable {
    let id: Int
    let researchID: String?
    let patientCode: String
    let biologicalSex: String
    let birthDate: String
    let createdAt: String
    let updatedAt: String

    enum CodingKeys: String, CodingKey {
        case id
        case researchID = "research_id"
        case patientCode = "patient_code"
        case biologicalSex = "biological_sex"
        case birthDate = "birth_date"
        case createdAt = "created_at"
        case updatedAt = "updated_at"
    }
}

private struct PatientListResponse: Codable {
    let results: [Patient]
}

enum PatientAPIError: Error, LocalizedError {
    case unauthorized
    case invalidResponse
    case httpStatus(Int)

    var errorDescription: String? {
        switch self {
        case .unauthorized:
            return "ログイン情報を確認してください。"
        case .invalidResponse:
            return "サーバーの応答が不正です。"
        case .httpStatus(let code):
            return "患者情報の取得に失敗しました (HTTP \(code))"
        }
    }
}

struct PatientView: View {
    @Binding var navigationPath: [String]
    @EnvironmentObject var auth: AuthManager
    @Environment(\.horizontalSizeClass) private var hSize
    @State private var patients: [Patient] = []
    @State private var isInitialLoading = false
    @State private var isRefreshing = false
    @State private var errorMessage: String?

    var body: some View {
        VStack(spacing: 0) {
            Text("患者情報一覧")
                .font(.system(size: AppUI.titleFontSize(hSize: hSize), weight: .regular))
                .padding(.vertical, 12)

            Divider()

            ZStack(alignment: .bottomTrailing) {
                Group {
                    if isInitialLoading && patients.isEmpty {
                        ProgressView("読み込み中...")
                            .font(.system(size: AppUI.sentenceFontSize(hSize: hSize)))
                            .frame(maxWidth: .infinity, maxHeight: .infinity)
                    } else if let errorMessage, patients.isEmpty {
                        VStack(spacing: 12) {
                            Text(errorMessage)
                                .font(.system(size: AppUI.sentenceFontSize(hSize: hSize)))
                                .foregroundColor(.red)
                                .multilineTextAlignment(.center)

                            Button("再読み込み") {
                                Task {
                                    await loadPatients(showInitialLoader: true)
                                }
                            }
                            .font(.system(size: AppUI.buttonFontSize(hSize: hSize)))
                        }
                        .padding()
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                    } else if patients.isEmpty {
                        VStack {
                            Text("データはありません。")
                                .font(.system(size: AppUI.sentenceFontSize(hSize: hSize)))
                                .foregroundColor(.secondary)
                        }
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                    } else {
                        VStack(spacing: 0) {
                            if let errorMessage {
                                Text(errorMessage)
                                    .font(.system(size: AppUI.sentenceFontSize(hSize: hSize)))
                                    .foregroundColor(.red)
                                    .multilineTextAlignment(.center)
                                    .padding(.horizontal, 16)
                                    .padding(.vertical, 8)
                            }

                            HStack(spacing: 12) {
                                Text("患者番号")
                                    .frame(maxWidth: .infinity, alignment: .leading)
                                Text("性別")
                                    .frame(width: 60, alignment: .center)
                                Text("誕生日")
                                    .frame(width: 110, alignment: .trailing)
                            }
                            .font(.system(size: AppUI.sentenceFontSize(hSize: hSize), weight: .semibold))
                            .padding(.horizontal, 16)
                            .padding(.vertical, 12)
                            .background(Color(.systemGray6))

                            Divider()

                            List(patients) { patient in
                                HStack(spacing: 12) {
                                    Text(patient.patientCode)
                                        .frame(maxWidth: .infinity, alignment: .leading)
                                    Text(patient.biologicalSex)
                                        .frame(width: 60, alignment: .center)
                                    Text(patient.birthDate)
                                        .frame(width: 110, alignment: .trailing)
                                }
                                .font(.system(size: AppUI.sentenceFontSize(hSize: hSize)))
                                .padding(.vertical, 6)
                                .listRowInsets(EdgeInsets(top: 0, leading: 16, bottom: 0, trailing: 16))
                            }
                            .listStyle(.plain)
                            .refreshable {
                                await loadPatients(showInitialLoader: false)
                            }
                        }
                    }
                }

                if isRefreshing {
                    ProgressView()
                        .padding(12)
                        .background(.ultraThinMaterial)
                        .clipShape(Capsule())
                        .padding(.top, 16)
                        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
                }

                Button {
                    navigationPath.append("PatientRegistration")
                } label: {
                    Image(systemName: "plus")
                        .font(.system(size: 24, weight: .bold))
                        .foregroundColor(.white)
                        .frame(width: 56, height: 56)
                        .background(Color.blue)
                        .clipShape(Circle())
                        .shadow(color: .black.opacity(0.18), radius: 8, x: 0, y: 4)
                }
                .padding(.trailing, 20)
                .padding(.bottom, 20)
                .accessibilityLabel("患者を追加")
            }

            Divider()

            Button {
                if !navigationPath.isEmpty {
                    navigationPath.removeLast()
                }
            } label: {
                Text("ホームへ戻る")
                    .frame(width: UIScreen.main.bounds.width / 2)
                    .frame(height: AppUI.buttonHeight(hSize: hSize))
                    .font(.system(size: AppUI.buttonFontSize(hSize: hSize)))
                    .padding(.horizontal)
                    .background(Color.gray.opacity(0.2))
                    .cornerRadius(10)
            }
            .padding()
        }
        .task {
            await loadPatients(showInitialLoader: true)
        }
        .onReceive(NotificationCenter.default.publisher(for: .patientDidRegister)) { _ in
            Task {
                await loadPatients(showInitialLoader: false)
            }
        }
        .navigationBarBackButtonHidden(true)
    }

    @MainActor
    private func loadPatients(showInitialLoader: Bool) async {
        if showInitialLoader && patients.isEmpty {
            isInitialLoading = true
        } else {
            isRefreshing = true
        }

        do {
            patients = try await fetchPatients()
            errorMessage = nil
        } catch {
            if patients.isEmpty {
                patients = []
            }
            errorMessage = (error as? LocalizedError)?.errorDescription ?? error.localizedDescription
        }

        isInitialLoading = false
        isRefreshing = false
    }

    private func fetchPatients() async throws -> [Patient] {
        let token: String
        do {
            token = try await auth.validAccessToken()
        } catch {
            throw PatientAPIError.unauthorized
        }

        var request = URLRequest(url: BackendAPI.Resources.patientsURL)
        request.httpMethod = "GET"
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        request.setValue("application/json", forHTTPHeaderField: "Accept")

        let (data, response) = try await URLSession.shared.data(for: request)
        guard let httpResponse = response as? HTTPURLResponse else {
            throw PatientAPIError.invalidResponse
        }

        guard (200..<300).contains(httpResponse.statusCode) else {
            throw PatientAPIError.httpStatus(httpResponse.statusCode)
        }

        let decoder = JSONDecoder()

        if let patients = try? decoder.decode([Patient].self, from: data) {
            return patients
        }

        if let wrapped = try? decoder.decode(PatientListResponse.self, from: data) {
            return wrapped.results
        }

        throw PatientAPIError.invalidResponse
    }
}

#Preview {
    PatientView(navigationPath: .constant([]))
        .environmentObject(AuthManager.shared)
}
