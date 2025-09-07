import Foundation
import AVFoundation
import AVFAudio


final class AudioRecorder: NSObject, ObservableObject, AVAudioRecorderDelegate {
    @Published var levels: [CGFloat] = Array(repeating: 0, count: 60) // 画面に出すサンプル数
    private var meterTimer: Timer?

    private var audioRecorder: AVAudioRecorder?
    private(set) var currentFileURL: URL?
    private var stopCompletion: ((URL?) -> Void)?

    func startRecording(completion: @escaping (Result<URL, Error>) -> Void) {
        let requestPermission: (@escaping (Bool) -> Void) -> Void = { handler in
            if #available(iOS 17.0, *) {
                AVAudioApplication.requestRecordPermission { granted in handler(granted) }
            } else {
                AVAudioSession.sharedInstance().requestRecordPermission { granted in handler(granted) }
            }
        }

        requestPermission { [weak self] granted in
            guard let self else { return }
            if !granted {
                completion(.failure(NSError(
                    domain: "AudioRecorder", code: 1,
                    userInfo: [NSLocalizedDescriptionKey: "マイクのアクセスが許可されていません"]
                )))
                return
            }

            do {
                let session = AVAudioSession.sharedInstance()
                try session.setCategory(.playAndRecord, mode: .default, options: [.defaultToSpeaker])
                try session.setActive(true)

                let fileName = "cough_\(Int(Date().timeIntervalSince1970)).m4a"
                let fileURL = FileManager.default.temporaryDirectory.appendingPathComponent(fileName)
                self.currentFileURL = fileURL

                let settings: [String: Any] = [
                    AVFormatIDKey: Int(kAudioFormatMPEG4AAC),
                    AVSampleRateKey: 44_100,
                    AVNumberOfChannelsKey: 1,
                    AVEncoderAudioQualityKey: AVAudioQuality.high.rawValue
                ]

                self.audioRecorder = try AVAudioRecorder(url: fileURL, settings: settings)
                self.audioRecorder?.delegate = self
                self.audioRecorder?.isMeteringEnabled = true
                self.audioRecorder?.prepareToRecord()
                self.audioRecorder?.record()

                self.startMetering() // ← 追加：メータ更新開始

                completion(.success(fileURL))
            } catch {
                completion(.failure(error))
            }
        }
    }

    func stopRecording(completion: @escaping (URL?) -> Void) {
        stopCompletion = completion
        audioRecorder?.stop()
        stopMetering()

        DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) { [weak self] in
            guard let self, self.stopCompletion != nil else { return }
            let url = self.currentFileURL
            self.audioRecorder = nil
            try? AVAudioSession.sharedInstance().setActive(false, options: .notifyOthersOnDeactivation)
            self.stopCompletion?(url)
            self.stopCompletion = nil
        }
    }

    func discardAndDeleteFile() {
        audioRecorder?.stop()
        stopMetering()
        audioRecorder = nil
        if let url = currentFileURL { try? FileManager.default.removeItem(at: url) }
        currentFileURL = nil
        try? AVAudioSession.sharedInstance().setActive(false, options: .notifyOthersOnDeactivation)
    }

    // MARK: - Metering
    private func startMetering() {
        stopMetering()
        // 30fps程度で更新（必要なら10〜60fpsで調整）
        meterTimer = Timer.scheduledTimer(withTimeInterval: 1.0 / 30.0, repeats: true) { [weak self] _ in
            guard let self, let rec = self.audioRecorder else { return }
            rec.updateMeters()
            // dB値（-160〜0 目安）→ 0〜1の線形スケールに変換
            let db = rec.averagePower(forChannel: 0)
            let v = Self.dbToLinear(db)
            // 簡単なスムージング（前値との折衷）
            let smoothed = (self.levels.last ?? 0) * 0.6 + v * 0.4
            DispatchQueue.main.async {
                self.levels.append(smoothed)
                if self.levels.count > 60 { self.levels.removeFirst(self.levels.count - 60) }
            }
        }
    }

    private func stopMetering() {
        meterTimer?.invalidate()
        meterTimer = nil
    }

    private static func dbToLinear(_ db: Float) -> CGFloat {
        // dB→振幅: 10^(dB/20)。下限クランプして0〜1へ
        let minDb: Float = -60 // ノイズ底。必要に応じて -80 などに
        let clamped = max(db, minDb)
        let linear = pow(10.0, clamped / 20.0)
        return CGFloat(min(max(linear, 0), 1))
    }

    // MARK: - AVAudioRecorderDelegate
    func audioRecorderDidFinishRecording(_ recorder: AVAudioRecorder, successfully flag: Bool) {
        stopMetering()
        let url = flag ? currentFileURL : nil
        audioRecorder = nil
        try? AVAudioSession.sharedInstance().setActive(false, options: .notifyOthersOnDeactivation)
        stopCompletion?(url)
        stopCompletion = nil
    }
}
