import SwiftUI
import UniformTypeIdentifiers

struct LocalModelsView: View {
    @EnvironmentObject private var appState: AppState
    @State private var importerPresented = false
    @State private var transferFormPresented = false

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: BMOTheme.spacingMD) {
                    statusCard
                    importCard
                    installedModels
                }
                .padding(.horizontal, BMOTheme.spacingMD)
                .padding(.bottom, BMOTheme.spacingXL)
            }
            .background(BMOTheme.backgroundPrimary)
            .navigationTitle("")
            .toolbar {
                ToolbarItem(placement: .principal) {
                    Text("Models")
                        .font(.headline)
                        .foregroundColor(BMOTheme.textPrimary)
                }
                ToolbarItem(placement: .topBarTrailing) {
                    Menu {
                        Button {
                            transferFormPresented = true
                        } label: {
                            Label("Add model source", systemImage: "arrow.down.circle")
                        }
                        Button {
                            importerPresented = true
                        } label: {
                            Label("Import model file", systemImage: "folder")
                        }
                    } label: {
                        Image(systemName: "plus.circle.fill")
                            .foregroundColor(BMOTheme.accent)
                    }
                }
            }
            .fileImporter(
                isPresented: $importerPresented,
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
            .sheet(isPresented: $transferFormPresented) {
                LocalModelDownloadSheet()
                    .environmentObject(appState)
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

    private var statusCard: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack {
                Text("Local runtime")
                    .font(.headline)
                    .foregroundColor(BMOTheme.textPrimary)
                Spacer()
                StatusBadge(label: appState.usesStubRuntime ? "Link runtime" : "Ready", color: appState.usesStubRuntime ? BMOTheme.warning : BMOTheme.success)
            }
            detailRow("Backend", value: appState.backendDisplayName)
            detailRow("Status", value: appState.runtimeStatus)
            Text("Add or import a mobile model artifact. BeMore stores it in app storage and only activates it when the matching native runtime is available.")
                .font(.caption)
                .foregroundColor(BMOTheme.textSecondary)
        }
        .bmoCard()
    }

    private var importCard: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Install inside BeMore")
                .font(.headline)
                .foregroundColor(BMOTheme.textPrimary)
            Text("Use the same model artifact shape as the mobile runtime expects. No model binaries belong in git.")
                .font(.caption)
                .foregroundColor(BMOTheme.textSecondary)
            HStack(spacing: 10) {
                Button {
                    transferFormPresented = true
                } label: {
                    Label("Add source", systemImage: "arrow.down.circle")
                }
                .buttonStyle(BMOButtonStyle(isPrimary: true))

                Button {
                    importerPresented = true
                } label: {
                    Label("Import file", systemImage: "folder")
                }
                .buttonStyle(BMOButtonStyle(isPrimary: false))
            }
        }
        .bmoCard()
    }

    private var installedModels: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Installed models")
                .font(.subheadline.weight(.semibold))
                .foregroundColor(BMOTheme.textSecondary)

            if appState.modelStore.installedModels.isEmpty {
                Text("No local models installed yet.")
                    .font(.subheadline)
                    .foregroundColor(BMOTheme.textTertiary)
                    .frame(maxWidth: .infinity)
                    .bmoCard()
            } else {
                ForEach(appState.modelStore.installedModels) { model in
                    modelRow(model)
                }
            }
        }
    }

    private func modelRow(_ model: InstalledModel) -> some View {
        let selected = appState.runtimePreferences.selection.selectedInstalledFilename == model.localFilename
        let ready = canActivate(model)

        return HStack(spacing: 12) {
            VStack(alignment: .leading, spacing: 4) {
                Text(model.displayName)
                    .font(.subheadline.weight(.semibold))
                    .foregroundColor(BMOTheme.textPrimary)
                Text("\(artifactLabel(model.localURL)) • \(ByteCountFormatter.string(fromByteCount: model.fileSizeBytes, countStyle: .file))")
                    .font(.caption)
                    .foregroundColor(BMOTheme.textTertiary)
                Text(routeMessage(model))
                    .font(.caption2)
                    .foregroundColor(ready ? BMOTheme.textTertiary : BMOTheme.warning)
            }
            Spacer()
            if selected && ready {
                StatusBadge(label: "Active", color: BMOTheme.accent)
            } else if ready {
                Button("Use") {
                    Task { await appState.setSelectedInstalledModel(filename: model.localFilename) }
                }
                .buttonStyle(BMOButtonStyle(isPrimary: false))
            } else if selected {
                Button("Clear") {
                    Task { await appState.setSelectedInstalledModel(filename: nil) }
                }
                .buttonStyle(BMOButtonStyle(isPrimary: false))
            } else {
                StatusBadge(label: "Stored", color: BMOTheme.warning)
            }
        }
        .bmoCard()
    }

    private func canActivate(_ model: InstalledModel) -> Bool {
        guard !appState.usesStubRuntime else { return false }
        let ext = model.localURL.pathExtension.lowercased()
        if ["task", "bin", "mlmodelc"].contains(ext) { return true }
        if ["gguf", "zip", "safetensors", "pt", "pth"].contains(ext) { return false }
        var isDirectory: ObjCBool = false
        guard FileManager.default.fileExists(atPath: model.localURL.path, isDirectory: &isDirectory) else { return false }
        let root = isDirectory.boolValue ? model.localURL : model.localURL.deletingLastPathComponent()
        return ["mlc-chat-config.json", "tokenizer.json", "params_shard_0.bin"].allSatisfy { marker in
            FileManager.default.fileExists(atPath: root.appendingPathComponent(marker).path)
        }
    }

    private func routeMessage(_ model: InstalledModel) -> String {
        if appState.usesStubRuntime { return "Stored. Waiting for a runtime-linked build." }
        let ext = model.localURL.pathExtension.lowercased()
        if ["task", "bin"].contains(ext) { return "Ready for the Google mobile route." }
        if ext == "mlmodelc" { return "Compiled Core ML artifact detected." }
        return canActivate(model) ? "Prepared package detected." : "Not a runnable iOS local route."
    }

    private func artifactLabel(_ url: URL) -> String {
        switch url.pathExtension.lowercased() {
        case "task": return "Task Bundle"
        case "bin": return "MediaPipe"
        case "mlmodelc": return "Core ML"
        case "": return "Package"
        default: return url.pathExtension.uppercased()
        }
    }

    private func detailRow(_ label: String, value: String) -> some View {
        HStack {
            Text(label).foregroundColor(BMOTheme.textSecondary)
            Spacer()
            Text(value).foregroundColor(BMOTheme.textPrimary).multilineTextAlignment(.trailing)
        }
        .font(.subheadline)
    }
}
