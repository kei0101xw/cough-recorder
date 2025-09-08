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

    // ▼ 追加：クールダウン解除予定時刻（これを保存・復元）
    @Published var cooldownUntil: Date? {
        didSet { saveCooldownUntil() }
    }

    private static let cooldownKey = "RecordingSession.cooldownUntil"

    init() {
        // アプリ起動時に前回の値を復元
        if let ts = UserDefaults.standard.object(forKey: Self.cooldownKey) as? TimeInterval {
            cooldownUntil = Date(timeIntervalSince1970: ts)
        } else {
            cooldownUntil = nil
        }
    }

    /// 送信成功などのタイミングで呼ぶ
    func startCooldown(seconds: TimeInterval = 20) {
        cooldownUntil = Date().addingTimeInterval(seconds)
    }

    /// 今クールダウン中かどうか
    var isInCooldown: Bool {
        guard let until = cooldownUntil else { return false }
        return Date() < until
    }

    /// 残り秒（UI表示用）
    var remainingCooldownSeconds: Int {
        guard let until = cooldownUntil else { return 0 }
        return max(0, Int(ceil(until.timeIntervalSinceNow)))
    }

    private func saveCooldownUntil() {
        if let until = cooldownUntil {
            UserDefaults.standard.set(until.timeIntervalSince1970, forKey: Self.cooldownKey)
        } else {
            UserDefaults.standard.removeObject(forKey: Self.cooldownKey)
        }
    }

    func sessionReset() {
        id = ""
        facility = ""
        gender = ""
        age = nil
        symptoms.removeAll()
        conditions.removeAll()
        recordingURL = nil
        dementiaStatus = ""
        // クールダウンは維持したいので cooldownUntil は消さない
    }
}
