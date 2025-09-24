import Foundation
import Combine

public struct AudioSettings: Codable, Equatable {
    public var sampleRate: Double
    public var format: String
    public var maxDurationSec: Int

    public init(sampleRate: Double = 44_100, format: String = "m4a", maxDurationSec: Int = 60) {
        self.sampleRate = sampleRate
        self.format = format
        self.maxDurationSec = maxDurationSec
    }
}


public final class AppSettings: ObservableObject, Codable {


    @Published public var facilities: [String]
    @Published public var minParticipantIDLength: Int
    @Published public var audio: AudioSettings

    private enum CodingKeys: String, CodingKey {
        case facilities, minParticipantIDLength, audio
    }

    public init(
        facilities: [String] = [],
        minParticipantIDLength: Int = 1,
        audio: AudioSettings = .init()
    ) {
        self.facilities = facilities
        self.minParticipantIDLength = minParticipantIDLength
        self.audio = audio
    }

    public required convenience init(from decoder: Decoder) throws {
        let c = try decoder.container(keyedBy: CodingKeys.self)
        let facilities = try c.decodeIfPresent([String].self, forKey: .facilities) ?? []
        let minLen = try c.decodeIfPresent(Int.self, forKey: .minParticipantIDLength) ?? 1
        let audio = try c.decodeIfPresent(AudioSettings.self, forKey: .audio) ?? .init()
        self.init(facilities: facilities, minParticipantIDLength: minLen, audio: audio)
    }

    public func encode(to encoder: Encoder) throws {
        var c = encoder.container(keyedBy: CodingKeys.self)
        try c.encode(facilities, forKey: .facilities)
        try c.encode(minParticipantIDLength, forKey: .minParticipantIDLength)
        try c.encode(audio, forKey: .audio)
    }

    private static let storageKey = "AppSettings.v1"


    @discardableResult
    public func save() -> Bool {
        do {
            let data = try JSONEncoder().encode(self)
            UserDefaults.standard.set(data, forKey: Self.storageKey)
            return true
        } catch {
            print("AppSettings save error:", error)
            return false
        }
    }


    public static func load() -> AppSettings {
        guard let data = UserDefaults.standard.data(forKey: storageKey) else {

            return AppSettings(facilities: ["A病院", "Bクリニック", "C大学病院"])
        }
        do {
            return try JSONDecoder().decode(AppSettings.self, from: data)
        } catch {
            print("AppSettings load error:", error)
            return AppSettings()
        }
    }

    public func addFacility(_ name: String) {
        let trimmed = name.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty, facilities.contains(trimmed) == false else { return }
        facilities.append(trimmed)
        _ = save()
    }

    public func removeFacilities(at offsets: IndexSet) {
        facilities.remove(atOffsets: offsets)
        _ = save()
    }

    public func updateFacility(from old: String, to new: String) {
        let newName = new.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !newName.isEmpty else { return }
        if let idx = facilities.firstIndex(of: old) {
            facilities[idx] = newName
            _ = save()
        }
    }
}
