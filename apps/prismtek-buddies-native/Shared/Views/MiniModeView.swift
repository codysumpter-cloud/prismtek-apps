import SwiftUI

/// Compact buddy + timer view. On macOS it can be toggled into a small floating
/// always-on-top window (see RootView). Here it's the compact layout itself.
struct MiniModeView: View {
    @EnvironmentObject var appState: AppState

    var body: some View {
        VStack(spacing: 8) {
            SelectedBuddyRenderer(state: appState.buddyState, pixelScale: 0.9)
            Text("Lvl \(appState.progression.level)")
                .font(.caption2)
                .foregroundStyle(.secondary)
        }
        .padding(8)
        .background(
            Rectangle()
                .fill(Color(white: 0.15).opacity(0.85))
        )
    }
}
