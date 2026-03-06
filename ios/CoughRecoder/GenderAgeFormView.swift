import SwiftUI

struct GenderAgeFormView: View {
    @Binding var navigationPath: [String]
    
    @EnvironmentObject var session: RecordingSession
    @Environment(\.horizontalSizeClass) private var hSize
    
    private var ageBindingForStepper: Binding<Int> {
            Binding(
                get: { session.age ?? 0 },
                set: { session.age = $0 }
            )
        }
    
    var body: some View {
        VStack {
            Text("あなたの情報を入力してください")
                .font(.system(size: AppUI.titleFontSize(hSize: hSize), weight: .regular))
            
            
            Form {
                Picker("性別を選択してください", selection: $session.gender) {
                    Text("男性").tag("male")
                    Text("女性").tag("female")
                    Text("その他").tag("その他")
                }
                .pickerStyle(.inline)
                .padding(.vertical, 10)
                .font(.system(size: AppUI.fieldFontSize(hSize: hSize)))
                .frame(height: AppUI.pickFormHeight(hSize: hSize), alignment: .leading)
                
                Section(header:
                            Text("年齢を入力してください")
                                .font(.system(size: AppUI.sectionHeaderFontSize(hSize: hSize)))
                                .keyboardType(.numberPad)) {
                    HStack {
                        TextField("年齢を入力してください", value: $session.age, format: .number)
                            .keyboardType(.numberPad)
                            .padding(.vertical, 10)
                            .frame(height: AppUI.fieldHeight(hSize: hSize))
                            .font(.system(size: AppUI.fieldFontSize(hSize: hSize)))
                        
                        Stepper("", value: ageBindingForStepper, in: 0...120, step: 1)
                            .labelsHidden()
                    }
                    
                }
            }
            
            Spacer()
            
            HStack {
                Button(action: {
                    navigationPath.removeLast()
                }) {
                    Text("戻る")
                        .frame(maxWidth: .infinity)
                        .frame(height: AppUI.buttonHeight(hSize: hSize))
                        .font(.system(size: AppUI.buttonFontSize(hSize: hSize)))
                        .padding(.horizontal)
                        .background(Color.gray.opacity(0.2))
                        .cornerRadius(10)
                }
                Button(action: {
                    navigationPath.append("CurrentSymptomsForm")
                }) {
                    Text("次へ")
                        .frame(maxWidth: .infinity)
                        .frame(height: AppUI.buttonHeight(hSize: hSize))
                        .font(.system(size: AppUI.buttonFontSize(hSize: hSize), weight: .semibold))
                        .padding(.horizontal)
                        .background((session.gender.isEmpty || session.age == nil) ? Color.blue.opacity(0.4) : Color.blue)                        .foregroundColor(.white)
                        .foregroundColor(.white)
                        .cornerRadius(10)
                }
                .disabled(session.gender.isEmpty || session.age == nil)
            }
            .padding()
        }
        .navigationBarBackButtonHidden(true)
    }
}

#Preview {
    GenderAgeFormView(navigationPath: .constant([]))
        .environmentObject(RecordingSession())
}
