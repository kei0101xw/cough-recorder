//
//  APIClient.swift
//  CoughRecoder
//
//  Created by 原田佳祐 on 2025/09/06.
//

import Foundation

struct StructuredData: Codable {
    let patientId: String
    let location: String
    let facility: String
    let ageGroup: String
    let biologicalSex: String
    let currentSymptoms: [String]
    let currentMedicalCondition: [String]
    let dementiaStatus: String
}

struct UploadRequest: Codable {
    let structuredData: StructuredData
    let coughFile: String
}

struct UploadResponse: Codable {
    let message: String?
}

enum APIError: Error, LocalizedError {
    case noRecordingURL, cannotReadAudio, invalidResponse, http(Int)
    var errorDescription: String? {
        switch self {
        case .noRecordingURL: return "録音ファイルが見つかりません。"
        case .cannotReadAudio: return "録音ファイルの読み込みに失敗しました。"
        case .invalidResponse: return "サーバーの応答が不正です。"
        case .http(let code): return "サーバーエラー (HTTP \(code))"
        }
    }
}

enum APIClient {
    static let endpoint = URL(string: "https://ydw26ea8a8.execute-api.us-east-1.amazonaws.com/prod/elderly-care-lambda")!

    static func upload(session: RecordingSession) async throws -> String {
        guard let recURL = session.recordingURL else { throw APIError.noRecordingURL }
        guard let audioData = try? Data(contentsOf: recURL) else { throw APIError.cannotReadAudio }

        let base64 = audioData.base64EncodedString()

        let body = UploadRequest(
            structuredData: StructuredData(
                patientId: session.id,
                location: "",
                facility: session.facility,
                ageGroup: session.age.map { String($0) } ?? "",
                biologicalSex: session.gender,
                currentSymptoms: Array(session.symptoms).sorted(),
                currentMedicalCondition: Array(session.conditions).sorted(),
                dementiaStatus: session.dementiaStatus
            ),
            coughFile: base64
        )

        var req = URLRequest(url: endpoint)
        req.httpMethod = "POST"
        req.setValue("application/json", forHTTPHeaderField: "Content-Type")
        req.httpBody = try JSONEncoder().encode(body)

        let (data, resp) = try await URLSession.shared.data(for: req)
        guard let http = resp as? HTTPURLResponse else { throw APIError.invalidResponse }
        guard (200..<300).contains(http.statusCode) else { throw APIError.http(http.statusCode) }

        if let decoded = try? JSONDecoder().decode(UploadResponse.self, from: data),
           let msg = decoded.message {
            return msg
        } else {
            return String(data: data, encoding: .utf8) ?? "Uploaded"
        }
    }
}
