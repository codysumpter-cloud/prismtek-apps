import SwiftUI

@main
struct BeMoreMacApp: App {
    @StateObject private var state = BeMoreMacState()

    var body: some Scene {
        WindowGroup {
            BeMoreMacRootView()
                .environmentObject(state)
        }
        .windowStyle(.hiddenTitleBar)
        .commands {
            CommandMenu("BeMore") {
                Button("Open Local Runtime") {
                    state.openRuntime()
                }
                .keyboardShortcut("r", modifiers: [.command, .shift])
            }
        }
    }
}
