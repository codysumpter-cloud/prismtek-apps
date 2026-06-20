import SwiftUI

/// Free-text memo pad persisted via AppState.memo (@AppStorage).
struct MemoView: View {
    @EnvironmentObject var appState: AppState

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Memo")
                .font(.headline)
            TextEditor(text: $appState.memo)
                .font(.body)
                .frame(minHeight: 120)
                .overlay(
                    RoundedRectangle(cornerRadius: 6)
                        .stroke(Color.secondary.opacity(0.3))
                )
            Text("Auto-saved")
                .font(.caption2)
                .foregroundStyle(.secondary)
        }
        .padding()
    }
}
