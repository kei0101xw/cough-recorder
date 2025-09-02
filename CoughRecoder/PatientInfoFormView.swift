import SwiftUI

struct PatientInfoFormView: View {
    @Binding var navigationPath: [String]
    @EnvironmentObject var session: RecordingSession

    private let facilityOptions: [String] = [
        "さんすまいる唐原",
        "藤の実会・七樹苑",
        "笑楽日",
        "いとう内科クリニック",
        "今泉ビハーラ",
        "フレンドピーチ千早",
        "マナハウス",
        "その他"
    ]

    var body: some View {
        VStack(spacing: 0) {
            Text("記録をする人の情報を入力してください")
                .font(.system(size: 30, weight: .regular))
                .padding(.vertical, 12)

            Form {
                Section(header: Text("参加者ID").font(.system(size: 30))) {
                    TextField("参加者IDを入力してください", text: $session.id)
                        .padding(.vertical, 10)
                        .frame(height: 70)
                        .font(.system(size: 25))
                        .textInputAutocapitalization(.none)
                        .autocorrectionDisabled()
                }

                Section {
                    Picker("施設を選択してください", selection: $session.facility) {
                        Text("(未選択)").tag("")
                        ForEach(facilityOptions, id: \.self) { facility in
                            Text(facility).tag(facility)
                        }
                    }
                    .pickerStyle(.navigationLink)
                    .frame(height: 70)
                    .font(.system(size: 25))
                } header: {
                    Text("施設")
                        .font(.system(size: 30))
                        .padding(.vertical, 6)
                }
            }

            Spacer()

            HStack {
                Button {
                    if !navigationPath.isEmpty { navigationPath.removeLast() }
                } label: {
                    Text("戻る")
                        .frame(maxWidth: .infinity)
                        .frame(height: 60)
                        .font(.system(size: 32))
                        .padding(.horizontal)
                        .background(Color.gray.opacity(0.2))
                        .cornerRadius(10)
                }

                Button {
                    navigationPath.append("PreRecording")
                } label: {
                    Text("次へ")
                        .frame(maxWidth: .infinity)
                        .frame(height: 60)
                        .font(.system(size: 32, weight: .semibold))
                        .padding(.horizontal)
                        .background(isNextEnabled ? Color.blue : Color.blue.opacity(0.4))
                        .foregroundColor(.white)
                        .cornerRadius(10)
                }
                .disabled(!isNextEnabled)
            }
            .padding()
        }
        .navigationBarBackButtonHidden(true)
    }

    private var isNextEnabled: Bool {
        !session.id.isEmpty && !session.facility.isEmpty
    }
}

#Preview {
    PatientInfoFormView(navigationPath: .constant([]))
        .environmentObject(RecordingSession())
}
