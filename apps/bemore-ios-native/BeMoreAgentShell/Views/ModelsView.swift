import SwiftUI
import UniformTypeIdentifiers

struct ModelsView: View {
    @EnvironmentObject private var appState: AppState
    @StateObject private var packageInstaller = MLCPackageInstaller()
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
                        Button { isModelImporterPresented = true } label: {
                            Label("Import prepared model", systemImage: "folder")
                        }
                        Button { showAddSource = true } label: {
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
                BundledModelCatalog.installBundledRecommendedModelIfAvailable(into: appState.modelStore)
                Task { await clearUnsupportedLocalSelectionIfNeeded(showAlert: false) }
            }
        }
    }

    private var activeRouteCard: some View {
        let selected = appState.selectedInstalledModel
        let usable = selected.map(isRuntimeCompatible) ?? false
        let unsupported = selected != nil && !usable

        return VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text("Active Route")
                    .font(.subheadline)
                    .fontWeight(.semibold)
                    .foregroundColor(BMOTheme.textSecondary)
                Spacer()
                StatusBadge(
                    label: unsupported ? "Needs runtime" : appState.activeRouteModeLabel,
                    color: appState.selectedProviderAccount != nil ? BMOTheme.success : (usable ? BMOTheme.accent : BMOTheme.warning)
                )
            }

            Text(unsupported ? "Local runtime not ready" : appState.activeRouteTitle)
                .font(.headline)
                .foregroundColor(BMOTheme.textPrimary)
            Text(unsupported ? runtimePackageMessage(for: selected!) : appState.activeRouteDetail)
                .font(.caption)
                .foregroundColor(BMOTheme.textSecondary)
            Text(unsupported ? "Use a cloud route for live chat until the native LiteRT-LM iOS bridge is linked and verified." : appState.routeHealthSummary)
                .font(.caption)
                .foregroundColor((appState.selectedProviderAccount != nil || usable) ? BMOTheme.textTertiary : BMOTheme.warning)
        }
        .bmoCard()
    }

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
                    Text("\(model.parameterCount) • \(model.family) • \(model.runtimeBackend)")
                        .font(.caption)
                        .foregroundColor(BMOTheme.textSecondary)
                    Text(BundledModelCatalog.hasBundledRecommendedModel ? "Included in this TestFlight build as a LiteRT-LM .litertlm artifact. Live local generation still waits for the native runtime bridge." : "Installs the Gemma 4 E2B LiteRT-LM .litertlm artifact from Hugging Face. This replaces the broken raw GGUF path.")
                        .font(.caption)
                        .foregroundColor(BMOTheme.textTertiary)
                        .fixedSize(horizontal: false, vertical: true)
                }
            }

            gemmaActionArea

            HStack(spacing: BMOTheme.spacingSM) {
                infoTag("LiteRT-LM")
                infoTag(".litertlm")
                infoTag(BundledModelCatalog.hasBundledRecommendedModel ? "Bundled" : "~2.6 GB")
            }
        }
        .bmoCard()
    }

    @ViewBuilder
    private var gemmaActionArea: some View {
        let installedModel = installedRecommendedModel

        switch packageInstaller.phase {
        case .resolvingManifest:
            VStack(spacing: 8) {
                ProgressView()
                    .tint(BMOTheme.accent)
                Text("Finding LiteRT-LM artifact on Hugging Face...")
                    .font(.caption)
                    .foregroundColor(BMOTheme.textSecondary)
            }

        case .downloading:
            VStack(spacing: 8) {
                ProgressView(value: packageInstaller.phase.progress ?? 0)
                    .tint(BMOTheme.accent)
                HStack {
                    Text(packageInstaller.phase.label)
                        .font(.caption)
                        .foregroundColor(BMOTheme.textSecondary)
                        .lineLimit(1)
                    Spacer()
                    Text("\(Int((packageInstaller.phase.progress ?? 0) * 100))%")
                        .font(.caption)
                        .fontWeight(.medium)
                        .foregroundColor(BMOTheme.accent)
                }
            }

        case .failed(let message):
            VStack(alignment: .leading, spacing: 8) {
                HStack(spacing: 6) {
                    Image(systemName: "xmark.circle.fill")
                        .foregroundColor(BMOTheme.error)
                    Text("Install failed")
                        .font(.subheadline)
                        .foregroundColor(BMOTheme.error)
                }
                Text(message)
                    .font(.caption)
                    .foregroundColor(BMOTheme.textTertiary)
                    .fixedSize(horizontal: false, vertical: true)
                Button("Retry LiteRT-LM install") {
                    Task {
                        await packageInstaller.installGemmaPackage(into: appState.modelStore) { filename in
                            await appState.setSelectedInstalledModel(filename: filename)
                        }
                    }
                }
                .buttonStyle(BMOButtonStyle(isPrimary: false))
            }

        case .idle, .installed:
            if let installedModel {
                if isRuntimeCompatible(installedModel) {
                    HStack(spacing: 8) {
                        Image(systemName: "checkmark.circle.fill")
                            .foregroundColor(BMOTheme.success)
                        Text("Installed & Ready")
                            .font(.subheadline)
                            .fontWeight(.medium)
                            .foregroundColor(BMOTheme.success)
                        Spacer()

                        if appState.runtimePreferences.selection.selectedInstalledFilename == installedModel.localFilename {
                            StatusBadge(label: "Active", color: BMOTheme.accent)
                        } else {
                            Button("Activate") {
                                Task { await appState.setSelectedInstalledModel(filename: installedModel.localFilename) }
                            }
                            .buttonStyle(BMOButtonStyle(isPrimary: false))
                        }
                    }
                } else {
                    unsupportedInstalledModelNotice(installedModel)
                }
            } else if BundledModelCatalog.hasBundledRecommendedModel {
                VStack(alignment: .leading, spacing: 10) {
                    HStack(spacing: 6) {
                        Image(systemName: "checkmark.circle.fill")
                            .foregroundColor(BMOTheme.success)
                        Text("Bundled model included")
                            .font(.subheadline)
                            .fontWeight(.medium)
                            .foregroundColor(BMOTheme.success)
                    }
                    Text("The bundled LiteRT-LM artifact will be registered automatically. It will stay inactive until the native LiteRT-LM bridge is linked.")
                        .font(.caption)
                        .foregroundColor(BMOTheme.textTertiary)
                }
            } else {
                VStack(alignment: .leading, spacing: 10) {
                    Button {
                        Task {
                            await packageInstaller.installGemmaPackage(into: appState.modelStore) { filename in
                                await appState.setSelectedInstalledModel(filename: filename)
                            }
                        }
                    } label: {
                        Label("Install Gemma 4 LiteRT-LM", systemImage: "arrow.down.circle.fill")
                            .font(.subheadline)
                            .fontWeight(.semibold)
                            .foregroundColor(BMOTheme.backgroundPrimary)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 14)
                            .background(BMOTheme.accent)
                            .clipShape(RoundedRectangle(cornerRadius: BMOTheme.radiusSmall, style: .continuous))
                    }

                    Text("This downloads gemma-4-E2B-it.litertlm instead of a raw GGUF file. Local generation remains gated until the runtime bridge is present.")
                        .font(.caption)
                        .foregroundColor(BMOTheme.textTertiary)
                        .fixedSize(horizontal: false, vertical: true)
                }
            }
        }
    }

    private func unsupportedInstalledModelNotice(_ model: InstalledModel) -> some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack(spacing: 6) {
                Image(systemName: "exclamationmark.triangle.fill")
                    .foregroundColor(BMOTheme.warning)
                Text("Installed artifact needs runtime")
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

                Button("Use cloud route") {
                    if let provider = appState.providerStore.enabledProviders().first?.provider {
                        appState.setSelectedProvider(provider)
                    } else {
                        appState.modelStore.errorMessage = "Link a cloud provider below for live chat while the native LiteRT-LM runtime bridge is being linked."
                    }
                }
                .buttonStyle(BMOButtonStyle(isPrimary: true))
            }
        }
    }

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

            VStack(alignment: .leading, spacing: 6) {
                Text(LiteRTLMAvailability.isAvailable ? "Native runtime linked" : "Native runtime required")
                    .font(.caption)
                    .fontWeight(.semibold)
                    .foregroundColor(LiteRTLMAvailability.isAvailable ? BMOTheme.success : BMOTheme.warning)
                Text(LiteRTLMAvailability.isAvailable ? "LiteRT-LM is available for verified .litertlm artifacts." : LiteRTLMAvailability.requirementMessage)
                    .font(.caption)
                    .foregroundColor(BMOTheme.textTertiary)
            }
            .padding(.top, 4)
        }
        .bmoCard()
    }

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
                StatusBadge(label: "Needs runtime", color: BMOTheme.warning)
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

            Text("Choose the active live route here. Local artifacts are not treated as live until the matching runtime is linked and verified.")
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

    private var savedSourcesSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text("Model Sources")
                    .font(.subheadline)
                    .fontWeight(.semibold)
                    .foregroundColor(BMOTheme.textSecondary)
                Spacer()
                Button { showAddSource = true } label: {
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
                Text("Saved source is a raw artifact or unknown package type. It can stay saved, but direct download is disabled until the source points at a prepared LiteRT-LM or runtime-supported package.")
                    .font(.caption2)
                    .foregroundColor(BMOTheme.warning)
                    .fixedSize(horizontal: false, vertical: true)
            }

            HStack(spacing: 10) {
                Button(sourceIsRunnable ? "Download" : "Download disabled") {
                    if sourceIsRunnable {
                        appState.modelStore.download(model)
                    } else {
                        appState.modelStore.errorMessage = "This source is not a prepared runtime package. Add a .litertlm artifact source or import a prepared runtime package from Files."
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

    private var installedRecommendedModel: InstalledModel? {
        let manifest = MLCPackageManifest.gemma4_E2B_IT_Q4F16_1
        return appState.modelStore.installedModels.first { model in
            model.localFilename == manifest.localFolderName || model.modelID == manifest.modelID
        }
    }

    private func clearUnsupportedLocalSelectionIfNeeded(showAlert: Bool) async {
        guard let selected = appState.selectedInstalledModel, !isRuntimeCompatible(selected) else { return }
        await appState.setSelectedInstalledModel(filename: nil)
        if let provider = appState.providerStore.enabledProviders().first?.provider {
            appState.setSelectedProvider(provider)
        }
        if showAlert {
            appState.modelStore.errorMessage = "The selected local artifact is not ready for this build, so it was cleared. Use a cloud route until the native LiteRT-LM runtime bridge is linked."
        }
    }

    private func isRuntimeCompatible(_ model: InstalledModel) -> Bool {
        let ext = model.localURL.pathExtension.lowercased()
        if ext == LiteRTLMAvailability.artifactExtension {
            return LiteRTLMAvailability.accepts(model)
        }

        guard !appState.usesStubRuntime else { return false }
        guard !model.modelLib.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else { return false }
        guard !Self.rawLocalArtifactExtensions.contains(ext) else { return false }

        var isDirectory: ObjCBool = false
        let exists = FileManager.default.fileExists(atPath: model.localURL.path, isDirectory: &isDirectory)
        guard exists, isDirectory.boolValue else { return false }

        return Self.preparedMLCMarkers.allSatisfy { marker in
            FileManager.default.fileExists(atPath: model.localURL.appendingPathComponent(marker).path)
        }
    }

    private func isRuntimeCompatibleSource(_ sourceURL: String) -> Bool {
        guard let url = URL(string: sourceURL) else { return false }
        let ext = url.pathExtension.lowercased()
        guard !Self.rawLocalArtifactExtensions.contains(ext) else { return false }
        return ext == LiteRTLMAvailability.artifactExtension || ext == "mlmodelc" || sourceURL.localizedCaseInsensitiveContains("mlc-chat-config.json")
    }

    private func runtimePackageMessage(for model: InstalledModel) -> String {
        let ext = model.localURL.pathExtension.lowercased()
        if ext == LiteRTLMAvailability.artifactExtension {
            return LiteRTLMAvailability.requirementMessage
        }
        if appState.usesStubRuntime {
            return "The artifact is installed, but this TestFlight build does not link a native on-device runtime. Use a cloud route for live chat until a runtime-linked build ships."
        }
        if model.modelLib.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            return "Missing runtime metadata. Import a prepared package with its model identifier and runtime backend metadata."
        }
        if Self.rawLocalArtifactExtensions.contains(ext) {
            return "Raw .\(ext) files are stored successfully, but this iOS runtime cannot execute them. Install the recommended LiteRT-LM artifact or use a cloud route."
        }
        return "This package does not include the prepared runtime markers required for on-device activation. Use a verified LiteRT-LM .litertlm artifact or a runtime-supported package."
    }

    private static let rawLocalArtifactExtensions: Set<String> = ["gguf", "task", "bin", "zip"]
    private static let preparedMLCMarkers = ["mlc-chat-config.json", "tokenizer.json", "params_shard_0.bin"]

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
                        fieldGroup("Display Name", text: $modelName, placeholder: "Gemma 4 E2B LiteRT-LM")
                        fieldGroup("Download URL", text: $modelURL, placeholder: "https://.../gemma-4-E2B-it.litertlm", keyboard: .URL)
                        fieldGroup("Model ID", text: $modelID, placeholder: "gemma-4-E2B-it")
                        fieldGroup("Runtime backend", text: $modelLib, placeholder: "litert-lm")

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
