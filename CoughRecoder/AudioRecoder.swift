import Foundation
import AVFoundation
import AVFAudio


final class AudioRecorder: NSObject, ObservableObject, AVAudioRecorderDelegate {
    private var audioRecorder: AVAudioRecorder?
    private(set) var currentFileURL: URL?
    private var stopCompletion: ((URL?) -> Void)?


    func startRecording(completion: @escaping (Result<URL, Error>) -> Void) {

        let requestPermission: (@escaping (Bool) -> Void) -> Void = { handler in
            if #available(iOS 17.0, *) {
                AVAudioApplication.requestRecordPermission { granted in
                    handler(granted)
                }
            } else {
                AVAudioSession.sharedInstance().requestRecordPermission { granted in
                    handler(granted)
                }
            }
        }

        requestPermission { [weak self] granted in
            guard let self else { return }
            if !granted {
                completion(.failure(NSError(
                    domain: "AudioRecorder",
                    code: 1,
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

                // 5) レコーダ作成＆開始
                self.audioRecorder = try AVAudioRecorder(url: fileURL, settings: settings)
                self.audioRecorder?.delegate = self
                self.audioRecorder?.isMeteringEnabled = true
                self.audioRecorder?.prepareToRecord()
                self.audioRecorder?.record()

                completion(.success(fileURL))
            } catch {
                completion(.failure(error))
            }
        }
    }

    /// 録音停止（書き込み終了を待ってからURLを返す）
    func stopRecording(completion: @escaping (URL?) -> Void) {
        stopCompletion = completion
        audioRecorder?.stop()

        // 2秒返ってこなければ終了処理を強制
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) { [weak self] in
            guard let self else { return }
            if self.stopCompletion != nil {
                let url = self.currentFileURL
                self.audioRecorder = nil
                try? AVAudioSession.sharedInstance().setActive(false, options: .notifyOthersOnDeactivation)
                self.stopCompletion?(url)
                self.stopCompletion = nil
            }
        }
    }


    func discardAndDeleteFile() {
        audioRecorder?.stop()
        audioRecorder = nil
        if let url = currentFileURL {
            try? FileManager.default.removeItem(at: url)
        }
        currentFileURL = nil
        try? AVAudioSession.sharedInstance().setActive(false, options: .notifyOthersOnDeactivation)
    }

    // MARK: - AVAudioRecorderDelegate
    func audioRecorderDidFinishRecording(_ recorder: AVAudioRecorder, successfully flag: Bool) {
        let url = flag ? currentFileURL : nil
        audioRecorder = nil
        try? AVAudioSession.sharedInstance().setActive(false, options: .notifyOthersOnDeactivation)
        stopCompletion?(url)
        stopCompletion = nil
    }
}
