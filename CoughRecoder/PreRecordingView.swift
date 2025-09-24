import SwiftUI

struct PreRecordingView: View {
    @Binding var navigationPath: [String]
    
    var body: some View {
        VStack {
            
            Text("録音を開始します")
                .font(.system(size: 30, weight: .regular))
                .padding(.vertical, 12)
            Divider()
            Spacer()
            HStack(alignment: .top) {
                VStack {
                    HStack(alignment: .firstTextBaseline) {
                        NumberCircle(number: 1)
                        Text("静かな環境で録音してください。")
                            .font(.system(size: 25))
                    }
                    .frame(height: 150, alignment: .top)

                    Image(.preReco1)
                        .resizable()
                        .scaledToFit()
                        .frame(height: 250)
                }
                .frame(maxWidth: .infinity)
                .padding(.horizontal)
                VStack {
                    HStack(alignment: .firstTextBaseline) {
                        NumberCircle(number: 2)
                        Text("録音時に「咳をしてください」などの、周辺からの話しかけはしないでください。")
                            .font(.system(size: 25))
                    }
                    .frame(height: 150, alignment: .top)

                    Image(.preReco2)
                        .resizable()
                        .scaledToFit()
                        .frame(height: 250)
                }
                .frame(maxWidth: .infinity)
                .padding(.horizontal)
                VStack {
                    HStack(alignment: .firstTextBaseline) {
                        NumberCircle(number: 3)
                        Text("録音は5秒以上30秒以内で最低3回以上の咳をしてください。")
                            .font(.system(size: 25))
                    }
                    .frame(height: 150, alignment: .top)

                    Image(.preReco3)
                        .resizable()
                        .scaledToFit()
                        .frame(height: 250)
                }
                .frame(maxWidth: .infinity)
                .padding(.horizontal)
            }
            .padding(.horizontal)
            
            
            Spacer()
            
            Divider()
            
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
                    navigationPath.append("Recording")
                }) {
                    Text("録音開始")
                        .frame(maxWidth: .infinity)
                        .frame(height: 60)
                        .font(.system(size: 32))
                        .padding(.horizontal)
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(10)
                }
            }
            .padding()
        }
        .navigationBarBackButtonHidden(true)
    }
}

#Preview {
    PreRecordingView(navigationPath: .constant([]))
        .environmentObject(RecordingSession())
}
