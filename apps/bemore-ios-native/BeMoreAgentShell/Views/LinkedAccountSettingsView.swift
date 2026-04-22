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

            Text("GitHub private repos can use a linked token immediately. ChatGPT/OpenAI and PixelLab keep native link state here too.")
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
                Text(record.isLinked ? "Linked" : (record.status == .pending ? "Pending" : "Not linked"))
                    .font(.caption)
                    .foregroundColor(record.isLinked ? BMOTheme.success : (record.status == .pending ? BMOTheme.warning : BMOTheme.textSecondary))
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
                    SecureField("Token", text: $accessToken)
                    Text(provider.tokenHint)
                        .font(.caption)
                        .foregroundColor(BMOTheme.textSecondary)
                }

                Section("Status") {
                    Text(record.isLinked ? "Linked locally on this device" : "Not linked yet")
                        .foregroundColor(record.isLinked ? BMOTheme.success : BMOTheme.textSecondary)
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
                        appState.linkedAccountStore.completeLink(
                            provider,
                            accountHandle: accountHandle,
                            accessToken: accessToken,
                            connectionMode: "native-link-shell"
                        )
                        dismiss()
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
}
