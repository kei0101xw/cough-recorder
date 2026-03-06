import XCTest
@testable import CoughRecoder

final class AppUnitTests: XCTestCase {

    override func setUp() {
        super.setUp()
        // Ensure clean UserDefaults before each test
        UserDefaults.standard.removeObject(forKey: "AppSettings.v1")
        UserDefaults.standard.removeObject(forKey: "RecordingSession.cooldownUntil")
    }

    override func tearDown() {
        // Cleanup
        UserDefaults.standard.removeObject(forKey: "AppSettings.v1")
        UserDefaults.standard.removeObject(forKey: "RecordingSession.cooldownUntil")
        super.tearDown()
    }

    func testAppSettings_save_and_load() throws {
        let settings = AppSettings(facilities: ["X病院", "Yクリニック"], minParticipantIDLength: 2, audio: AudioSettings(sampleRate: 48000, format: "wav", maxDurationSec: 30))
        XCTAssertTrue(settings.save(), "AppSettings.save should return true")

        let loaded = AppSettings.load()
        XCTAssertEqual(loaded.facilities, ["X病院", "Yクリニック"])
        XCTAssertEqual(loaded.minParticipantIDLength, 2)
        XCTAssertEqual(loaded.audio.sampleRate, 48000)
        XCTAssertEqual(loaded.audio.format, "wav")
        XCTAssertEqual(loaded.audio.maxDurationSec, 30)
    }

    func testAppSettings_add_update_remove_facility_behaviour() throws {
        let settings = AppSettings(facilities: ["A病院", "Bクリニック"], minParticipantIDLength: 1)
        XCTAssertTrue(settings.save())

        // Add with surrounding whitespace -> should be trimmed and appended
        settings.addFacility(" Cクリニック ")
        XCTAssertTrue(settings.facilities.contains("Cクリニック"))

        // Adding duplicate should do nothing
        let beforeCount = settings.facilities.count
        settings.addFacility("A病院")
        XCTAssertEqual(settings.facilities.count, beforeCount)

        // Update facility name with trimming
        settings.updateFacility(from: "Bクリニック", to: " B2クリニック ")
        XCTAssertTrue(settings.facilities.contains("B2クリニック"))
        XCTAssertFalse(settings.facilities.contains("Bクリニック"))

        // Remove first facility
        settings.removeFacilities(at: IndexSet(integer: 0))
        // Ensure the array shortened
        XCTAssertEqual(settings.facilities.count, beforeCount) // removed one, but one duplicate add was ignored
    }

    func testRecordingSession_cooldown_persistence_and_flags() throws {
        // Ensure key removed
        UserDefaults.standard.removeObject(forKey: "RecordingSession.cooldownUntil")

        let session = RecordingSession()
        XCTAssertFalse(session.isInCooldown)
        XCTAssertEqual(session.remainingCooldownSeconds, 0)

        // Start a short cooldown (5 sec)
        session.startCooldown(seconds: 5)
        XCTAssertTrue(session.isInCooldown)
        XCTAssertGreaterThanOrEqual(session.remainingCooldownSeconds, 1)

        // Create a new instance to verify persistence
        let newSession = RecordingSession()
        XCTAssertTrue(newSession.isInCooldown)
        XCTAssertGreaterThan(newSession.remainingCooldownSeconds, 0)

        // Reset session fields should not clear cooldown
        newSession.sessionReset()
        XCTAssertTrue(newSession.isInCooldown)
    }

    func testAppFileStore_saveSession_creates_audio_and_json_payload() throws {
        // Prepare a temporary audio file
        let tmpDir = FileManager.default.temporaryDirectory
        let srcURL = tmpDir.appendingPathComponent("test_audio_\(UUID().uuidString).m4a")
        let sampleData = "dummy audio data".data(using: .utf8)!
        try sampleData.write(to: srcURL)

        let session = RecordingSession()
        session.id = "test-id-1"
        session.facility = "Test Hospital"
        session.gender = "M"
        session.age = 42
        session.symptoms = ["cough", "fever", "a sore throat"]
        session.conditions = ["z", "y"]
        session.dementiaStatus = "none"
        session.recordingURL = srcURL

        // let fileStore = AppFileStore()
        let fileStore = AppFileStore.shared

        // Call saveSession
        let sessionDir = try fileStore.saveSession(session)

        // Check that sessionDir exists
        var isDirectory: ObjCBool = false
        XCTAssertTrue(FileManager.default.fileExists(atPath: sessionDir.path, isDirectory: &isDirectory))
        XCTAssertTrue(isDirectory.boolValue)

        // Look for audio and json files
        let contents = try FileManager.default.contentsOfDirectory(at: sessionDir, includingPropertiesForKeys: nil)
        let audioFiles = contents.filter { $0.pathExtension == "m4a" }
        let jsonFiles = contents.filter { $0.pathExtension == "json" }

        XCTAssertFalse(audioFiles.isEmpty, "Expected at least one audio file in Sessions dir")
        XCTAssertFalse(jsonFiles.isEmpty, "Expected at least one json file in Sessions dir")

        // Decode the JSON payload
        let jsonData = try Data(contentsOf: jsonFiles[0])
        let payload = try JSONDecoder().decode(SessionPayload.self, from: jsonData)

        XCTAssertEqual(payload.id, "test-id-1")
        XCTAssertEqual(payload.facility, "Test Hospital")
        XCTAssertEqual(payload.gender, "M")
        XCTAssertEqual(payload.age, 42)
        XCTAssertEqual(payload.dementiaStatus, "none")

        // Symptoms and conditions should be sorted alphabetically
        XCTAssertEqual(payload.symptoms, payload.symptoms.sorted())
        XCTAssertEqual(payload.conditions, payload.conditions.sorted())

        // Cleanup created files
        try? FileManager.default.removeItem(at: sessionDir)
        try? FileManager.default.removeItem(at: srcURL)
    }
}
