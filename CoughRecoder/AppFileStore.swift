//
//  AppFileStore.swift
//  CoughRecoder
//
//  Created by 原田佳祐 on 2025/08/26.
//

import Foundation

struct SessionPayload: Codable {
    let id: String
    let facility: String
    let gender: String
    let age: Int?
    let symptoms: [String]
    let conditions: [String]
    let dementiaStatus: String
    let audioFileName: String
    let savedAt: Date
}

final class AppFileStore {
    static let shared = AppFileStore()
    private init() {}

    @discardableResult
    func saveSession(_ session: RecordingSession) throws -> URL {
        // 保存ディレクトリ: Documents/Sessions
        let docs = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        let sessionDir = docs.appendingPathComponent("Sessions", conformingTo: .directory)
        try FileManager.default.createDirectory(at: sessionDir, withIntermediateDirectories: true)

        // 日時
        let ts = Int(Date().timeIntervalSince1970)
        let base = "session_\(ts)"

        // 音声ファイルをコピー
        guard let srcURL = session.recordingURL else {
            throw NSError(domain: "AppFileStore", code: 1, userInfo: [NSLocalizedDescriptionKey: "録音ファイルが見つかりません"])
        }
        let audioExt = srcURL.pathExtension.isEmpty ? "m4a" : srcURL.pathExtension
        let audioFileName = "\(base).\(audioExt)"
        let dstAudioURL = sessionDir.appendingPathComponent(audioFileName)

        try? FileManager.default.removeItem(at: dstAudioURL)
        try FileManager.default.copyItem(at: srcURL, to: dstAudioURL)


        let payload = SessionPayload(
            id: session.id,
            facility: session.facility,
            gender: session.gender,
            age: session.age,
            symptoms: Array(session.symptoms).sorted(),
            conditions: Array(session.conditions).sorted(),
            dementiaStatus: session.dementiaStatus, 
            audioFileName: audioFileName,
            savedAt: Date()
        )
        let jsonURL = sessionDir.appendingPathComponent("\(base).json")
        let data = try JSONEncoder().encode(payload)
        try data.write(to: jsonURL, options: [.atomic])

        return sessionDir
    }
}
