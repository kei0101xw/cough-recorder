//
//  ImportCoordinator.swift
//  CoughRecoder
//
//  Created by 原田佳祐 on 2025/09/09.
//

import Foundation

@MainActor
final class ImportCoordinator: ObservableObject {
    static let shared = ImportCoordinator()
    @Published var lastImportedURL: URL?    // コピー先（Documents/Sessions/xxx.m4a）

    private init() {}

    func handleIncomingFile(url: URL) {
        // セキュリティスコープ
        let needStop = url.startAccessingSecurityScopedResource()
        defer { if needStop { url.stopAccessingSecurityScopedResource() } }

        do {
            // 保存先フォルダ
            let docs = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
            let sessionsDir = docs.appendingPathComponent("Sessions", isDirectory: true)
            try FileManager.default.createDirectory(at: sessionsDir, withIntermediateDirectories: true)

            // ファイル名（衝突回避）
            let ext = url.pathExtension.isEmpty ? "m4a" : url.pathExtension
            let base = "imported_\(Int(Date().timeIntervalSince1970)).\(ext)"
            let dst = sessionsDir.appendingPathComponent(base)

            // 既存なら消す→コピー
            try? FileManager.default.removeItem(at: dst)
            try FileManager.default.copyItem(at: url, to: dst)

            self.lastImportedURL = dst
        } catch {
            print("Import error:", error)
            self.lastImportedURL = nil
        }
    }
}
