import SwiftUI

@main
struct BeMoreAgentApp: App {
    @StateObject private var appState = AppState(engine: LocalBrainService(engine: OnDeviceModelRouterEngine()))

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
final class OnDeviceModelRouterEngine: LocalLLMEngine {
    private enum Route {
        case llama
        case google
        case mlc
    }

    private let llamaEngine = LlamaCppModelEngine()
    private let googleEngine = GoogleModelFileEngine()
    private let mlcEngine = MLCBridgeEngine()
    private var activeRoute: Route?

    private var activeEngine: LocalLLMEngine? {
        switch activeRoute {
        case .llama:
            return llamaEngine
        case .google:
            return googleEngine
        case .mlc:
            return mlcEngine
        case nil:
            return nil
        }
    }

    var backendDisplayName: String {
        if llamaEngine.supportsLocalModels { return llamaEngine.backendDisplayName }
        if googleEngine.supportsLocalModels { return googleEngine.backendDisplayName }
        if mlcEngine.supportsLocalModels { return mlcEngine.backendDisplayName }
        return "Stub runtime (native local runtime pending)"
    }

    var isRuntimeReady: Bool { activeEngine?.isRuntimeReady ?? false }
    var supportsLocalModels: Bool { llamaEngine.supportsLocalModels || googleEngine.supportsLocalModels || mlcEngine.supportsLocalModels }
    var requiresModelSelection: Bool { true }

    var runtimeRequirementMessage: String? {
        supportsLocalModels ? nil : "This build can import local model files, but it does not link the native local runtime yet."
    }

    func bootstrap() async throws {
        try await llamaEngine.bootstrap()
        try await googleEngine.bootstrap()
        try await mlcEngine.bootstrap()
    }

    func configureRuntime(_ config: EngineRuntimeConfig?) async throws {
        guard let config else {
            try await activeEngine?.unloadRuntime()
            activeRoute = nil
            return
        }

        let nextRoute: Route
        if LlamaCppModelEngine.canLoad(config.modelURL) {
            nextRoute = .llama
        } else if GoogleModelFileEngine.canLoad(config.modelURL) {
            nextRoute = .google
        } else {
            nextRoute = .mlc
        }

        if activeRoute != nextRoute {
            try await activeEngine?.unloadRuntime()
            activeRoute = nextRoute
        }

        guard let activeEngine else {
            throw NSError(domain: "OnDeviceModelRouterEngine", code: 1, userInfo: [NSLocalizedDescriptionKey: "Could not select a runtime for this model artifact."])
        }
        try await activeEngine.configureRuntime(config)
    }

    func generate(prompt: String, fileContexts: [WorkspaceFile], chatHistory: [ChatMessage], activeStack: CompiledStack?) async throws -> String {
        guard let activeEngine else {
            throw NSError(domain: "OnDeviceModelRouterEngine", code: 2, userInfo: [NSLocalizedDescriptionKey: "Select and load a local model before generating."])
        }
        return try await activeEngine.generate(prompt: prompt, fileContexts: fileContexts, chatHistory: chatHistory, activeStack: activeStack)
    }

    func cancelGeneration() async {
        await activeEngine?.cancelGeneration()
    }

    func unloadRuntime() async throws {
        try await activeEngine?.unloadRuntime()
        activeRoute = nil
    }
}
