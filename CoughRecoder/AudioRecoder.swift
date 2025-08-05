//
//  AudioRecoder.swift
//  CoughRecoder
//
//  Created by 原田佳祐 on 2025/08/05.
//

import Foundation
import AVFoundation

class AudioRecorder {
    var audioRecorder: AVAudioRecorder?

    func startRecording() {
        let settings = [
            AVFormatIDKey: Int(kAudioFormatMPEG4AAC),
            AVSampleRateKey: 44100,
            AVNumberOfChannelsKey: 1,
            AVEncoderAudioQualityKey: AVAudioQuality.high.rawValue
        ]

        do {
            let fileURL = FileManager.default.temporaryDirectory.appendingPathComponent("cough_record.m4a")
            audioRecorder = try AVAudioRecorder(url: fileURL, settings: settings)
            audioRecorder?.record()
            print("録音開始")
        } catch {
            print("録音エラー: \(error)")
        }
    }

    func stopRecording() {
        audioRecorder?.stop()
        print("録音停止")
    }
}
