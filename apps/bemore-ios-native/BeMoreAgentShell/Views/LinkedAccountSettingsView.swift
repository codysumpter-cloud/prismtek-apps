import SwiftUI

struct LinkedAccountsSectionView: View {
    @EnvironmentObject private var appState: AppState
    @Environment(\.openURL) private var openURL
    @State private var editingProvider: LinkedAccountProvider?

    var body: some View {
        Section("Linked Accounts") {
            ForEach(LinkedAccountProvider.allCases) { provider in
                linkedAccountRow(provider)
                    .listRowBackground(BMOTheme.backgroundCard)
            }

            Text("GitHub private repos can use a linked token immediately. ChatGPT/OpenAI and PixelLab keep native link state here too. Provider browser hops now open the most relevant account/token page instead of a generic homepage. Full zero-auth callback completion still depends on matching provider/backend setup.")
                .font(.caption)
                .foregroundColor(BMOTheme.textSecondary)
                .listRowBackground(BMOTheme.backgroundCard)
        }
        .sheet(item: $editingProvider) { provider in
            LinkedAccountEditorSheet(provider: provider)
                .environmentObject(appState)
        }
    }

    private func linkedAccountRow(_ provider: LinkedAccountProvider) -> some View {
        let record = appState.linkedAccountStore.record(for: provider)
        return VStack(alignment: .leading, spacing: 10) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text(provider.title)
                        .foregroundColor(BMOTheme.textPrimary)
                    Text(record.accountHandle ?? provider.tokenHint)
                        .font(.caption)
                        .foregroundColor(BMOTheme.textSecondary)
                }
                Spacer()
                Text(statusLabel(for: record))
                    .font(.caption)
                    .foregroundColor(statusColor(for: record))
            }

            HStack {
                Button(record.isLinked ? "Manage" : "Link") {
                    editingProvider = provider
                }
                .buttonStyle(.bordered)

                Button(browserActionLabel(for: provider)) {
                    appState.linkedAccountStore.markPending(provider)
                    if let url = OAuthLinkService().authorizationURL(for: provider, stackConfig: appState.stackConfig) {
                        openURL(url)
                    }
                }
                .buttonStyle(.bordered)
            }
        }
    }

    private func statusLabel(for record: LinkedAccountRecord) -> String {
        if record.isLinked { return "Linked" }
        switch record.status {
        case .unlinked: return "Not linked"
        case .pending: return "Pending"
        case .linked: return "Linked"
        }
    }

    private func statusColor(for record: LinkedAccountRecord) -> Color {
        record.isLinked ? BMOTheme.success : (record.status == .pending ? BMOTheme.warning : BMOTheme.textSecondary)
    }

    private func browserActionLabel(for provider: LinkedAccountProvider) -> String {
        switch provider {
        case .github:
            return "Get Token"
        case .chatgpt:
            return "Open Keys"
        case .pixelLab:
            return "Open Site"
        }
    }
}

private struct LinkedAccountEditorSheet: View {
    @EnvironmentObject private var appState: AppState
    @Environment(\.dismiss) private var dismiss
    let provider: LinkedAccountProvider
    @State private var accountHandle = ""
    @State private var accessToken = ""

    var body: some View {
        let record = appState.linkedAccountStore.record(for: provider)
        NavigationStack {
            Form {
                Section("Account") {
                    TextField(provider.accountPlaceholder, text: $accountHandle)
                    SecureField("Access token", text: $accessToken)
                    Text(provider.tokenHint)
                        .font(.caption)
                        .foregroundColor(BMOTheme.textSecondary)
                }

                Section("Status") {
                    Text(record.isLinked ? "Linked locally on this device" : "Not linked yet")
                        .foregroundColor(record.isLinked ? BMOTheme.success : BMOTheme.textSecondary)
                    Button("Start provider authorization") {
                        appState.linkedAccountStore.markPending(provider)
                        dismiss()
                    }
                    .foregroundColor(BMOTheme.accent)
                }

                if record.isLinked {
                    Section {
                        Button("Unlink") {
                            appState.linkedAccountStore.unlink(provider)
                            dismiss()
                        }
                        .foregroundColor(BMOTheme.error)
                    }
                }
            }
            .navigationTitle(provider.title)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
 ToolbarItem(placement: .confirmationAction) {
 Button("Save") {
 Task {
 await saveLinkedAccount()
 }
 }
 .disabled(accessToken.isEmpty)
 }
 }
 .onAppear {
 accountHandle = record.accountHandle ?? ""
 accessToken = record.accessToken ?? ""
 }
 }
 }
 
 private func saveLinkedAccount() async {
 // Validate PixelLab token if applicable
 if provider == .pixelLab {
 let (isValid, _) = await PixelLabService.shared.validateToken(accessToken)
 if !isValid {
 // Token validation failed, but we'll still save it
 // The user can try again later
 }
 }
 
 await MainActor.run {
 appState.linkedAccountStore.completeLink(
 provider,
 accountHandle: accountHandle,
 accessToken: accessToken,
 connectionMode: "native-link-shell"
 )
 dismiss()
 }
 }
 
 }
 .onAppear {
 accountHandle = record.accountHandle ?? ""
 accessToken = record.accessToken ?? ""
 }
 }
}