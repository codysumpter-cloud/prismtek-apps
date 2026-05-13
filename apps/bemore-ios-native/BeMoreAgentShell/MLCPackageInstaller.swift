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
        Paths.modelsDirectory.appendingPathComponent(localFolderName, isDirectory: false)
    }

    static let gemma4_E2B_IT_Q4F16_1 = MLCPackageManifest(
        displayName: "Gemma 4 E2B IT LiteRT-LM",
        repositoryID: "litert-community/gemma-4-E2B-it-litert-lm",
        repositoryBaseURL: URL(string: "https://huggingface.co/litert-community/gemma-4-E2B-it-litert-lm/resolve/main/")!,
        repositoryTreeAPIURL: URL(string: "https://huggingface.co/api/models/litert-community/gemma-4-E2B-it-litert-lm/tree/main")!,
        localFolderName: "gemma-4-E2B-it.litertlm",
        modelID: "gemma-4-E2B-it",
        modelLib: "litert-lm",
        fallbackFiles: ["gemma-4-E2B-it.litertlm"]
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
                return "Finding LiteRT-LM package"
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
            guard let primaryFilename = packageFiles.first else {
                throw NSError(domain: "LiteRTLMInstaller", code: 1000, userInfo: [NSLocalizedDescriptionKey: "No LiteRT-LM artifact was found for Gemma 4 E2B."])
            }

            let destinationURL = manifest.localURL
            let tempRoot = Paths.modelsDirectory.appendingPathComponent(".\(manifest.modelID)-litertlm-partial-\(UUID().uuidString)", isDirectory: true)
            let stagedURL = tempRoot.appendingPathComponent(primaryFilename, isDirectory: false)

            if fileManager.fileExists(atPath: tempRoot.path) {
                try fileManager.removeItem(at: tempRoot)
            }
            try fileManager.createDirectory(at: tempRoot, withIntermediateDirectories: true)

            let sourceURL = manifest.repositoryBaseURL.appendingPathComponent(primaryFilename)
            try await downloadFile(from: sourceURL, to: stagedURL) { [weak self] fraction in
                Task { @MainActor in
                    self?.phase = .downloading(file: primaryFilename, completed: 0, total: 1, fraction: fraction)
                }
            }

            try verifyPackage(at: stagedURL)

            if fileManager.fileExists(atPath: destinationURL.path) {
                try fileManager.removeItem(at: destinationURL)
            }
            try fileManager.moveItem(at: stagedURL, to: destinationURL)
            try? fileManager.removeItem(at: tempRoot)
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
            .filter(Self.isLiteRTLMFile)
            .sorted()

        return files.isEmpty ? manifest.fallbackFiles : files
    }

    private static func isLiteRTLMFile(_ path: String) -> Bool {
        !path.contains("/") && path.lowercased().hasSuffix(".litertlm")
    }

    private func downloadFile(from sourceURL: URL, to destinationURL: URL, onProgress: @escaping @Sendable (Double) -> Void) async throws {
        let (asyncBytes, response) = try await session.bytes(from: sourceURL)
        if let http = response as? HTTPURLResponse, !(200...299).contains(http.statusCode) {
            throw NSError(
                domain: "LiteRTLMInstaller",
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
        guard url.pathExtension.lowercased() == "litertlm", fileManager.fileExists(atPath: url.path) else {
            throw NSError(
                domain: "LiteRTLMInstaller",
                code: 1001,
                userInfo: [NSLocalizedDescriptionKey: "Downloaded package is not a LiteRT-LM .litertlm artifact."]
            )
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
        if let available = values.volumeAvailableCapacityForImportantUsage, available < 3_300_000_000 {
            throw NSError(
                domain: "LiteRTLMInstaller",
                code: 1002,
                userInfo: [NSLocalizedDescriptionKey: "Gemma 4 E2B LiteRT-LM needs about 2.6 GB plus install room. Free at least 3.3 GB and try again."]
            )
        }
    }
}
