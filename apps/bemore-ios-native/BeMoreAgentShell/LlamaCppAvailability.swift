import Foundation

enum LlamaCppAvailability {
    static let backendName = "llama.cpp"
    static let artifactExtension = "gguf"

    static var isAvailable: Bool {
        #if canImport(SwiftLlama)
        true
        #else
        false
        #endif
    }

    static let requirementMessage = "This model file needs the bundled llama.cpp iOS runtime before it can be used on device."

    static func accepts(_ model: InstalledModel) -> Bool {
        model.localURL.pathExtension.lowercased() == artifactExtension && isAvailable
    }
}
