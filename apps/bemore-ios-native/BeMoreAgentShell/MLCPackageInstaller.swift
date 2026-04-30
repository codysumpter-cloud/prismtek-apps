import Foundation

struct MLCPackageManifest {
    let displayName: String
    let repositoryID: String
    let repositoryBaseURL: URL
    let repositoryTreeAPIURL: URL
    let localFolderName: String
    let modelID: String
    let modelLib: String
    let fallbackFiles: [String]

    var localURL: URL {
        Paths.modelsDirectory.appendingPathComponent(localFolderName, isDirectory: true)
    }

    static let gemma4_E2B_IT_Q4F16_1 = MLCPackageManifest(
        displayName: "Gemma 4 E2B IT MLC",
        repositoryID: "welcoma/gemma-4-E2B-it-q4f16_1-MLC",
        repositoryBaseURL: URL(string: "https://huggingface.co/welcoma/gemma-4-E2B-it-q4f16_1-MLC/resolve/main/")!,
        repositoryTreeAPIURL: URL(string: "https://huggingface.co/api/models/welcoma/gemma-4-E2B-it-q4f16_1-MLC/tree/main")!,
        localFolderName: "gemma-4-E2B-it-q4f16_1-MLC",
        modelID: "gemma-4-E2B-it-q4f16_1-MLC",
        modelLib: "gemma-4-E2B-it-q4f16_1-MLC",
        fallbackFiles: [
            "mlc-chat-config.json",
            "tensor-cache.json",
            "tokenizer.json",
            "tokenizer.model",
            "tokenizer_config.json",
            "release-manifest.json"
        ] + (0...41).map { "params_shard_\($0).bin" }
    )
}

@MainActor
final class MLCPackageInstaller: ObservableObject {
    enum Phase: Equatable {
        case idle
        case resolvingManifest
        case downloading(file: String, completed: Int, total: Int, fraction: Double)
        case installed
        case failed(String)

        var progress: Double? {
            guard case .downloading(_, let completed, let total, let fraction) = self, total > 0 else { return nil }
            return min((Double(completed) + fraction) / Double(total), 1.0)
        }

        var label: String {
            switch self {
            case .idle:
                return "Ready to install"
            case .resolvingManifest:
                return "Finding package files"
            case .downloading(let file, let completed, let total, _):
                return "Downloading \(file) (\(completed + 1)/\(total))"
            case .installed:
                return "Installed"
            case .failed(let message):
                return message
            }
        }
    }

    @Published private(set) var phase: Phase = .idle

    private struct HuggingFaceTreeItem: Decodable {
        let path: String
        let type: String?
    }

    private let session: URLSession
    private let fileManager: FileManager

    init(session: URLSession = .shared, fileManager: FileManager = .default) {
        self.session = session
        self.fileManager = fileManager
    }

    func installGemmaPackage(into modelStore: ModelCatalogStore, activate: @escaping @MainActor (String) async -> Void) async {
        await install(MLCPackageManifest.gemma4_E2B_IT_Q4F16_1, into: modelStore, activate: activate)
    }

    func install(_ manifest: MLCPackageManifest, into modelStore: ModelCatalogStore, activate: @escaping @MainActor (String) async -> Void) async {
        do {
            try ensureEnoughDiskForGemmaPackage()
            phase = .resolvingManifest
            let packageFiles = try await resolvePackageFiles(for: manifest)

            let destinationRoot = manifest.localURL
            let tempRoot = Paths.modelsDirectory.appendingPathComponent(".\(manifest.localFolderName)-partial-\(UUID().uuidString)", isDirectory: true)
            if fileManager.fileExists(atPath: tempRoot.path) {
                try fileManager.removeItem(at: tempRoot)
            }
            try fileManager.createDirectory(at: tempRoot, withIntermediateDirectories: true)

            for (index, filename) in packageFiles.enumerated() {
                let sourceURL = manifest.repositoryBaseURL.appendingPathComponent(filename)
                let destinationURL = tempRoot.appendingPathComponent(filename)
                try fileManager.createDirectory(at: destinationURL.deletingLastPathComponent(), withIntermediateDirectories: true)
                try await downloadFile(from: sourceURL, to: destinationURL) { [weak self] fraction in
                    Task { @MainActor in
                        self?.phase = .downloading(file: filename, completed: index, total: packageFiles.count, fraction: fraction)
                    }
                }
            }

            try verifyPackage(at: tempRoot)

            if fileManager.fileExists(atPath: destinationRoot.path) {
                try fileManager.removeItem(at: destinationRoot)
            }
            try fileManager.moveItem(at: tempRoot, to: destinationRoot)
            try persistDescriptor(for: manifest)

            modelStore.refreshInstalledModels()
            phase = .installed
            await activate(manifest.localFolderName)
        } catch {
            phase = .failed((error as NSError).localizedDescription)
        }
    }

    private func resolvePackageFiles(for manifest: MLCPackageManifest) async throws -> [String] {
        let (data, response) = try await session.data(from: manifest.repositoryTreeAPIURL)
        if let http = response as? HTTPURLResponse, !(200...299).contains(http.statusCode) {
            return manifest.fallbackFiles
        }

        let decoded = try JSONDecoder().decode([HuggingFaceTreeItem].self, from: data)
        let files = decoded
            .filter { ($0.type ?? "file") == "file" }
            .map(\.path)
            .filter(Self.isMLCPackageFile)
            .sorted()

        return files.isEmpty ? manifest.fallbackFiles : files
    }

    private static func isMLCPackageFile(_ path: String) -> Bool {
        guard !path.contains("/") else { return false }
        return path == "mlc-chat-config.json" ||
            path == "tensor-cache.json" ||
            path == "tokenizer.json" ||
            path == "tokenizer.model" ||
            path == "tokenizer_config.json" ||
            path == "release-manifest.json" ||
            (path.hasPrefix("params_shard_") && path.hasSuffix(".bin"))
    }

    private func downloadFile(from sourceURL: URL, to destinationURL: URL, onProgress: @escaping @Sendable (Double) -> Void) async throws {
        let (asyncBytes, response) = try await session.bytes(from: sourceURL)
        if let http = response as? HTTPURLResponse, !(200...299).contains(http.statusCode) {
            throw NSError(
                domain: "MLCPackageInstaller",
                code: http.statusCode,
                userInfo: [NSLocalizedDescriptionKey: "Failed to download \(sourceURL.lastPathComponent) with HTTP \(http.statusCode)."]
            )
        }

        let expectedLength = max(response.expectedContentLength, 0)
        let tempURL = destinationURL.appendingPathExtension("download")
        if fileManager.fileExists(atPath: tempURL.path) {
            try fileManager.removeItem(at: tempURL)
        }
        fileManager.createFile(atPath: tempURL.path, contents: nil)
        let handle = try FileHandle(forWritingTo: tempURL)
        defer { try? handle.close() }

        var received: Int64 = 0
        var buffer = Data()
        buffer.reserveCapacity(256 * 1024)

        for try await byte in asyncBytes {
            buffer.append(byte)
            if buffer.count >= 256 * 1024 {
                handle.write(buffer)
                received += Int64(buffer.count)
                buffer.removeAll(keepingCapacity: true)
                if expectedLength > 0 {
                    onProgress(min(Double(received) / Double(expectedLength), 1.0))
                }
            }
        }

        if !buffer.isEmpty {
            handle.write(buffer)
            received += Int64(buffer.count)
        }
        try? handle.close()
        onProgress(1.0)
        try fileManager.moveItem(at: tempURL, to: destinationURL)
    }

    private func verifyPackage(at url: URL) throws {
        let required = ["mlc-chat-config.json", "tokenizer.json", "tokenizer.model", "tokenizer_config.json", "params_shard_0.bin"]
        for filename in required {
            let path = url.appendingPathComponent(filename).path
            guard fileManager.fileExists(atPath: path) else {
                throw NSError(
                    domain: "MLCPackageInstaller",
                    code: 1001,
                    userInfo: [NSLocalizedDescriptionKey: "Downloaded package is incomplete. Missing \(filename)."]
                )
            }
        }
    }

    private func persistDescriptor(for manifest: MLCPackageManifest) throws {
        var descriptors: [String: InstalledModelDescriptor] = [:]
        if let data = try? Data(contentsOf: Paths.installedModelMetadataFile),
           let decoded = try? JSONDecoder().decode([String: InstalledModelDescriptor].self, from: data) {
            descriptors = decoded
        }

        descriptors[manifest.localFolderName] = InstalledModelDescriptor(
            filename: manifest.localFolderName,
            displayName: manifest.displayName,
            modelID: manifest.modelID,
            modelLib: manifest.modelLib,
            checksumSHA256: nil
        )

        let data = try JSONEncoder().encode(descriptors)
        try data.write(to: Paths.installedModelMetadataFile, options: [.atomic])
    }

    private func ensureEnoughDiskForGemmaPackage() throws {
        let values = try Paths.modelsDirectory.resourceValues(forKeys: [.volumeAvailableCapacityForImportantUsageKey])
        if let available = values.volumeAvailableCapacityForImportantUsage, available < 3_500_000_000 {
            throw NSError(
                domain: "MLCPackageInstaller",
                code: 1002,
                userInfo: [NSLocalizedDescriptionKey: "Gemma 4 needs about 2.7 GB plus install room. Free at least 3.5 GB and try again."]
            )
        }
    }
}
