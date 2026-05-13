import Foundation

enum LiteRTLMAvailability {
    static let isAvailable = false

    static func accepts(_ model: InstalledModel) -> Bool {
        model.localURL.pathExtension.lowercased() == "litertlm" && isAvailable
    }
}
