//
//  RecordingSession.swift
//  CoughRecoder
//
//  Created by 原田佳祐 on 2025/08/24.
//

import Foundation

final class RecordingSession: ObservableObject {
    @Published var id: String = ""
    @Published var facility: String = ""
    @Published var gender: String = ""
    @Published var age: Int? = nil
    @Published var symptoms: Set<String> = []
    @Published var conditions: Set<String> = []
    @Published var recordingURL: URL? = nil
    @Published var dementiaStatus: String = ""


    func sessionReset() {
        id = ""
        facility = ""
        gender = ""
        age = nil
        symptoms.removeAll()
        conditions.removeAll()
        recordingURL = nil
        dementiaStatus = ""
    }
}
