//
//  ContentView.swift
//  CoughRecoder
//
//  Created by 原田佳祐 on 2025/08/05.
//

import SwiftUI

struct ContentView: View {
    @State var navigationPath: [String] = []
    
    var body: some View {
        NavigationStack(path: $navigationPath) {
            VStack {
                ZStack {
                    Image(.header)
                        .ignoresSafeArea()
                    HStack {
                        Image(.virufyLogo)
                        Image(.virufyText)
                    }
                }
                
                
                Spacer()
                
                HStack {
                    Button {
                        navigationPath.append("PatientInfoForm")
                    } label: {
                        VStack {
                            Spacer()
                            Text("録音する")
                                .font(.system(size: 50))
                                .bold()
                            Spacer()
                            Image(systemName: "mic.fill")
                                .resizable()
                                .scaledToFit()
                                .frame(height: 100)
                            Spacer()
                        }
                        .frame(width: 500, height: 400)
                        .padding()
                        .background(Color.startButton.opacity(0.1))
                        .foregroundColor(.startButton)
                        .overlay(
                            RoundedRectangle(cornerRadius: 10)
                                .stroke(Color.startButton, lineWidth: 10)
                        )
                        .cornerRadius(10)
                    }
                    .padding()
                    
                    VStack {
                        Button {
                            navigationPath.append("CoughLog")
                        } label: {
                            VStack {
                                Text("咳記録ログ")
                                    .font(.system(size: 50))
                                    .bold()
                                Image(systemName: "list.bullet.rectangle.fill")
                                    .resizable()
                                    .scaledToFit()
                                    .frame(height: 60)
                            }
                            .frame(width: 500, height: 180)
                            .padding()
                            .background(Color.logButton.opacity(0.1))
                            .foregroundColor(.logButton)
                            .overlay(
                                RoundedRectangle(cornerRadius: 10)
                                    .stroke(Color.logButton, lineWidth: 10)
                            )
                            .cornerRadius(10)
                        }
                        
                        Button {
                            navigationPath.append("Settings")
                        } label: {
                            VStack {
                                Text("設定")
                                    .font(.system(size: 50))
                                    .bold()
                                Image(systemName: "gearshape.fill")
                                    .resizable()
                                    .scaledToFit()
                                    .frame(height: 60)
                            }
                            .frame(width: 500, height: 180)
                            .padding()
                            .background(Color.settingButton.opacity(0.1))
                            .foregroundColor(.blue)
                            .overlay(
                                RoundedRectangle(cornerRadius: 10)
                                    .stroke(Color.blue, lineWidth: 10)
                            )
                            .cornerRadius(10)
                        }
                    }
                }
                Spacer()
            }
            .navigationDestination(for: String.self) { value in
                switch value {
                case "PatientInfoForm":
                    PatientInfoFormView(navigationPath: $navigationPath)
                case "CoughLog":
                    CoughLogView(navigationPath: $navigationPath)
                case "Settings":
                    SettingsView(navigationPath: $navigationPath)
                case "PreRecording":
                    PreRecordingView(navigationPath: $navigationPath)
                case "Recording":
                    RecordingView(navigationPath: $navigationPath)
                case "RecordingReview":
                    RecordingReviewView(navigationPath: $navigationPath)
                case "GenderAgeForm":
                    GenderAgeFormView(navigationPath:
                        $navigationPath)
                case "CurrentSymptomsForm":
                    CurrentSymptomsFormView(navigationPath:
                        $navigationPath)
                case "MedicalConditionForm":
                    MedicalConditionFormView(navigationPath:
                        $navigationPath)
                default:
                    EmptyView()
                }
            }
        }
    }
}

#Preview {
    ContentView()
}
