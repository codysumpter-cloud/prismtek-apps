import Foundation

#if canImport(SwiftLlama)
import SwiftLlama
#endif

@MainActor
final class LlamaCppModelEngine: LocalLLMEngine {
    private var runtimeConfig: EngineRuntimeConfig?

    #if canImport(SwiftLlama)
    private var llamaService: LlamaService?
    #endif

    static func canLoad(_ url: URL) -> Bool {
        url.pathExtension.lowercased() == LlamaCppAvailability.artifactExtension
    }

    var backendDisplayName: String {
        #if canImport(SwiftLlama)
        return LlamaCppAvailability.backendName
        #else
        return "Stub runtime"
        #endif
    }

    var isRuntimeReady: Bool {
        #if canImport(SwiftLlama)
        return llamaService != nil
        #else
        return false
        #endif
    }

    var supportsLocalModels: Bool {
        #if canImport(SwiftLlama)
        return true
        #else
        return false
        #endif
    }

    var requiresModelSelection: Bool { true }

    var runtimeRequirementMessage: String? {
        supportsLocalModels ? nil : LlamaCppAvailability.requirementMessage
    }

    func bootstrap() async throws {}

    func configureRuntime(_ config: EngineRuntimeConfig?) async throws {
        runtimeConfig = config

        #if canImport(SwiftLlama)
        guard let config else {
            llamaService = nil
            return
        }
        guard Self.canLoad(config.modelURL) else {
            throw NSError(domain: "LlamaCppModelEngine", code: 20, userInfo: [NSLocalizedDescriptionKey: "This route expects a GGUF model artifact."])
        }
        guard FileManager.default.fileExists(atPath: config.modelURL.path) else {
            throw NSError(domain: "LlamaCppModelEngine", code: 21, userInfo: [NSLocalizedDescriptionKey: "The selected model file is missing. Reinstall or import it again."])
        }

        let runtimeConfig = LlamaConfig(batchSize: 256, maxTokenCount: 2048, useGPU: true)
        llamaService = LlamaService(modelUrl: config.modelURL, config: runtimeConfig)
        #else
        throw NSError(domain: "LlamaCppModelEngine", code: 22, userInfo: [NSLocalizedDescriptionKey: runtimeRequirementMessage ?? "The local runtime is not linked in this build."])
        #endif
    }

    func generate(prompt: String, fileContexts: [WorkspaceFile], chatHistory: [ChatMessage], activeStack: CompiledStack?) async throws -> String {
        let contextPrefix = buildContextPrefix(fileContexts: fileContexts, chatHistory: chatHistory, activeStack: activeStack)

        #if canImport(SwiftLlama)
        guard let llamaService else {
            throw NSError(domain: "LlamaCppModelEngine", code: 23, userInfo: [NSLocalizedDescriptionKey: "Load a model before generating."])
        }

        var messages: [LlamaChatMessage] = []
        if !contextPrefix.isEmpty {
            messages.append(LlamaChatMessage(role: .system, content: contextPrefix))
        }
        for message in chatHistory.suffix(12) {
            messages.append(LlamaChatMessage(role: llamaRole(for: message.role), content: message.content))
        }
        messages.append(LlamaChatMessage(role: .user, content: prompt))

        let sampling = LlamaSamplingConfig(
            temperature: 0.7,
            seed: 101,
            topP: 0.9,
            topK: 40
        )
        let output = try await llamaService.respond(to: messages, samplingConfig: sampling)
        return output.trimmingCharacters(in: .whitespacesAndNewlines)
        #else
        throw NSError(domain: "LlamaCppModelEngine", code: 24, userInfo: [NSLocalizedDescriptionKey: runtimeRequirementMessage ?? "The local runtime is not linked in this build."])
        #endif
    }

    func cancelGeneration() async {
        #if canImport(SwiftLlama)
        await llamaService?.stopCompletion()
        #endif
    }

    func unloadRuntime() async throws {
        runtimeConfig = nil
        #if canImport(SwiftLlama)
        await llamaService?.stopCompletion()
        llamaService = nil
        #endif
    }

    #if canImport(SwiftLlama)
    private func llamaRole(for role: ChatMessage.Role) -> LlamaChatMessage.Role {
        switch role.rawValue.lowercased() {
        case "assistant":
            return .assistant
        case "user":
            return .user
        default:
            return .system
        }
    }
    #endif

    private func buildContextPrefix(fileContexts: [WorkspaceFile], chatHistory: [ChatMessage], activeStack: CompiledStack?) -> String {
        var parts: [String] = []

        if let activeStack {
            parts.append("STACK SUMMARY:\n\(activeStack.summary)\nMODEL STRATEGY:\n\(activeStack.recommendedModelStrategy)\nWORKSPACE GUIDANCE:\n\(activeStack.workspaceGuidance)\nSYSTEM PROMPT:\n\(activeStack.chatSystemPrompt)")
        }

        if !fileContexts.isEmpty {
            let rendered = fileContexts.map { file -> String in
                let text = (try? String(contentsOf: file.localURL, encoding: .utf8)) ?? "[binary or unreadable file]"
                return "FILE: \(file.filename)\n\(text.prefix(8000))"
            }
            parts.append(rendered.joined(separator: "\n\n"))
        }

        if !chatHistory.isEmpty {
            let history = chatHistory.suffix(12).map { msg in
                "\(msg.role.rawValue.capitalized): \(msg.content)"
            }.joined(separator: "\n\n")
            parts.append("RECENT CHAT HISTORY:\n\(history)")
        }

        let prefix = parts.joined(separator: "\n\n")
        return prefix.isEmpty ? "" : prefix + "\n\n"
    }
}
