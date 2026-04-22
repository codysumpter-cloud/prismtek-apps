import Foundation

extension Paths {
    static var pixelLabPreviewRecordsFile: URL {
        stateDirectory.appendingPathComponent("pixellab-preview-records.json")
    }
}

enum PixelLabPreviewStatus: String, Codable {
    case queued
    case ready
    case failed
}

struct PixelLabPreviewRecord: Codable, Hashable {
    var requestKey: String
    var buddyName: String
    var previewURL: String?
    var status: PixelLabPreviewStatus
    var errorMessage: String?
    var updatedAt: Date
}

enum PixelLabPreviewService {
    private static let endpoint = URL(string: "https://api.pixellab.ai/mcp")!

    static func record(for requestKey: String) -> PixelLabPreviewRecord? {
        guard let data = try? Data(contentsOf: Paths.pixelLabPreviewRecordsFile),
              let records = try? JSONDecoder().decode([String: PixelLabPreviewRecord].self, from: data) else {
            return nil
        }
        return records[requestKey]
    }

    static func sync(
        requestKey: String,
        buddyName: String,
        archetypeID: String,
        paletteID: String,
        expressionTone: String,
        accentLabel: String,
        accessToken: String
    ) async -> PixelLabPreviewRecord {
        if let existing = record(for: requestKey), existing.status == .ready {
            return existing
        }

        var request = URLRequest(url: endpoint)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("application/json", forHTTPHeaderField: "Accept")
        request.setValue("Bearer \(accessToken)", forHTTPHeaderField: "Authorization")
        request.httpBody = try? JSONSerialization.data(withJSONObject: [
            "jsonrpc": "2.0",
            "id": 1,
            "method": "tools/call",
            "params": [
                "name": "create_character",
                "arguments": [
                    "name": buddyName,
                    "description": "cute \(archetypeID) pixel buddy, palette \(paletteID), mood \(expressionTone), accent \(accentLabel), transparent background, one centered character, readable silhouette",
                    "size": 48,
                    "n_directions": 4,
                    "mode": "standard"
                ]
            ]
        ])

        do {
            let (data, _) = try await URLSession.shared.data(for: request)
            let json = (try JSONSerialization.jsonObject(with: data) as? [String: Any]) ?? [:]
            let previewURL = findString(in: json, keys: ["preview_url", "previewUrl", "preview_image"])
            let record = PixelLabPreviewRecord(
                requestKey: requestKey,
                buddyName: buddyName,
                previewURL: previewURL,
                status: previewURL == nil ? .queued : .ready,
                errorMessage: nil,
                updatedAt: .now
            )
            save(record)
            return record
        } catch {
            let record = PixelLabPreviewRecord(
                requestKey: requestKey,
                buddyName: buddyName,
                previewURL: nil,
                status: .failed,
                errorMessage: error.localizedDescription,
                updatedAt: .now
            )
            save(record)
            return record
        }
    }

    private static func save(_ record: PixelLabPreviewRecord) {
        var records: [String: PixelLabPreviewRecord] = [:]
        if let data = try? Data(contentsOf: Paths.pixelLabPreviewRecordsFile),
           let decoded = try? JSONDecoder().decode([String: PixelLabPreviewRecord].self, from: data) {
            records = decoded
        }
        records[record.requestKey] = record
        if let data = try? JSONEncoder().encode(records) {
            try? FileManager.default.createDirectory(at: Paths.pixelLabPreviewRecordsFile.deletingLastPathComponent(), withIntermediateDirectories: true)
            try? data.write(to: Paths.pixelLabPreviewRecordsFile, options: [.atomic])
        }
    }

    private static func findString(in value: Any, keys: [String]) -> String? {
        if let dict = value as? [String: Any] {
            for key in keys {
                if let str = dict[key] as? String, !str.isEmpty {
                    return str
                }
            }
            for child in dict.values {
                if let found = findString(in: child, keys: keys) {
                    return found
                }
            }
        }
        if let array = value as? [Any] {
            for child in array {
                if let found = findString(in: child, keys: keys) {
                    return found
                }
            }
        }
        return nil
    }
}
