import Foundation

#if canImport(MediaPipeTasksGenai)
import MediaPipeTasksGenai
#endif

@MainActor
final class GoogleModelFileEngine: LocalLLMEngine {
    private var runtimeConfig: EngineRuntimeConfig?

    #if canImport(MediaPipeTasksGenai)
    private var llmInference: LlmInference?
    #endif

    static func canLoad(_ url: URL) -> Bool {
        ["task", "bin"].contains(url.pathExtension.lowercased())
    }

    var backendDisplayName: String {
        #if canImport(MediaPipeTasksGenai)
        return "MediaPipe GenAI"
        #else
        return "Stub runtime (MediaPipe GenAI pending)"
        #endif
    }

    var isRuntimeReady: Bool {
        #if canImport(MediaPipeTasksGenai)
        return llmInference != nil
        #else
        return false
        #endif
    }

    var supportsLocalModels: Bool {
        #if canImport(MediaPipeTasksGenai)
        return true
        #else
        return false
        #endif
    }

    var requiresModelSelection: Bool { true }
    var runtimeRequirementMessage: String? { supportsLocalModels ? nil : "Link MediaPipeTasksGenai to activate .task and .bin model files." }

    func bootstrap() async throws {}

    func configureRuntime(_ config: EngineRuntimeConfig?) async throws {
        runtimeConfig = config

        #if canImport(MediaPipeTasksGenai)
        guard let config else {
            llmInference = nil
            return
        }
        guard Self.canLoad(config.modelURL) else {
            throw NSError(domain: "GoogleModelFileEngine", code: 10, userInfo: [NSLocalizedDescriptionKey: "This route expects a .task or .bin model artifact."])
        }

        let options = LlmInferenceOptions()
        options.baseOptions.modelPath = config.modelURL.path
        options.maxTokens = 1024
        options.topk = 40
        options.temperature = 0.8
        options.randomSeed = 101
        llmInference = try LlmInference(options: options)
        #else
        throw NSError(domain: "GoogleModelFileEngine", code: 11, userInfo: [NSLocalizedDescriptionKey: runtimeRequirementMessage ?? "Native local runtime is not linked in this build."])
        #endif
    }

    func generate(prompt: String, fileContexts: [WorkspaceFile], chatHistory: [ChatMessage], activeStack: CompiledStack?) async throws -> String {
        let finalPrompt = buildContextPrefix(fileContexts: fileContexts, chatHistory: chatHistory, activeStack: activeStack) + prompt

        #if canImport(MediaPipeTasksGenai)
        guard let llmInference else {
            throw NSError(domain: "GoogleModelFileEngine", code: 12, userInfo: [NSLocalizedDescriptionKey: "Load a .task or .bin model before generating."])
        }
        return try llmInference.generateResponse(inputText: finalPrompt).trimmingCharacters(in: .whitespacesAndNewlines)
        #else
        throw NSError(domain: "GoogleModelFileEngine", code: 13, userInfo: [NSLocalizedDescriptionKey: runtimeRequirementMessage ?? "Native local runtime is not linked in this build."])
        #endif
    }

    func cancelGeneration() async {}

    func unloadRuntime() async throws {
        runtimeConfig = nil
        #if canImport(MediaPipeTasksGenai)
        llmInference = nil
        #endif
    }

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
            let history = chatHistory.map { msg in
                "\(msg.role.rawValue.capitalized): \(msg.content)"
            }.joined(separator: "\n\n")
            parts.append("CHAT HISTORY:\n\(history)")
        }

        let prefix = parts.joined(separator: "\n\n")
        return prefix.isEmpty ? "" : prefix + "\n\n"
    }
}
