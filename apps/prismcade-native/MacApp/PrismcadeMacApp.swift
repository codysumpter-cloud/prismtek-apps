import SwiftUI

@main
struct PrismcadeMacApp: App {
    @StateObject private var state = PrismcadeState()

    var body: some Scene {
        WindowGroup {
            RootView()
                .environmentObject(state)
                .frame(minWidth: 920, minHeight: 620)
        }
    }
}
