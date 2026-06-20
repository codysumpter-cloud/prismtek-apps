import SwiftUI

/// Ambience toggles. v0: UI state only (silent placeholders) — no bundled audio yet to
/// keep licensing clean. Toggling on makes Bitbud wave. Audio is a documented placeholder.
struct AmbienceView: View {
    @EnvironmentObject var appState: AppState

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("Ambience")
                .font(.headline)
            Text("Sound is a silent placeholder in v0 (no bundled audio).")
                .font(.caption2)
                .foregroundStyle(.secondary)

            toggle("Rain", systemImage: "cloud.rain", isOn: $appState.rainOn)
            toggle("Keyboard", systemImage: "keyboard", isOn: $appState.keyboardOn)
            toggle("Fireplace", systemImage: "flame", isOn: $appState.fireplaceOn)
            toggle("Café", systemImage: "cup.and.saucer", isOn: $appState.cafeOn)
        }
        .padding()
    }

    private func toggle(_ label: String, systemImage: String, isOn: Binding<Bool>) -> some View {
        Toggle(isOn: Binding(
            get: { isOn.wrappedValue },
            set: { newValue in
                isOn.wrappedValue = newValue
                appState.ambienceToggled(on: newValue)
            }
        )) {
            Label(label, systemImage: systemImage)
        }
        #if os(macOS)
        .toggleStyle(.checkbox)
        #endif
    }
}
