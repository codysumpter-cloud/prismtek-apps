import Foundation

enum BundledModelCatalog {
    private static let bundleRootName = "BundledModels"
    private static let manifest = MLCPackageManifest.gemma4_E2B_IT_Q4F16_1

    static var bundledRecommendedModelURL: URL? {
        Bundle.main.url(forResource: manifest.localFolderName, withExtension: nil, subdirectory: bundleRootName)
    }

    static var hasBundledRecommendedModel: Bool {
        guard let url = bundledRecommendedModelURL else { return false }
        return isValidPackage(at: url)
    }

    @MainActor
    static func installBundledRecommendedModelIfAvailable(into modelStore: ModelCatalogStore) {
        guard let sourceURL = bundledRecommendedModelURL, isValidPackage(at: sourceURL) else { return }
        let destinationURL = Paths.modelsDirectory.appendingPathComponent(manifest.localFolderName, isDirectory: true)
        let fileManager = FileManager.default

        do {
            if shouldReplace(destinationURL, target: sourceURL) {
                if fileManager.fileExists(atPath: destinationURL.path) || isSymbolicLink(destinationURL) {
                    try fileManager.removeItem(at: destinationURL)
                }
                do {
                    try fileManager.createSymbolicLink(at: destinationURL, withDestinationURL: sourceURL)
                } catch {
                    try fileManager.copyItem(at: sourceURL, to: destinationURL)
                }
            }
            try writeDescriptor()
            modelStore.load()
        } catch {
            modelStore.errorMessage = "Bundled model install failed: \(error.localizedDescription)"
        }
    }

    private static func shouldReplace(_ destination: URL, target: URL) -> Bool {
        let fileManager = FileManager.default
        if let linkedTarget = try? fileManager.destinationOfSymbolicLink(atPath: destination.path) {
            return URL(fileURLWithPath: linkedTarget).path != target.path
        }
        var isDirectory: ObjCBool = false
        guard fileManager.fileExists(atPath: destination.path, isDirectory: &isDirectory) else { return true }
        guard isDirectory.boolValue else { return true }
        return !isValidPackage(at: destination)
    }

    private static func isSymbolicLink(_ url: URL) -> Bool {
        (try? url.resourceValues(forKeys: [.isSymbolicLinkKey]).isSymbolicLink) == true
    }

    private static func isValidPackage(at url: URL) -> Bool {
        ["mlc-chat-config.json", "tokenizer.json", "tokenizer.model", "tokenizer_config.json", "params_shard_0.bin"].allSatisfy { marker in
            FileManager.default.fileExists(atPath: url.appendingPathComponent(marker).path)
        }
    }

    private static func writeDescriptor() throws {
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
}
