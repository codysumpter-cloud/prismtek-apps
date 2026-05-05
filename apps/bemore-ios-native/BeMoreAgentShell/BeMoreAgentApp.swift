import SwiftUI

#if canImport(MediaPipeTasksGenai)
import MediaPipeTasksGenai
#endif

@main
struct BeMoreAgentApp: App {
    @StateObject private var appState = AppState(engine: LocalBrainService(engine: OnDeviceLLMRouterEngine()))

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(appState)
                .task {
                    await appState.bootstrap()
                }
        }
    }
}

@MainActor
final class OnDeviceLLMRouterEngine: LocalLLMEngine {
    private let googleAIEdgeEngine = GoogleAIEdgeLLMEngine()
    private let mlcEngine = MLCBridgeEngine()
    private var activeEngine: LocalLLMEngine?

    var backendDisplayName: String {
        if googleAIEdgeEngine.supportsLocalModels {
            return googleAIEdgeEngine.backendDisplayName
        }
        if mlcEngine.supportsLocalModels {
            return mlcEngine.backendDisplayName
        }
        return "Stub runtime (Google AI Edge pending)"
    }

    var isRuntimeReady: Bool {
        activeEngine?.isRuntimeReady ?? false
    }

    var supportsLocalModels: Bool {
        googleAIEdgeEngine.supportsLocalModels || mlcEngine.supportsLocalModels
    }

    var requiresModelSelection: Bool { true }

    var runtimeRequirementMessage: String? {
        if supportsLocalModels { return nil }
        return "This build can import local model files, but it does not link Google AI Edge / MediaPipe GenAI or MLCSwift yet. Link the native runtime before activating local chat."
    }

    func bootstrap() async throws {
        try await googleAIEdgeEngine.bootstrap()
        try await mlcEngine.bootstrap()
    }

    func configureRuntime(_ config: EngineRuntimeConfig?) async throws {
        guard let config else {
            try await activeEngine?.unloadRuntime()
            activeEngine = nil
            return
        }

        let selectedEngine: LocalLLMEngine
        if GoogleAIEdgeLLMEngine.canLoad(config.modelURL) {
            selectedEngine = googleAIEdgeEngine
        } else {
            selectedEngine = mlcEngine
        }

        if activeEngine !== selectedEngine as AnyObject {
            try await activeEngine?.unloadRuntime()
            activeEngine = selectedEngine
        }

        try await selectedEngine.configureRuntime(config)
    }

    func generate(prompt: String, fileContexts: [WorkspaceFile], chatHistory: [ChatMessage], activeStack: CompiledStack?) async throws -> String {
        guard let activeEngine else {
            throw NSError(
                domain: "OnDeviceLLMRouterEngine",
                code: 1,
                userInfo: [NSLocalizedDescriptionKey: "Select and load a local model before generating."]
            )
        }
        return try await activeEngine.generate(prompt: prompt, fileContexts: fileContexts, chatHistory: chatHistory, activeStack: activeStack)
    }

    func cancelGeneration() async {
        await activeEngine?.cancelGeneration()
    }

    func unloadRuntime() async throws {
        try await activeEngine?.unloadRuntime()
        activeEngine = nil
    }
}

@MainActor
final class GoogleAIEdgeLLMEngine: LocalLLMEngine {
    private var runtimeConfig: EngineRuntimeConfig?

    #if canImport(MediaPipeTasksGenai)
    private var llmInference: LlmInference?
    #endif

    static func canLoad(_ url: URL) -> Bool {
        ["task", "bin"].contains(url.pathExtension.lowercased())
    }

    var backendDisplayName: String {
        #if canImport(MediaPipeTasksGenai)
        return "Google AI Edge / MediaPipe GenAI"
        #else
        return "Stub runtime (Google AI Edge pending)"
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

    var runtimeRequirementMessage: String? {
        supportsLocalModels ? nil : "Link MediaPipeTasksGenAI / MediaPipeTasksGenAIC to activate .task and .bin local model files."
    }

    func bootstrap() async throws {}

    func configureRuntime(_ config: EngineRuntimeConfig?) async throws {
        runtimeConfig = config

        #if canImport(MediaPipeTasksGenai)
        guard let config else {
            llmInference = nil
            return
        }

        guard Self.canLoad(config.modelURL) else {
            throw NSError(
                domain: "GoogleAIEdgeLLMEngine",
                code: 10,
                userInfo: [NSLocalizedDescriptionKey: "Google AI Edge route expects a .task or .bin model artifact."]
            )
        }

        let options = LlmInferenceOptions()
        options.baseOptions.modelPath = config.modelURL.path
        options.maxTokens = 1024
        options.topk = 40
        options.temperature = 0.8
        options.randomSeed = 101
        llmInference = try LlmInference(options: options)
        #else
        throw NSError(
            domain: "GoogleAIEdgeLLMEngine",
            code: 11,
            userInfo: [NSLocalizedDescriptionKey: runtimeRequirementMessage ?? "Google AI Edge runtime is not linked in this build."]
        )
        #endif
    }

    func generate(prompt: String, fileContexts: [WorkspaceFile], chatHistory: [ChatMessage], activeStack: CompiledStack?) async throws -> String {
        let finalPrompt = buildContextPrefix(fileContexts: fileContexts, chatHistory: chatHistory, activeStack: activeStack) + prompt

        #if canImport(MediaPipeTasksGenai)
        guard let llmInference else {
            throw NSError(
                domain: "GoogleAIEdgeLLMEngine",
                code: 12,
                userInfo: [NSLocalizedDescriptionKey: "Load a .task or .bin model before generating."]
            )
        }

        return try llmInference.generateResponse(inputText: finalPrompt)
            .trimmingCharacters(in: .whitespacesAndNewlines)
        #else
        let filenames = fileContexts.map(\.filename).joined(separator: ", ")
        let selected = runtimeConfig?.modelID ?? "none"
        let attachedFiles = filenames.isEmpty ? "none" : filenames
        return """
        [BMO Agent — Stub Response]

        Your prompt: \(prompt)
        Selected model: \(selected)
        Attached files: \(attachedFiles)
        History: \(chatHistory.count) messages

        This is a simulated response. Link MediaPipeTasksGenAI / MediaPipeTasksGenAIC to run .task or .bin local model artifacts fully on-device.
        """
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
