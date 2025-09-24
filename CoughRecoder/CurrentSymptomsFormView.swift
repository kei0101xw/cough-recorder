import SwiftUI

struct CurrentSymptomsFormView: View {
    @Binding var navigationPath: [String]
    
    @EnvironmentObject var session: RecordingSession
    
    private let symptomOptions: [String] = [
        "なし",
        "体の痛み",
        "咳（乾いた咳）",
        "咳（湿った、粘液を伴う）",
        "発熱・寒気・発汗",
        "頭痛",
        "味覚・嗅覚障害",
        "鼻水",
        "息切れ",
        "喉の痛み"
    ]
    
    var body: some View {
        VStack(spacing: 0) {
            Text("現在の症状を選択してください")
                .font(.system(size: 35, weight: .regular))
                .padding(.vertical, 12)
            
            List(selection: $session.symptoms) {
                Section {
                    ForEach(symptomOptions, id: \.self) { symptom in
                        Text(symptom)
                            .font(.system(size: 24))
                            .padding(.vertical, 6)
                    }
                } header: {
                    Text("該当するものを全て選択してください")
                        .font(.system(size: 24))
                        .padding(EdgeInsets(top: 10, leading: 0, bottom: 10, trailing: 0))
                }
            }
            .environment(\.editMode, .constant(.active))
            
            Spacer()
            
            HStack {
                Button(action: {
                    navigationPath.removeLast()
                }) {
                    Text("戻る")
                        .frame(maxWidth: .infinity)
                        .frame(height: 60)
                        .font(.system(size: 32))
                        .padding(.horizontal)
                        .background(Color.gray.opacity(0.2))
                        .cornerRadius(10)
                }
                
                Button(action: {
                    navigationPath.append("MedicalConditionForm")
                }) {
                    Text("次へ（選択中: \(session.symptoms.count) 件）")
                        .frame(maxWidth: .infinity)
                        .frame(height: 60)
                        .font(.system(size: 32, weight: .semibold))
                        .padding(.horizontal)
                        .background(session.symptoms.isEmpty ? Color.blue.opacity(0.4) : Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(10)
                }
                .disabled(session.symptoms.isEmpty)
            }
            .padding()
        }
        .navigationBarBackButtonHidden(true)
    }
}

#Preview {
    CurrentSymptomsFormView(navigationPath: .constant([]))
        .environmentObject(RecordingSession())
}
