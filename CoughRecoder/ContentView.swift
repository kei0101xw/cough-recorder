//
//  ContentView.swift
//  CoughRecoder
//
//  Created by 原田佳祐 on 2025/08/05.
//

import SwiftUI

struct ContentView: View {
    @State var navigationPath: [String] = []
    @EnvironmentObject var session: RecordingSession
    @Environment(\.scenePhase) private var scenePhase

    // 残り秒計算（TimelineView の date を使う）
    private func remainingSeconds(at date: Date) -> Int {
        guard let until = session.cooldownUntil else { return 0 }
        return max(0, Int(ceil(until.timeIntervalSince(date))))
    }
    private func isInCooldown(at date: Date) -> Bool {
        remainingSeconds(at: date) > 0
    }

    var body: some View {
        NavigationStack(path: $navigationPath) {
            ZStack {
                Color.blue.ignoresSafeArea()

                VStack {
                    Spacer()
                    HStack {
                        Image(.appTitle)
                            .resizable()
                            .scaledToFit()
                            .frame(height: 130)
                        Text("Cough Recorder")
                            .font(.system(size: 60)).bold()
                            .foregroundColor(.white)
                    }
                    Spacer()
                    Rectangle()
                        .fill(Color.white)
                        .frame(maxWidth: .infinity)
                        .frame(height: 450)
                        .clipShape(.rect(topLeadingRadius: 50,
                                         bottomLeadingRadius: 0,
                                         bottomTrailingRadius: 0,
                                         topTrailingRadius: 50))
                }
                .edgesIgnoringSafeArea(.all)

                // ← ここを TimelineView で包む
                TimelineView(.periodic(from: .now, by: 1)) { context in
                    let remain = remainingSeconds(at: context.date)
                    let cooling = remain > 0

                    VStack {
                        Spacer()
                        Text("")
                        VStack(spacing: 30) {
                            Button {
                                navigationPath.append("PreRecording")
                                session.sessionReset()
                            } label: {
                                HStack(spacing: 20) {
                                    Spacer()
                                    Text("録音する")
                                        .font(.system(size: 30)).bold()
                                    Image(systemName: "mic.fill")
                                        .resizable()
                                        .scaledToFit()
                                        .frame(height: 40)
                                    Spacer()
                                }
                            }
                            .frame(width: UIScreen.main.bounds.width / 2)
                            .frame(height: 80)
                            .background(Color.blue)
                            .foregroundColor(.white)
                            .cornerRadius(20)
                            .disabled(cooling)
                            .opacity(cooling ? 0.5 : 1.0)
                            .overlay(
                                Group {
                                    if cooling {
                                        Text("あと \(remain) 秒")
                                            .font(.system(size: 16, weight: .bold))
                                            .padding(30)
                                            .foregroundColor(.white)
                                    }
                                }
                                .padding(.trailing, 12),
                                alignment: .trailing
                            )

                            VStack {
                                Button {
                                    navigationPath.append("CoughLog")
                                } label: {
                                    HStack(spacing: 20)  {
                                        Text("咳記録ログ")
                                            .font(.system(size: 30)).bold()
                                        Image(systemName: "list.bullet.rectangle.fill")
                                            .resizable()
                                            .scaledToFit()
                                            .frame(height: 30)
                                    }
                                    .frame(width: UIScreen.main.bounds.width / 2)
                                    .frame(height: 80)
                                    .foregroundColor(Color.primary.opacity(0.7))
                                    .background(Color(.systemGray5))
                                    .cornerRadius(20)
                                }
                            }
                        }
                        .padding(.bottom, 120)
                    }
                }
            }
            .navigationDestination(for: String.self) { value in
                switch value {
                case "CoughLog": CoughLogView(navigationPath: $navigationPath)
                case "PreRecording": PreRecordingView(navigationPath: $navigationPath)
                case "Recording": RecordingView(navigationPath: $navigationPath)
                case "RecordingReview": RecordingReviewView(navigationPath: $navigationPath)
                case "PatientInfoForm": PatientInfoFormView(navigationPath: $navigationPath)
                case "GenderAgeForm": GenderAgeFormView(navigationPath: $navigationPath)
                case "CurrentSymptomsForm": CurrentSymptomsFormView(navigationPath: $navigationPath)
                case "MedicalConditionForm": MedicalConditionFormView(navigationPath: $navigationPath)
                case "DementiaStatusForm": DementiaStatusFormView(navigationPath: $navigationPath)
                default: EmptyView()
                }
            }
            // 任意：フォアグラウンド復帰で即時再評価したい時の軽い起爆剤
            .onChange(of: scenePhase) { oldValue, newValue in
                if newValue == .active {
                    // TimelineViewが更新を始めるので特に不要だが、
                    // 必要ならここで軽い処理を入れてもOK
                }
            }
        }
    }
}

#Preview {
    ContentView()
        .environmentObject(RecordingSession())
}
