import Foundation

enum LiteRTLMAvailability {
    static let isAvailable = false

    static let backendName = "LiteRT-LM"
    static let artifactExtension = "litertlm"

    static let requirementMessage = "Gemma 4 E2B is installed as a LiteRT-LM .litertlm artifact, but this build has not linked the native LiteRT-LM iOS bridge yet. Use a cloud route for live chat until a runtime-linked build ships."

    static func accepts(_ model: InstalledModel) -> Bool {
        model.localURL.pathExtension.lowercased() == artifactExtension && isAvailable
    }

    static func isLiteRTLMArtifact(_ url: URL) -> Bool {
        url.pathExtension.lowercased() == artifactExtension
    }
}
