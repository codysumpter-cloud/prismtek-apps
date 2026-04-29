import SwiftUI
import UniformTypeIdentifiers

struct ModelsView: View {
    @EnvironmentObject private var appState: AppState
    @State private var isModelImporterPresented = false
    @State private var showAddSource = false

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: BMOTheme.spacingMD) {
                    activeRouteCard
                    recommendedModelCard
                    runtimeInfoCard
                    installedModelsSection
                    cloudRoutesSection
                    savedSourcesSection
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
                            isModelImporterPresented = true
                        } label: {
                            Label("Import prepared model", systemImage: "folder")
                        }
                        Button {
                            showAddSource = true
                        } label: {
                            Label("Add model source URL", systemImage: "link")
                        }
                    } label: {
                        Image(systemName: "plus.circle.fill")
                            .foregroundColor(BMOTheme.accent)
                    }
                }
            }
            .toolbarBackground(BMOTheme.backgroundPrimary, for: .navigationBar)
            .toolbarBackground(.visible, for: .navigationBar)
            .fileImporter(
                isPresented: $isModelImporterPresented,
                allowedContentTypes: [.folder, .data],
                allowsMultipleSelection: true
            ) { result in
                switch result {
                case .success(let urls):
                    appState.modelStore.importPreparedModelItems(from: urls)
                    Task { await clearUnsupportedLocalSelectionIfNeeded(showAlert: false) }
                case .failure(let error):
                    appState.modelStore.errorMessage = error.localizedDescription
                }
            }
            .sheet(isPresented: $showAddSource) {
                AddModelSourceSheet()
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
            .onAppear {
                Task { await clearUnsupportedLocalSelectionIfNeeded(showAlert: false) }
            }
        }
    }

    private var activeRouteCard: some View {
        let selectedLocalModel = appState.selectedInstalledModel
        let selectedLocalModelIsUsable = selectedLocalModel.map(isRuntimeCompatible) ?? false
        let selectedLocalModelIsUnsupported = selectedLocalModel != nil && !selectedLocalModelIsUsable

        return VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text("Active Route")
                    .font(.subheadline)
                    .fontWeight(.semibold)
                    .foregroundColor(BMOTheme.textSecondary)
                Spacer()
                StatusBadge(
                    label: selectedLocalModelIsUnsupported ? "Needs package" : appState.activeRouteModeLabel,
                    color: appState.selectedProviderAccount != nil ? BMOTheme.success : (selectedLocalModelIsUsable ? BMOTheme.accent : BMOTheme.warning)
                )
            }

            Text(selectedLocalModelIsUnsupported ? "Local model package required" : appState.activeRouteTitle)
                .font(.headline)
                .foregroundColor(BMOTheme.textPrimary)
            Text(selectedLocalModelIsUnsupported ? runtimePackageMessage(for: selectedLocalModel!) : appState.activeRouteDetail)
                .font(.caption)
                .foregroundColor(BMOTheme.textSecondary)
            Text(selectedLocalModelIsUnsupported ? "Choose a cloud route or import a prepared MLC/Core ML package before using on-device chat." : appState.routeHealthSummary)
                .font(.caption)
                .foregroundColor((appState.selectedProviderAccount != nil || selectedLocalModelIsUsable) ? BMOTheme.textTertiary : BMOTheme.warning)
        }
        .bmoCard()
    }

    // MARK: - Recommended model

    private var recommendedModelCard: some View {
        let model = KnownModel.gemma4E2B

        return VStack(alignment: .leading, spacing: 14) {
            HStack {
                Text("Recommended")
                    .font(.caption)
                    .fontWeight(.semibold)
                    .foregroundColor(BMOTheme.accent)
                    .padding(.horizontal, 10)
                    .padding(.vertical, 4)
                    .background(BMOTheme.accent.opacity(0.12))
                    .clipShape(Capsule())
                Spacer()
            }

            HStack(alignment: .top, spacing: 14) {
                ZStack {
                    RoundedRectangle(cornerRadius: BMOTheme.radiusSmall, style: .continuous)
                        .fill(BMOTheme.accent.opacity(0.12))
                        .frame(width: 52, height: 52)
                    Image(systemName: "cpu")
                        .font(.title2)
                        .foregroundColor(BMOTheme.accent)
                }

                VStack(alignment: .leading, spacing: 4) {
                    Text(model.name)
                        .font(.headline)
                        .foregroundColor(BMOTheme.textPrimary)
                    Text("\(model.parameterCount) parameters • \(model.family)")
                        .font(.caption)
                        .foregroundColor(BMOTheme.textSecondary)
                    Text("The previous built-in download saved a raw GGUF file. This app's current on-device path needs a prepared MLC/Core ML runtime package, so automatic local install is paused until a compatible package ships.")
                        .font(.caption)
                        .foregroundColor(BMOTheme.textTertiary)
                        .fixedSize(horizontal: false, vertical: true)
                }
            }

            // State-dependent action
            gemmaActionArea

            HStack(spacing: BMOTheme.spacingSM) {
                infoTag("Prepared package required")
                infoTag("GGUF not runnable here")
                infoTag("Use cloud now")
            }
        }
        .bmoCard()
    }

    @ViewBuilder
    private var gemmaActionArea: some View {
        switch appState.gemmaDownloadState {
        case .notInstalled:
            VStack(alignment: .leading, spacing: 10) {
                Text("Automatic local install is disabled for this model in Build 50 because the available download is a raw GGUF artifact, not a prepared iOS runtime package.")
                    .font(.caption)
                    .foregroundColor(BMOTheme.warning)
                    .fixedSize(horizontal: false, vertical: true)

                HStack(spacing: 10) {
                    Button {
                        isModelImporterPresented = true
                    } label: {
                        Label("Import prepared package", systemImage: "folder")
                    }
                    .buttonStyle(BMOButtonStyle(isPrimary: false))

                    Button {
                        if let provider = appState.providerStore.enabledProviders().first?.provider {
                            appState.setSelectedProvider(provider)
                        } else {
                            appState.modelStore.errorMessage = "Link a cloud provider below for live chat while the prepared on-device Gemma package is being added."
                        }
                    } label: {
                        Label("Use cloud route", systemImage: "cloud.fill")
                    }
                    .buttonStyle(BMOButtonStyle(isPrimary: true))
                }
            }

        case .downloading(let progress):
            VStack(spacing: 8) {
                ProgressView(value: progress)
                    .tint(BMOTheme.accent)
                HStack {
                    Text("Downloading legacy artifact...")
                        .font(.caption)
                        .foregroundColor(BMOTheme.textSecondary)
                    Spacer()
                    Text("\(Int(progress * 100))%")
                        .font(.caption)
                        .fontWeight(.medium)
                        .foregroundColor(BMOTheme.accent)
                }
            }

        case .installed:
            if let model = appState.modelStore.installedModels.first(where: { $0.modelID == "gemma4-e2b-it" }) {
                if isRuntimeCompatible(model) {
                    HStack(spacing: 8) {
                        Image(systemName: "checkmark.circle.fill")
                            .foregroundColor(BMOTheme.success)
                        Text("Installed & Ready")
                            .font(.subheadline)
                            .fontWeight(.medium)
                            .foregroundColor(BMOTheme.success)
                        Spacer()

                        if appState.runtimePreferences.selection.selectedInstalledFilename == model.localFilename {
                            StatusBadge(label: "Active", color: BMOTheme.accent)
                        } else {
                            Button("Activate") {
                                Task { await appState.setSelectedInstalledModel(filename: model.localFilename) }
                            }
                            .buttonStyle(BMOButtonStyle(isPrimary: false))
                        }
                    }
                } else {
                    unsupportedInstalledModelNotice(model)
                }
            } else {
                unsupportedInstalledGemmaNotice
            }

        case .failed(let message):
            VStack(alignment: .leading, spacing: 8) {
                HStack(spacing: 6) {
                    Image(systemName: "xmark.circle.fill")
                        .foregroundColor(BMOTheme.error)
                    Text("Install unavailable")
                        .font(.subheadline)
                        .foregroundColor(BMOTheme.error)
                }
                Text(message)
                    .font(.caption)
                    .foregroundColor(BMOTheme.textTertiary)

                Button("Import prepared package") {
                    isModelImporterPresented = true
                }
                .buttonStyle(BMOButtonStyle(isPrimary: false))
            }
        }
    }

    private func unsupportedInstalledModelNotice(_ model: InstalledModel) -> some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack(spacing: 6) {
                Image(systemName: "exclamationmark.triangle.fill")
                    .foregroundColor(BMOTheme.warning)
                Text("Installed file is not runnable")
                    .font(.subheadline)
                    .fontWeight(.medium)
                    .foregroundColor(BMOTheme.warning)
            }
            Text(runtimePackageMessage(for: model))
                .font(.caption)
                .foregroundColor(BMOTheme.textTertiary)
                .fixedSize(horizontal: false, vertical: true)
            HStack(spacing: 10) {
                Button("Clear route") {
                    Task { await appState.setSelectedInstalledModel(filename: nil) }
                }
                .buttonStyle(BMOButtonStyle(isPrimary: false))

                Button("Remove file") {
                    appState.modelStore.deleteInstalledModel(model)
                    Task { await appState.setSelectedInstalledModel(filename: nil) }
                }
                .buttonStyle(BMOButtonStyle(isPrimary: false))
            }
        }
    }

    private var unsupportedInstalledGemmaNotice: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("The previous Gemma install is not a prepared runtime package. Remove the raw file from Installed Models, then use a cloud route or import a prepared MLC/Core ML package.")
                .font(.caption)
                .foregroundColor(BMOTheme.warning)
                .fixedSize(horizontal: false, vertical: true)
            Button("Clear local route") {
                Task { await appState.setSelectedInstalledModel(filename: nil) }
            }
            .buttonStyle(BMOButtonStyle(isPrimary: false))
        }
    }

    // MARK: - Runtime info

    private var runtimeInfoCard: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack {
                Image(systemName: "bolt.fill")
                    .foregroundColor(BMOTheme.accent)
                Text("Runtime")
                    .font(.headline)
                    .foregroundColor(BMOTheme.textPrimary)
            }

            HStack {
                Text("Backend")
                    .foregroundColor(BMOTheme.textSecondary)
                Spacer()
                Text(appState.backendDisplayName)
                    .fontWeight(.medium)
                    .foregroundColor(BMOTheme.textPrimary)
            }
            .font(.subheadline)

            HStack {
                Text("Status")
                    .foregroundColor(BMOTheme.textSecondary)
                Spacer()
                Text(appState.runtimeStatus)
                    .fontWeight(.medium)
                    .foregroundColor(BMOTheme.textPrimary)
            }
            .font(.subheadline)

            if appState.usesStubRuntime {
                VStack(alignment: .leading, spacing: 6) {
                    Text("Runtime package required")
                        .font(.caption)
                        .fontWeight(.semibold)
                        .foregroundColor(BMOTheme.warning)
                    Text("Model storage works, but live on-device inference requires a prepared iOS runtime package. Raw GGUF files are not executable through the current MLC/MLCSwift path.")
                        .font(.caption)
                        .foregroundColor(BMOTheme.textTertiary)
                }
                .padding(.top, 4)
            }
        }
        .bmoCard()
    }

    // MARK: - Installed models

    private var installedModelsSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Installed Models")
                .font(.subheadline)
                .fontWeight(.semibold)
                .foregroundColor(BMOTheme.textSecondary)

            if appState.modelStore.installedModels.isEmpty {
                VStack(spacing: 8) {
                    Image(systemName: "tray")
                        .font(.title2)
                        .foregroundColor(BMOTheme.textTertiary)
                    Text("No models installed yet")
                        .font(.subheadline)
                        .foregroundColor(BMOTheme.textTertiary)
                }
                .frame(maxWidth: .infinity)
                .bmoCard()
            } else {
                ForEach(appState.modelStore.installedModels) { model in
                    installedModelRow(model)
                }
            }
        }
    }

    private func installedModelRow(_ model: InstalledModel) -> some View {
        let isSelected = appState.runtimePreferences.selection.selectedInstalledFilename == model.localFilename
        let canUseModel = isRuntimeCompatible(model)

        return HStack(spacing: 12) {
            VStack(alignment: .leading, spacing: 3) {
                Text(model.displayName)
                    .font(.subheadline)
                    .fontWeight(.medium)
                    .foregroundColor(BMOTheme.textPrimary)
                HStack(spacing: 8) {
                    Text(ByteCountFormatter.string(fromByteCount: model.fileSizeBytes, countStyle: .file))
                        .font(.caption)
                        .foregroundColor(BMOTheme.textTertiary)
                    if !model.modelID.isEmpty {
                        Text(model.modelID)
                            .font(.caption)
                            .foregroundColor(BMOTheme.textTertiary)
                    }
                }
                if !canUseModel {
                    Text(runtimePackageMessage(for: model))
                        .font(.caption2)
                        .foregroundColor(BMOTheme.warning)
                        .fixedSize(horizontal: false, vertical: true)
                }
            }

            Spacer()

            if isSelected && canUseModel {
                StatusBadge(label: "Active", color: BMOTheme.accent)
            } else if isSelected {
                Button("Clear") {
                    Task { await appState.setSelectedInstalledModel(filename: nil) }
                }
                .font(.caption)
                .fontWeight(.semibold)
                .foregroundColor(BMOTheme.warning)
                .padding(.horizontal, 12)
                .padding(.vertical, 6)
                .background(BMOTheme.warning.opacity(0.12))
                .clipShape(Capsule())
            } else if canUseModel {
                Button("Use") {
                    Task { await appState.setSelectedInstalledModel(filename: model.localFilename) }
                }
                .font(.caption)
                .fontWeight(.semibold)
                .foregroundColor(BMOTheme.accent)
                .padding(.horizontal, 12)
                .padding(.vertical, 6)
                .background(BMOTheme.accent.opacity(0.12))
                .clipShape(Capsule())
            } else {
                StatusBadge(label: "Unsupported", color: BMOTheme.warning)
            }

            Button {
                appState.modelStore.deleteInstalledModel(model)
                if isSelected {
                    Task { await appState.setSelectedInstalledModel(filename: nil) }
                }
            } label: {
                Image(systemName: "trash")
                    .font(.caption)
                    .foregroundColor(BMOTheme.error.opacity(0.6))
            }
        }
        .bmoCard()
    }

    private var cloudRoutesSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Cloud Routes")
                .font(.subheadline)
                .fontWeight(.semibold)
                .foregroundColor(BMOTheme.textSecondary)

            Text("Choose the active model route here. Workspace actions run through BeMore runtime receipts, not unconfirmed model claims.")
                .font(.caption)
                .foregroundColor(BMOTheme.textTertiary)

            ForEach(ProviderKind.allCases) { provider in
                providerRouteRow(provider)
            }
        }
    }

    private func providerRouteRow(_ provider: ProviderKind) -> some View {
        let account = appState.providerStore.account(for: provider)
        let isActive = appState.runtimePreferences.selection.selectedProvider == provider
        let models = appState.availableModels(for: provider)

        return VStack(alignment: .leading, spacing: 10) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text(provider.displayName)
                        .foregroundColor(BMOTheme.textPrimary)
                    Text(account.isEnabled ? account.baseURL : provider.accountHint)
                        .font(.caption)
                        .foregroundColor(BMOTheme.textSecondary)
                        .lineLimit(2)
                }
                Spacer()
                Text(isActive ? "Active" : account.isEnabled ? "Ready" : "Not linked")
                    .font(.caption)
                    .foregroundColor(isActive ? BMOTheme.accent : account.isEnabled ? BMOTheme.success : BMOTheme.warning)
            }

            if account.isEnabled {
                Picker("Model", selection: Binding(
                    get: { appState.providerStore.account(for: provider).modelSlug },
                    set: { appState.updateProviderModel(provider, modelSlug: $0) }
                )) {
                    ForEach(models) { model in
                        Text(model.displayName).tag(model.slug)
                    }
                }
                .pickerStyle(.menu)

                HStack {
                    Button(isActive ? "Using now" : "Make active") {
                        appState.setSelectedProvider(provider)
                    }
                    .buttonStyle(.borderedProminent)
                    .disabled(isActive)

                    Button("Test route") {
                        Task { await appState.verifyProviderConnection(provider) }
                    }
                    .buttonStyle(.bordered)
                }
            }
        }
        .bmoCard()
    }

    // MARK: - Saved sources

    private var savedSourcesSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text("Model Sources")
                    .font(.subheadline)
                    .fontWeight(.semibold)
                    .foregroundColor(BMOTheme.textSecondary)
                Spacer()
                Button {
                    showAddSource = true
                } label: {
                    Image(systemName: "plus")
                        .font(.caption)
                        .foregroundColor(BMOTheme.accent)
                }
            }

            if appState.modelStore.remoteModels.isEmpty {
                VStack(spacing: 8) {
                    Text("No saved model sources")
                        .font(.subheadline)
                        .foregroundColor(BMOTheme.textTertiary)
                }
                .frame(maxWidth: .infinity)
                .bmoCard()
            } else {
                ForEach(appState.modelStore.remoteModels) { model in
                    sourceRow(model)
                }
            }
        }
    }

    private func sourceRow(_ model: RemoteModel) -> some View {
        let sourceIsRunnable = isRuntimeCompatibleSource(model.sourceURL)

        return VStack(alignment: .leading, spacing: 8) {
            Text(model.displayName)
                .font(.subheadline)
                .fontWeight(.medium)
                .foregroundColor(BMOTheme.textPrimary)
            Text(model.sourceURL)
                .font(.caption)
                .foregroundColor(BMOTheme.textTertiary)
                .lineLimit(1)

            if !sourceIsRunnable {
                Text("Saved source is a raw artifact or unknown package type. It can stay saved, but direct download is disabled until the source points at a prepared runtime package.")
                    .font(.caption2)
                    .foregroundColor(BMOTheme.warning)
                    .fixedSize(horizontal: false, vertical: true)
            }

            HStack(spacing: 10) {
                Button(sourceIsRunnable ? "Download" : "Download disabled") {
                    if sourceIsRunnable {
                        appState.modelStore.download(model)
                    } else {
                        appState.modelStore.errorMessage = "This source is not a prepared runtime package. Add an MLC/Core ML package source or import the prepared folder from Files."
                    }
                }
                .font(.caption)
                .fontWeight(.semibold)
                .foregroundColor(sourceIsRunnable ? BMOTheme.backgroundPrimary : BMOTheme.textTertiary)
                .padding(.horizontal, 14)
                .padding(.vertical, 8)
                .background(sourceIsRunnable ? BMOTheme.accent : BMOTheme.backgroundSecondary)
                .clipShape(Capsule())

                Button("Remove") {
                    appState.modelStore.removeRemoteModel(model)
                }
                .font(.caption)
                .foregroundColor(BMOTheme.error.opacity(0.7))
            }
        }
        .bmoCard()
    }

    // MARK: - Helpers

    private func clearUnsupportedLocalSelectionIfNeeded(showAlert: Bool) async {
        guard let selected = appState.selectedInstalledModel, !isRuntimeCompatible(selected) else { return }
        await appState.setSelectedInstalledModel(filename: nil)
        if let provider = appState.providerStore.enabledProviders().first?.provider {
            appState.setSelectedProvider(provider)
        }
        if showAlert {
            appState.modelStore.errorMessage = "The selected local file is not a prepared runtime package, so it was cleared. Use a cloud route or import a prepared MLC/Core ML package."
        }
    }

    private func isRuntimeCompatible(_ model: InstalledModel) -> Bool {
        guard !model.modelLib.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
            return false
        }

        let ext = model.localURL.pathExtension.lowercased()
        if Self.rawLocalArtifactExtensions.contains(ext) {
            return false
        }

        if ext == "mlmodelc" {
            return true
        }

        var isDirectory: ObjCBool = false
        let exists = FileManager.default.fileExists(atPath: model.localURL.path, isDirectory: &isDirectory)
        guard exists else { return false }

        let packageRoot = isDirectory.boolValue ? model.localURL : model.localURL.deletingLastPathComponent()
        return Self.preparedRuntimeMarkers.contains { marker in
            FileManager.default.fileExists(atPath: packageRoot.appendingPathComponent(marker).path)
        }
    }

    private func isRuntimeCompatibleSource(_ sourceURL: String) -> Bool {
        guard let url = URL(string: sourceURL) else { return false }
        let ext = url.pathExtension.lowercased()
        guard !Self.rawLocalArtifactExtensions.contains(ext) else { return false }
        return ["mlmodelc"].contains(ext) || sourceURL.localizedCaseInsensitiveContains("mlc-chat-config.json")
    }

    private func runtimePackageMessage(for model: InstalledModel) -> String {
        let ext = model.localURL.pathExtension.lowercased()
        if model.modelLib.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            return "Missing modelLib metadata. Import a prepared runtime package with its model library name."
        }
        if Self.rawLocalArtifactExtensions.contains(ext) {
            return "Raw .\(ext) files are stored successfully, but this iOS runtime cannot execute them. Import a prepared MLC/Core ML package or use a cloud route."
        }
        return "This file does not include the prepared runtime markers required for on-device activation. Import a folder containing mlc-chat-config.json, tokenizer files, and parameter shards."
    }

    private static let rawLocalArtifactExtensions: Set<String> = ["gguf", "task", "bin", "zip"]
    private static let preparedRuntimeMarkers = ["mlc-chat-config.json", "tokenizer.json", "params_shard_0.bin"]

    private func infoTag(_ text: String) -> some View {
        Text(text)
            .font(.system(size: 11))
            .foregroundColor(BMOTheme.textTertiary)
            .padding(.horizontal, 8)
            .padding(.vertical, 4)
            .background(BMOTheme.backgroundSecondary)
            .clipShape(Capsule())
    }
}

// MARK: - Add model source sheet

struct AddModelSourceSheet: View {
    @EnvironmentObject private var appState: AppState
    @Environment(\.dismiss) private var dismiss
    @State private var modelName = ""
    @State private var modelURL = ""
    @State private var modelID = ""
    @State private var modelLib = ""

    var body: some View {
        NavigationStack {
            ZStack {
                BMOTheme.backgroundPrimary.ignoresSafeArea()

                ScrollView {
                    VStack(spacing: BMOTheme.spacingMD) {
                        fieldGroup("Display Name", text: $modelName, placeholder: "My Model")
                        fieldGroup("Download URL", text: $modelURL, placeholder: "https://...", keyboard: .URL)
                        fieldGroup("Model ID (runtime)", text: $modelID, placeholder: "model-id")
                        fieldGroup("Model Lib (MLC)", text: $modelLib, placeholder: "model_lib_name")

                        Button("Save Source") {
                            appState.modelStore.addRemoteModel(
                                displayName: modelName,
                                sourceURL: modelURL,
                                modelID: modelID,
                                modelLib: modelLib
                            )
                            dismiss()
                        }
                        .buttonStyle(BMOButtonStyle())
                        .disabled(modelName.isEmpty || modelURL.isEmpty)
                        .opacity(modelName.isEmpty || modelURL.isEmpty ? 0.4 : 1.0)
                        .padding(.top, BMOTheme.spacingSM)
                    }
                    .padding(BMOTheme.spacingLG)
                }
            }
            .navigationTitle("Add Model Source")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                        .foregroundColor(BMOTheme.textSecondary)
                }
            }
        }
    }

    private func fieldGroup(_ label: String, text: Binding<String>, placeholder: String, keyboard: UIKeyboardType = .default) -> some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(label)
                .font(.caption)
                .foregroundColor(BMOTheme.textSecondary)
            TextField(placeholder, text: text)
                .textFieldStyle(.plain)
                .font(.body)
                .foregroundColor(BMOTheme.textPrimary)
                .padding(.horizontal, 14)
                .padding(.vertical, 12)
                .background(BMOTheme.backgroundCard)
                .clipShape(RoundedRectangle(cornerRadius: BMOTheme.radiusSmall, style: .continuous))
                .textInputAutocapitalization(.never)
                .autocorrectionDisabled()
                .keyboardType(keyboard)
        }
    }
}
