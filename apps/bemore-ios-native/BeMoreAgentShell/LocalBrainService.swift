import Foundation

#if canImport(UIKit)
import UIKit
#endif

enum LocalBrainLifecycleState: String, Codable, Hashable {
    case idle
    case verifying
    case loading
    case ready
    case generating
    case unloading
    case failed

    var operatorLabel: String {
        switch self {
        case .idle: return "Idle"
        case .verifying: return "Verifying model"
        case .loading: return "Loading model"
        case .ready: return "Ready"
        case .generating: return "Generating"
        case .unloading: return "Unloading"
        case .failed: return "Failed"
        }
    }
}

enum LocalBrainFailureKind: String, Codable, Hashable {
    case missingModelAsset
    case invalidModelAsset
    case runtimeUnavailable
    case emptyGeneration
    case cancelled
    case memoryPressure
    case loadFailed
    case generationFailed
    case unknown
}

enum LocalBrainEventKind: String, Codable, Hashable {
    case bootstrap
    case modelSelectionChanged
    case modelPathResolved
    case fileExistenceVerified
    case checksumComputed
    case loadStarted
    case loadFinished
    case generationStarted
    case firstTokenReceived
    case streamFinished
    case cancelRequested
    case unloadRequested
    case unloadFinished
    case memoryWarningReceived
    case failure
}

struct LocalBrainEvent: Identifiable, Codable, Hashable {
    let id: UUID
    let kind: LocalBrainEventKind
    let createdAt: Date
    let message: String
    let metadata: [String: String]

    init(
        id: UUID = UUID(),
        kind: LocalBrainEventKind,
        createdAt: Date = .now,
        message: String,
        metadata: [String: String] = [:]
    ) {
        self.id = id
        self.kind = kind
        self.createdAt = createdAt
        self.message = message
        self.metadata = metadata
    }
}

@MainActor
final class LocalBrainService: ObservableObject, LocalLLMEngine {
    @Published private(set) var lifecycleState: LocalBrainLifecycleState = .idle
    @Published private(set) var events: [LocalBrainEvent] = []
    @Published private(set) var lastFailureKind: LocalBrainFailureKind?
    @Published private(set) var lastUserVisibleError: String?
    @Published private(set) var currentModelSummary: String?

    private let engine: LocalLLMEngine
    private var activeConfig: EngineRuntimeConfig?
    private var generationTask: Task<String, Error>?
    private var memoryWarningObserver: NSObjectProtocol?

    init(engine: LocalLLMEngine) {
        self.engine = engine

        if let bridge = engine as? MLCBridgeEngine {
            bridge.eventHook = { [weak self] event in
                Task { @MainActor in
                    self?.handleBridgeEvent(event)
                }
            }
        }
    }

    deinit {
        #if canImport(UIKit)
        if let memoryWarningObserver {
            NotificationCenter.default.removeObserver(memoryWarningObserver)
        }
        #endif
    }

    var backendDisplayName: String { engine.backendDisplayName }
    var isRuntimeReady: Bool { lifecycleState == .ready || lifecycleState == .generating }
    var supportsLocalModels: Bool { engine.supportsLocalModels }
    var requiresModelSelection: Bool { engine.requiresModelSelection }
    var runtimeRequirementMessage: String? { engine.runtimeRequirementMessage }

    func bootstrap() async throws {
        loadPersistedEvents()
        appendEvent(.bootstrap, message: "Local brain bootstrap started.")
        registerMemoryPressureObserverIfNeeded()
        try await engine.bootstrap()
    }

    func configureRuntime(_ config: EngineRuntimeConfig?) async throws {
        if let config {
            currentModelSummary = config.modelID.isEmpty ? config.modelURL.lastPathComponent : config.modelID
            appendEvent(
                .modelSelectionChanged,
                message: "Selected local model changed.",
                metadata: [
                    "modelID": config.modelID,
                    "filename": config.modelURL.lastPathComponent
                ]
            )

            guard supportsLocalModels else {
                throw classifiedError(
                    .runtimeUnavailable,
                    message: runtimeRequirementMessage ?? "This build does not include the packaged on-device runtime."
                )
            }

            lifecycleState = .verifying
            appendEvent(
                .modelPathResolved,
                message: "Resolved local model path.",
                metadata: [
                    "path": config.modelURL.path,
                    "modelLib": config.modelLib
                ]
            )

            let fileExists = FileManager.default.fileExists(atPath: config.modelURL.path)
            guard fileExists else {
                throw classifiedError(
                    .missingModelAsset,
                    message: "The selected model file is missing from Application Support."
                )
            }

            appendEvent(
                .fileExistenceVerified,
                message: "Verified that the selected model file exists.",
                metadata: ["path": config.modelURL.path]
            )

            if let checksum = ModelCatalogStore.sha256Hex(for: config.modelURL) {
                appendEvent(
                    .checksumComputed,
                    message: "Computed model checksum.",
                    metadata: ["sha256": checksum]
                )
            }

            lifecycleState = .loading
            appendEvent(.loadStarted, message: "Starting model load.", metadata: ["modelID": currentModelSummary ?? "unknown"])
            do {
                try await engine.configureRuntime(config)
                activeConfig = config
                lifecycleState = .ready
                lastFailureKind = nil
                lastUserVisibleError = nil
                appendEvent(.loadFinished, message: "Model load finished.", metadata: ["modelID": currentModelSummary ?? "unknown"])
            } catch {
                lifecycleState = .failed
                throw classify(error, fallback: .loadFailed)
            }
            return
        }

        lifecycleState = .unloading
        appendEvent(.unloadRequested, message: "Runtime unload requested.")
        do {
            try await engine.unloadRuntime()
            activeConfig = nil
            generationTask = nil
            lifecycleState = .idle
            appendEvent(.unloadFinished, message: "Runtime unload finished.")
        } catch {
            lifecycleState = .failed
            throw classify(error, fallback: .loadFailed)
        }
    }

    func generate(prompt: String, fileContexts: [WorkspaceFile], chatHistory: [ChatMessage], activeStack: CompiledStack?) async throws -> String {
        guard activeConfig != nil else {
            throw classifiedError(.missingModelAsset, message: "Choose an installed model before starting on-device generation.")
        }

        lifecycleState = .generating
        appendEvent(.generationStarted, message: "Local generation started.", metadata: ["promptLength": "\(prompt.count)"])

        let task = Task<String, Error> {
            try Task.checkCancellation()
            return try await engine.generate(prompt: prompt, fileContexts: fileContexts, chatHistory: chatHistory, activeStack: activeStack)
        }
        generationTask = task

        do {
            let output = try await task.value.trimmingCharacters(in: .whitespacesAndNewlines)
            generationTask = nil

            guard !output.isEmpty else {
                lifecycleState = .failed
                throw classifiedError(.emptyGeneration, message: "The local model returned an empty response.")
            }

            lifecycleState = .ready
            appendEvent(.streamFinished, message: "Local generation finished.", metadata: ["outputLength": "\(output.count)"])
            return output
        } catch is CancellationError {
            generationTask = nil
            lifecycleState = activeConfig == nil ? .idle : .ready
            throw classifiedError(.cancelled, message: "The local generation was cancelled.")
        } catch {
            generationTask = nil
            lifecycleState = .failed
            throw classify(error, fallback: .generationFailed)
        }
    }

    func cancelGeneration() async {
        guard let generationTask else { return }
        appendEvent(.cancelRequested, message: "Local generation cancellation requested.")
        generationTask.cancel()
        await engine.cancelGeneration()
    }

    func unloadRuntime() async throws {
        try await configureRuntime(nil)
    }

    private func registerMemoryPressureObserverIfNeeded() {
        #if canImport(UIKit)
        guard memoryWarningObserver == nil else { return }
        memoryWarningObserver = NotificationCenter.default.addObserver(
            forName: UIApplication.didReceiveMemoryWarningNotification,
            object: nil,
            queue: .main
        ) { [weak self] _ in
            guard let self else { return }
            Task { @MainActor in
                self.appendEvent(.memoryWarningReceived, message: "Received iOS memory warning; unloading local runtime.")
                self.lastFailureKind = .memoryPressure
                self.lastUserVisibleError = "The local model was unloaded after an iPhone memory warning."
                self.lifecycleState = .unloading
                try? await self.engine.unloadRuntime()
                self.activeConfig = nil
                self.lifecycleState = .idle
                self.appendEvent(.unloadFinished, message: "Runtime unloaded after memory pressure.")
            }
        }
        #endif
    }

    private func handleBridgeEvent(_ event: LocalEngineHookEvent) {
        switch event {
        case .firstToken:
            appendEvent(.firstTokenReceived, message: "First token received from local runtime.")
        case .streamFinished(let outputLength):
            appendEvent(.streamFinished, message: "Local runtime stream finished.", metadata: ["outputLength": "\(outputLength)"])
        }
    }

    private func classifiedError(_ kind: LocalBrainFailureKind, message: String) -> NSError {
        lastFailureKind = kind
        lastUserVisibleError = message
        appendEvent(.failure, message: message, metadata: ["kind": kind.rawValue])
        return NSError(
            domain: "LocalBrainService",
            code: 1,
            userInfo: [
                NSLocalizedDescriptionKey: message,
                "LocalBrainFailureKind": kind.rawValue
            ]
        )
    }

    private func classify(_ error: Error, fallback: LocalBrainFailureKind) -> Error {
        let nsError = error as NSError
        if let rawValue = nsError.userInfo["LocalBrainFailureKind"] as? String, let existing = LocalBrainFailureKind(rawValue: rawValue) {
            lastFailureKind = existing
            lastUserVisibleError = nsError.localizedDescription
            return error
        }
        return classifiedError(fallback, message: nsError.localizedDescription)
    }

    private func appendEvent(_ kind: LocalBrainEventKind, message: String, metadata: [String: String] = [:]) {
        events.insert(LocalBrainEvent(kind: kind, message: message, metadata: metadata), at: 0)
        if events.count > 80 {
            events = Array(events.prefix(80))
        }
        persistEvents()
    }

    private func loadPersistedEvents() {
        guard let data = try? Data(contentsOf: Paths.runtimeDiagnosticsFile),
              let decoded = try? JSONDecoder().decode([LocalBrainEvent].self, from: data) else {
            return
        }
        events = decoded
    }

    private func persistEvents() {
        guard let data = try? JSONEncoder().encode(events) else { return }
        try? data.write(to: Paths.runtimeDiagnosticsFile, options: [.atomic])
    }
}
