import SwiftUI

@main
struct BeMoreAgentApp: App {
    @StateObject private var appState = AppState(engine: LocalBrainService(engine: MLCBridgeEngine()))

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(appState)
                .task {
                    await appState.bootstrap()
                }
        }
    }
}
