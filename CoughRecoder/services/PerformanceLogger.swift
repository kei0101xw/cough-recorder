import Foundation

struct PerformanceRecord: Codable {
    let timestamp: String
    let eventName: String
    let duration: Double
    let success: Bool
    let errorMessage: String?
    
    enum CodingKeys: String, CodingKey {
        case timestamp = "実行時刻"
        case eventName = "イベント名"
        case duration = "待ち時間(秒)"
        case success = "成功"
        case errorMessage = "エラーメッセージ"
    }
}

final class PerformanceLogger {
    static let shared = PerformanceLogger()
    private init() {}
    
    private let csvFileName = "performance_metrics.csv"
    
    private var csvFilePath: URL {
        let docs = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        return docs.appendingPathComponent(csvFileName)
    }
    
    // MARK: - CSV Header
    private func getCSVHeader() -> String {
        return "実行時刻,イベント名,待ち時間(秒),成功,エラーメッセージ\n"
    }
    
    // MARK: - Record Performance
    func logPerformance(
        eventName: String,
        duration: TimeInterval,
        success: Bool,
        errorMessage: String? = nil
    ) {
        let record = PerformanceRecord(
            timestamp: formatTimestamp(Date()),
            eventName: eventName,
            duration: duration,
            success: success,
            errorMessage: errorMessage
        )
        
        writeRecordToCSV(record)
    }
    
    // MARK: - Private Methods
    private func formatTimestamp(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd HH:mm:ss.SSS"
        return formatter.string(from: date)
    }
    
    private func writeRecordToCSV(_ record: PerformanceRecord) {
        let csvLine = createCSVLine(from: record)
        
        do {
            let fileExists = FileManager.default.fileExists(atPath: csvFilePath.path)
            
            if !fileExists {
                // ファイルが存在しない場合、ヘッダーを含めて作成
                let header = getCSVHeader()
                try header.write(to: csvFilePath, atomically: true, encoding: .utf8)
            }
            
            // 既存の内容を読み込む
            var existingContent = try String(contentsOf: csvFilePath, encoding: .utf8)
            
            // 新しい行を追加
            existingContent.append(csvLine + "\n")
            
            // ファイルに書き込む
            try existingContent.write(to: csvFilePath, atomically: true, encoding: .utf8)
            
            print("✅ Performance logged: \(record.eventName) - \(record.duration)s")
        } catch {
            print("❌ Failed to log performance: \(error.localizedDescription)")
        }
    }
    
    private func createCSVLine(from record: PerformanceRecord) -> String {
        let timestamp = escapeCSV(record.timestamp)
        let eventName = escapeCSV(record.eventName)
        let duration = String(format: "%.3f", record.duration)
        let success = record.success ? "はい" : "いいえ"
        let errorMessage = escapeCSV(record.errorMessage ?? "")
        
        return "\(timestamp),\(eventName),\(duration),\(success),\(errorMessage)"
    }
    
    private func escapeCSV(_ string: String) -> String {
        // カンマ、改行、ダブルクォートを含む場合はダブルクォートで囲む
        if string.contains(",") || string.contains("\n") || string.contains("\"") {
            return "\"\(string.replacingOccurrences(of: "\"", with: "\"\""))\""
        }
        return string
    }
    
    // MARK: - Get CSV File Path
    func getCSVFileURL() -> URL {
        print("📁 CSVファイルの保存先を確認してください:")
        print("📍 \(csvFilePath.path)")
        return csvFilePath
    }
    
    // MARK: - Get All Records
    func getAllRecords() -> [String] {
        do {
            guard FileManager.default.fileExists(atPath: csvFilePath.path) else {
                return []
            }
            let content = try String(contentsOf: csvFilePath, encoding: .utf8)
            return content.components(separatedBy: .newlines).filter { !$0.isEmpty }
        } catch {
            print("❌ Failed to read CSV file: \(error.localizedDescription)")
            return []
        }
    }
    
    // MARK: - Clear All Records
    func clearAllRecords() {
        do {
            try FileManager.default.removeItem(at: csvFilePath)
            print("✅ Performance log cleared")
        } catch {
            print("❌ Failed to clear performance log: \(error.localizedDescription)")
        }
    }
}
