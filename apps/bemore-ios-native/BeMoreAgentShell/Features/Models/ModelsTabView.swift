import SwiftUI
import UniformTypeIdentifiers

struct ModelsTabView: View {
    @EnvironmentObject private var appState: AppState
    @State private var modelName = ""
    @State private var modelURL = ""
    @State private var modelID = ""
    @State private var modelLib = ""
    @State private var isModelImporterPresented = false

    var body: some View {
        NavigationStack {
            List {
                if let stack = appState.activeStack {
                    Section("Stack Model Posture") {
                        Text(stack.recommendedModelStrategy)
                            .font(.footnote)
                            .foregroundStyle(.secondary)
                    }
                }

                Section("Runtime") {
                    LabeledContent("Backend", value: appState.backendDisplayName)
                    LabeledContent("Status", value: appState.runtimeStatus)
                    if let localBrainService = appState.localBrainService {
                        LabeledContent("Lifecycle", value: localBrainService.lifecycleState.operatorLabel)
                        if let failure = localBrainService.lastFailureKind?.rawValue {
                            LabeledContent("Last failure", value: failure)
                        }
                        if let currentModelSummary = localBrainService.currentModelSummary {
                            LabeledContent("Selected model", value: currentModelSummary)
                        }
                    }
                }

                if let localBrainService = appState.localBrainService {
                    Section("Local probe") {
                        Text("Run a tiny on-device prompt to verify model load, generation, and visible output without sending anything to a cloud route.")
                            .font(.footnote)
                            .foregroundStyle(.secondary)
                        Button("Run `Reply with OK.` probe") {
                            Task { await appState.runLocalModelProbe() }
                        }
                        .buttonStyle(.borderedProminent)

                        if let localProbeOutput = appState.localProbeOutput {
                            Text(localProbeOutput)
                                .font(.footnote.monospaced())
                        }
                    }

                    Section("Runtime diagnostics") {
                        if let lastUserVisibleError = localBrainService.lastUserVisibleError {
                            Text(lastUserVisibleError)
                                .font(.footnote)
                                .foregroundStyle(.red)
                        }

                        if localBrainService.events.isEmpty {
                            Text("No runtime events recorded yet.")
                                .foregroundStyle(.secondary)
                        } else {
                            ForEach(localBrainService.events.prefix(12)) { event in
                                VStack(alignment: .leading, spacing: 4) {
                                    Text(event.kind.rawValue.replacingOccurrences(of: "_", with: " ").capitalized)
                                        .font(.caption.weight(.semibold))
                                    Text(event.message)
                                        .font(.footnote)
                                    if event.metadata.isEmpty == false {
                                        Text(event.metadata.map { "\($0.key)=\($0.value)" }.sorted().joined(separator: " • "))
                                            .font(.caption2)
                                            .foregroundStyle(.secondary)
                                    }
                                }
                                .padding(.vertical, 2)
                            }
                        }
                    }
                }

                Section("Prepared model import") {
                    Text("Import a prepared model folder or artifact from Files when you already packaged it on your Mac. This is the preferred local-first path.")
                        .font(.footnote)
                        .foregroundStyle(.secondary)
                    if appState.usesStubRuntime {
                        Text("If the on-device runtime package is present, imports become real local routes. If it is absent, imports still prepare storage, selection, and model posture so the app can switch cleanly when local runtime support is available.")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                    Button("Import prepared model") {
                        isModelImporterPresented = true
                    }
                    .buttonStyle(.bordered)
                }

                Section("Add model source") {
                    Text("A saved model source is a convenience for later downloads. It is a networked path, not the default local-first path.")
                        .font(.footnote)
                        .foregroundStyle(.secondary)
                    TextField("Display name", text: $modelName)
                    TextField("Direct download URL", text: $modelURL)
                        .textInputAutocapitalization(.never)
                        .autocorrectionDisabled()
                        .keyboardType(.URL)
                    TextField("Model ID (for runtime)", text: $modelID)
                        .textInputAutocapitalization(.never)
                        .autocorrectionDisabled()
                    TextField("modelLib (packaged MLC lib name)", text: $modelLib)
                        .textInputAutocapitalization(.never)
                        .autocorrectionDisabled()

                    Button("Save model source") {
                        appState.modelStore.addRemoteModel(displayName: modelName, sourceURL: modelURL, modelID: modelID, modelLib: modelLib)
                        modelName = ""
                        modelURL = ""
                        modelID = ""
                        modelLib = ""
                    }
                    .buttonStyle(.borderedProminent)
                }

                if let activeDownload = appState.modelStore.activeDownload {
                    Section("Download") {
                        switch activeDownload {
                        case .idle(let modelName):
                            Label("Preparing \(modelName)", systemImage: "arrow.down.circle")
                        case .progress(let modelName, let fraction):
                            VStack(alignment: .leading, spacing: 8) {
                                Text(modelName)
                                ProgressView(value: fraction)
                            }
                        }
                    }
                }

                Section("Saved model sources") {
                    if appState.modelStore.remoteModels.isEmpty {
                        Text("No model sources yet.")
                            .foregroundStyle(.secondary)
                    }

                    ForEach(appState.modelStore.remoteModels) { model in
                        VStack(alignment: .leading, spacing: 8) {
                            Text(model.displayName)
                                .font(.headline)
                            Text(model.sourceURL)
                                .font(.caption)
                                .foregroundStyle(.secondary)
                                .lineLimit(2)
                            if !model.modelID.isEmpty {
                                Text("modelID: \(model.modelID)")
                                    .font(.caption2)
                                    .foregroundStyle(.secondary)
                            }
                            if !model.modelLib.isEmpty {
                                Text("modelLib: \(model.modelLib)")
                                    .font(.caption2)
                                    .foregroundStyle(.secondary)
                            }
                            HStack {
                                Button("Download") {
                                    appState.modelStore.download(model)
                                }
                                .buttonStyle(.borderedProminent)

                                Button("Remove", role: .destructive) {
                                    appState.modelStore.removeRemoteModel(model)
                                }
                                .buttonStyle(.bordered)
                            }
                        }
                        .padding(.vertical, 4)
                    }
                }

                Section("Installed model files") {
                    if appState.modelStore.installedModels.isEmpty {
                        Text("No downloaded model files yet.")
                            .foregroundStyle(.secondary)
                    }

                    ForEach(appState.modelStore.installedModels) { model in
                        VStack(alignment: .leading, spacing: 6) {
                            Text(model.localFilename)
                                .font(.headline)
                            Text(ByteCountFormatter.string(fromByteCount: model.fileSizeBytes, countStyle: .file))
                                .font(.caption)
                                .foregroundStyle(.secondary)
                            if !model.modelID.isEmpty {
                                Text("modelID: \(model.modelID)")
                                    .font(.caption2)
                                    .foregroundStyle(.secondary)
                            }
                            if !model.modelLib.isEmpty {
                                Text("modelLib: \(model.modelLib)")
                                    .font(.caption2)
                                    .foregroundStyle(.secondary)
                            }
                            if let checksum = model.checksumSHA256, checksum.isEmpty == false {
                                Text("sha256: \(checksum)")
                                    .font(.caption2)
                                    .foregroundStyle(.secondary)
                                    .lineLimit(1)
                            }

                            HStack {
                                Button(appState.runtimePreferences.selection.selectedInstalledFilename == model.localFilename ? "Selected" : "Use") {
                                    Task { await appState.setSelectedInstalledModel(filename: model.localFilename) }
                                }
                                .buttonStyle(.borderedProminent)

                                ShareLink(item: model.localURL) {
                                    Label("Share", systemImage: "square.and.arrow.up")
                                }
                                .buttonStyle(.bordered)

                                Button("Delete", role: .destructive) {
                                    appState.modelStore.deleteInstalledModel(model)
                                    if appState.runtimePreferences.selection.selectedInstalledFilename == model.localFilename {
                                        Task { await appState.setSelectedInstalledModel(filename: nil) }
                                    }
                                }
                                .buttonStyle(.bordered)
                            }
                        }
                        .padding(.vertical, 4)
                    }
                }
            }
            .navigationTitle("Models")
            .fileImporter(
                isPresented: $isModelImporterPresented,
                allowedContentTypes: [.folder, .data],
                allowsMultipleSelection: true
            ) { result in
                switch result {
                case .success(let urls):
                    appState.modelStore.importPreparedModelItems(from: urls)
                case .failure(let error):
                    appState.modelStore.errorMessage = error.localizedDescription
                }
            }
            .alert("Model error", isPresented: Binding(get: {
                appState.modelStore.errorMessage != nil
            }, set: { _ in
                appState.modelStore.errorMessage = nil
            })) {
                Button("OK", role: .cancel) {}
            } message: {
                Text(appState.modelStore.errorMessage ?? "Unknown error")
            }
        }
    }
}
