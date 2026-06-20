import SwiftUI

@main
struct PrismcadeiOSApp: App {
    @StateObject private var state = PrismcadeState()

    var body: some Scene {
        WindowGroup {
            RootView()
                .environmentObject(state)
        }
    }
}
