import Foundation

extension Paths {
    static var pixelLabPreviewRecordsFile: URL {
        stateDirectory.appendingPathComponent("pixellab-preview-records.json")
    }

    static var pixelLabPreviewAssetDirectory: URL {
        stateDirectory.appendingPathComponent("pixellab-previews", isDirectory: true)
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
    var localAssetPath: String?
    var status: PixelLabPreviewStatus
    var errorMessage: String?
    var updatedAt: Date

    var hasLocalAsset: Bool {
        guard let localAssetPath else { return false }
        return FileManager.default.fileExists(atPath: localAssetPath)
    }
}

enum PixelLabPreviewService {
    static var client = PixelLabClient()

    static func record(for requestKey: String) -> PixelLabPreviewRecord? {
        guard let data = try? Data(contentsOf: Paths.pixelLabPreviewRecordsFile),
              let records = try? JSONDecoder().decode([String: PixelLabPreviewRecord].self, from: data) else {
            return nil
        }
        guard var record = records[requestKey] else { return nil }
        if record.hasLocalAsset == false {
            record.localAssetPath = nil
        }
        return record
    }

    static func sync(
        spec: BuddyAppearancePreviewSpec,
        accessToken: String
    ) async -> PixelLabPreviewRecord {
        if let existing = record(for: spec.pixelRequestKey ?? ""), existing.status == .ready, existing.hasLocalAsset {
            return existing
        }

        guard let requestKey = spec.pixelRequestKey else {
            return PixelLabPreviewRecord(
                requestKey: "",
                buddyName: spec.buddyName,
                previewURL: nil,
                localAssetPath: nil,
                status: .failed,
                errorMessage: "Pixel preview key missing.",
                updatedAt: .now
            )
        }

        do {
            let response = try await client.generatePreview(spec: spec, accessToken: accessToken)
            let imageData = try await resolvedImageData(from: response)
            let assetURL = try saveImageData(imageData, requestKey: requestKey)
            let record = PixelLabPreviewRecord(
                requestKey: requestKey,
                buddyName: spec.buddyName,
                previewURL: response.previewURL?.absoluteString,
                localAssetPath: assetURL.path,
                status: .ready,
                errorMessage: nil,
                updatedAt: .now
            )
            save(record)
            return record
        } catch let PixelLabClientError.requestFailed(status, snippet) {
            logFailure(status: status, snippet: snippet, spec: spec)
            return failedRecord(for: requestKey, buddyName: spec.buddyName, existing: record(for: requestKey), message: "Pixel preview unavailable right now. Showing a local fallback.")
        } catch let PixelLabClientError.decodeFailure(snippet) {
            logFailure(status: 200, snippet: snippet, spec: spec)
            return failedRecord(for: requestKey, buddyName: spec.buddyName, existing: record(for: requestKey), message: "Pixel preview format changed. Showing a local fallback.")
        } catch {
            logFailure(status: 0, snippet: error.localizedDescription, spec: spec)
            return failedRecord(for: requestKey, buddyName: spec.buddyName, existing: record(for: requestKey), message: "Pixel preview failed. Showing a local fallback.")
        }
    }

    private static func resolvedImageData(from response: PixelLabGenerateResponse) async throws -> Data {
        if let imageData = response.imageData {
            return imageData
        }
        if let previewURL = response.previewURL {
            return try await client.downloadImage(from: previewURL)
        }
        throw PixelLabClientError.missingPreview
    }

    private static func saveImageData(_ data: Data, requestKey: String) throws -> URL {
        try FileManager.default.createDirectory(at: Paths.pixelLabPreviewAssetDirectory, withIntermediateDirectories: true)
        let filename = requestKey
            .replacingOccurrences(of: "pixellab:", with: "")
            .replacingOccurrences(of: "|", with: "-")
        let url = Paths.pixelLabPreviewAssetDirectory.appendingPathComponent("\(filename).png")
        try data.write(to: url, options: [.atomic])
        return url
    }

    private static func failedRecord(
        for requestKey: String,
        buddyName: String,
        existing: PixelLabPreviewRecord?,
        message: String
    ) -> PixelLabPreviewRecord {
        let record = PixelLabPreviewRecord(
            requestKey: requestKey,
            buddyName: buddyName,
            previewURL: existing?.previewURL,
            localAssetPath: existing?.hasLocalAsset == true ? existing?.localAssetPath : nil,
            status: existing?.hasLocalAsset == true ? .ready : .failed,
            errorMessage: message,
            updatedAt: .now
        )
        save(record)
        return record
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

    private static func logFailure(status: Int, snippet: String?, spec: BuddyAppearancePreviewSpec) {
        let redactedSnippet = (snippet ?? "n/a")
            .replacingOccurrences(of: "\n", with: " ")
            .prefix(220)
        print(
            "[PixelLabPreview] status=\(status) signature=\(spec.requestSignature) archetype=\(spec.archetypeID) palette=\(spec.paletteID) snippet=\(redactedSnippet)"
        )
    }
}
