import SwiftUI

struct ThankYouView: View {
    @Binding var navigationPath: [String]
    @EnvironmentObject var session: RecordingSession
    
    var body: some View {
        VStack {
            Text("ご協力ありがとうございました")
                .font(.system(size: 30, weight: .regular))
                .padding(.vertical, 12)
            Divider()
            Spacer()
            Image(.thankYou)
                .resizable()
                .scaledToFit()
                .frame(height: 250)
            Spacer();
            VStack(spacing: 8) {
                Text("あなたの参加者ID:")
                    .font(.headline)

                Text(session.id.isEmpty ? "未設定" : session.id)
                    .font(.system(size: 28, weight: .bold))
                    .foregroundColor(.blue)
                    .padding(.vertical, 12)
                    .padding(.horizontal, 24)
                    
            }
            .frame(width: UIScreen.main.bounds.width / 2)
            .padding(.vertical, 12)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(Color.blue, lineWidth: 2)
            )
            
            Spacer()
            
            Text("""
            参加者IDは、今後、あなたの匿名化されたデータを九州大学へ削除依頼する際に必要となりますので、必ず保管してください。
            その後、咳や発熱、息切れなど新たに症状が出た場合は、再度、最新の咳の音を投稿してください。
            """)
            .font(.system(size: 20))
            .padding(.horizontal, 100)
            .frame(maxWidth: .infinity)
            Spacer();
            Divider()
            Button(action: {
                navigationPath.removeAll()
            }) {
                Text("ホームへ戻る")
                    .frame(width: UIScreen.main.bounds.width / 2)
                    .frame(height: 60)
                    .font(.system(size: 32))
                    .padding(.horizontal)
                    .background(Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(10)
            }
            .padding()
        }
        .onDisappear {
            session.sessionReset()
        }
        .navigationBarBackButtonHidden(true)
    }
}

#Preview {
    ThankYouView(navigationPath: .constant([]))
        .environmentObject(RecordingSession())
}
