import SwiftUI

@main
struct PrismtekBuddiesMacApp: App {
    @StateObject private var appState = AppState()

    var body: some Scene {
        WindowGroup {
            RootView()
                .environmentObject(appState)
                .frame(minWidth: 720, minHeight: 520)
        }
        .windowResizability(.contentMinSize)
    }
}
