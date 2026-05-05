import SwiftUI

struct LocalModelDownloadSheet: View {
    @EnvironmentObject private var appState: AppState
    @Environment(\.dismiss) private var dismiss
    @State private var displayName = ""
    @State private var source = ""
    @State private var modelID = ""

    var body: some View {
        NavigationStack {
            ZStack {
                BMOTheme.backgroundPrimary.ignoresSafeArea()
                VStack(spacing: BMOTheme.spacingMD) {
                    textField("Display name", text: $displayName)
                    textField("Model file address", text: $source, keyboard: .URL)
                    textField("Model ID", text: $modelID)

                    Text("Use a direct model file address for a mobile artifact, such as a task bundle or MediaPipe model file.")
                        .font(.caption)
                        .foregroundColor(BMOTheme.textTertiary)
                        .fixedSize(horizontal: false, vertical: true)

                    Button("Save and start transfer") {
                        appState.modelStore.addRemoteModel(
                            displayName: displayName,
                            sourceURL: source,
                            modelID: modelID,
                            modelLib: ""
                        )
                        if let saved = appState.modelStore.remoteModels.first {
                            appState.modelStore.download(saved)
                        }
                        dismiss()
                    }
                    .buttonStyle(BMOButtonStyle())
                    .disabled(displayName.isEmpty || source.isEmpty)
                    .opacity(displayName.isEmpty || source.isEmpty ? 0.4 : 1.0)

                    Spacer()
                }
                .padding(BMOTheme.spacingLG)
            }
            .navigationTitle("Add Local Model")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
            }
        }
    }

    private func textField(_ label: String, text: Binding<String>, keyboard: UIKeyboardType = .default) -> some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(label)
                .font(.caption)
                .foregroundColor(BMOTheme.textSecondary)
            TextField(label, text: text)
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
