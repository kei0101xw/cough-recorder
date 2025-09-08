//
//  AudioPreviewButton.swift
//  CoughRecoder
//
//  Created by 原田佳祐 on 2025/09/08.
//

import SwiftUI
import AVFoundation
import Combine

final class AudioPlayerDelegateBox: NSObject, AVAudioPlayerDelegate {
    var onFinish: (() -> Void)?
    func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool) {
        onFinish?()
    }
}

struct AudioPreviewButton: View {
    let url: URL

    @State private var player: AVAudioPlayer?
    @State private var isPlaying = false
    @State private var delegateBox = AudioPlayerDelegateBox()

    private let interruptionPublisher =
        NotificationCenter.default.publisher(for: AVAudioSession.interruptionNotification)
    private let routeChangePublisher =
        NotificationCenter.default.publisher(for: AVAudioSession.routeChangeNotification)

    var body: some View {
        Button(action: toggle) {
            HStack(spacing: 8) {
                Image(systemName: isPlaying ? "pause.circle.fill" : "play.circle.fill")
                    .font(.system(size: 28))
                Text(isPlaying ? "停止" : "再生")
                    .font(.system(size: 20))
            }
            .frame(minWidth: 90)
            .padding(.vertical, 6)
            .padding(.horizontal, 12)
            .background(Color.gray.opacity(0.15))
            .clipShape(RoundedRectangle(cornerRadius: 8))
        }
        .buttonStyle(.plain)
        .onReceive(interruptionPublisher) { notification in
            guard
                let info = notification.userInfo,
                let typeValue = info[AVAudioSessionInterruptionTypeKey] as? UInt,
                let type = AVAudioSession.InterruptionType(rawValue: typeValue)
            else { return }
            if type == .began { stop() }
        }
        .onReceive(routeChangePublisher) { _ in
            if isPlaying { stop() }
        }
        .onDisappear { stop() }
    }

    private func toggle() {
        if isPlaying {
            stop()
            return
        }
        do {
            let p = try AVAudioPlayer(contentsOf: url)
            p.prepareToPlay()

            delegateBox.onFinish = { [weak p] in
                DispatchQueue.main.async {
                    self.isPlaying = false
                    self.player = nil
                    p?.currentTime = 0
                }
            }
            p.delegate = delegateBox

            p.play()
            player = p
            isPlaying = true
        } catch {
            stop()
        }
    }

    private func stop() {
        player?.stop()
        player = nil
        isPlaying = false
    }
}
