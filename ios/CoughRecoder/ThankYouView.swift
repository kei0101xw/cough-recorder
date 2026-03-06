import SwiftUI

struct ThankYouView: View {
    @Binding var navigationPath: [String]
    @EnvironmentObject var session: RecordingSession
    @Environment(\.horizontalSizeClass) private var hSize
    
    var body: some View {
        VStack {
            Text("ご協力ありがとうございました")
                .font(.system(size: AppUI.titleFontSize(hSize: hSize), weight: .regular))
                .padding(.vertical, 12)
            Divider()
            Spacer()
            Image(.thankYou)
                .resizable()
                .scaledToFit()
                .frame(height: Layout.imageHeight(hSize))
            Spacer();
            VStack(spacing: 8) {
                Text("あなたの参加者ID:")
                    .font(.headline)

                Text(session.id.isEmpty ? "未設定" : session.id)
                    .font(.system(size: 28, weight: .bold))
                    .foregroundColor(.blue)
                    .padding(.vertical, 12)
                    
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
            .font(.system(size: AppUI.sentenceFontSize(hSize: hSize)))
            .padding(.horizontal, Layout.horizontalPadding(hSize))
            .frame(maxWidth: .infinity)
            Spacer();
            Divider()
            Button(action: {
                navigationPath.removeAll()
            }) {
                Text("ホームへ戻る")
                    .frame(width: UIScreen.main.bounds.width / 2)
                    .frame(height: AppUI.buttonHeight(hSize: hSize))
                    .font(.system(size: AppUI.buttonFontSize(hSize: hSize)))
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

extension ThankYouView {
    enum Layout {
        static func imageHeight(_ hSize: UserInterfaceSizeClass?) -> CGFloat {
            (hSize == .compact) ? 150 : 250
        }
        static func horizontalPadding(_ hSize: UserInterfaceSizeClass?) -> CGFloat {
            (hSize == .compact) ? 50 : 100
        }
    }
}

#Preview {
    ThankYouView(navigationPath: .constant([]))
        .environmentObject(RecordingSession())
}
