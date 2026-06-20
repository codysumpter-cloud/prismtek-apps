import SwiftUI

/// Top-level layout. macOS: room + side panel with a Mini Mode floating-window toggle.
/// iOS: room on top, tabbed panels below (compact layout).
struct RootView: View {
    @EnvironmentObject var appState: AppState

    var body: some View {
        #if os(macOS)
        MacRootView()
        #else
        iOSRootView()
        #endif
    }
}

// MARK: - macOS

#if os(macOS)
import AppKit

private struct MacRootView: View {
    @EnvironmentObject var appState: AppState
    @State private var miniWindow: NSWindow?

    var body: some View {
        HSplitView {
            VStack(spacing: 0) {
                CozyRoomView()
                if appState.showGiftUnlock { GiftBanner() }
            }
            .frame(minWidth: 360)

            ScrollView {
                VStack(alignment: .leading, spacing: 12) {
                    HStack {
                        Text("Prismtek Buddies").font(.title3.bold())
                        Spacer()
                        Button(miniWindow == nil ? "Mini Mode" : "Close Mini") {
                            toggleMini()
                        }
                        .buttonStyle(.bordered)
                    }
                    .padding(.horizontal)
                    .padding(.top)

                    RoomThemePicker()
                        .padding(.horizontal)

                    BuddyActionsView()
                    Divider()
                    FocusTimerView()
                    Divider()
                    TasksView()
                    Divider()
                    MemoView()
                    Divider()
                    AmbienceView()
                }
            }
            .frame(minWidth: 320, idealWidth: 360)
        }
        .onAppear { appState.greeted() }
    }

    private func toggleMini() {
        if let win = miniWindow {
            win.close()
            miniWindow = nil
            return
        }
        let hosting = NSHostingController(
            rootView: MiniModeView().environmentObject(appState)
        )
        let win = NSWindow(contentViewController: hosting)
        win.styleMask = [.titled, .closable, .fullSizeContentView]
        win.titleVisibility = .hidden
        win.titlebarAppearsTransparent = true
        win.isMovableByWindowBackground = true
        win.level = .floating
        win.setContentSize(NSSize(width: 140, height: 150))
        win.title = "Bitbud"
        win.makeKeyAndOrderFront(nil)
        miniWindow = win
    }
}
#endif

// MARK: - iOS

#if os(iOS)
private struct iOSRootView: View {
    @EnvironmentObject var appState: AppState

    var body: some View {
        VStack(spacing: 0) {
            CozyRoomView()
                .frame(height: 240)
            if appState.showGiftUnlock { GiftBanner() }
            RoomThemePicker()
                .padding(.horizontal)
                .padding(.vertical, 6)
            TabView {
                ScrollView { BuddyActionsView() }
                    .tabItem { Label("Buddy", systemImage: "face.smiling") }
                ScrollView { FocusTimerView() }
                    .tabItem { Label("Focus", systemImage: "timer") }
                ScrollView { TasksView() }
                    .tabItem { Label("Tasks", systemImage: "checklist") }
                ScrollView { MemoView() }
                    .tabItem { Label("Memo", systemImage: "note.text") }
                ScrollView { AmbienceView() }
                    .tabItem { Label("Ambience", systemImage: "speaker.wave.2") }
            }
        }
        .onAppear { appState.greeted() }
    }
}
#endif

// MARK: - Shared gift banner

struct GiftBanner: View {
    @EnvironmentObject var appState: AppState
    var body: some View {
        HStack {
            Image(systemName: "gift.fill")
            Text("Gift unlocked! (\(appState.progression.giftsUnlocked) total) — reward coming soon.")
                .font(.caption)
            Spacer()
            Button("OK") { appState.showGiftUnlock = false }
                .buttonStyle(.borderless)
        }
        .padding(8)
        .background(Color.accentColor.opacity(0.2))
    }
}

// MARK: - Room theme picker

/// Selects the cozy-room theme. Persists the chosen id under the same
/// @AppStorage key `CozyRoomView` reads ("buddy.room.theme"), default Cozy Desk.
struct RoomThemePicker: View {
    @AppStorage("buddy.room.theme") private var themeID: String = BuddyRoomTheme.defaultID

    var body: some View {
        Picker("Room Theme", selection: $themeID) {
            ForEach(BuddyRoomTheme.presets) { theme in
                Text(theme.name).tag(theme.id)
            }
        }
        #if os(macOS)
        .pickerStyle(.menu)
        #else
        .pickerStyle(.segmented)
        #endif
    }
}
