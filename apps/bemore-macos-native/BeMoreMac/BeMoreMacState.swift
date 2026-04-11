import AppKit
import Foundation

enum BeMoreMacSection: String, CaseIterable, Identifiable {
    case home = "Buddy Home"
    case workspace = "Workspace"
    case tasks = "Tasks"
    case skills = "Skills"
    case results = "Results"
    case settings = "Settings"

    var id: String { rawValue }

    var symbol: String {
        switch self {
        case .home: return "heart.text.square.fill"
        case .workspace: return "folder.fill"
        case .tasks: return "checklist.checked"
        case .skills: return "sparkles.rectangle.stack.fill"
        case .results: return "doc.richtext.fill"
        case .settings: return "gearshape.fill"
        }
    }
}

@MainActor
final class BeMoreMacState: ObservableObject {
    @Published var selectedSection: BeMoreMacSection = .home
    @Published var buddyMood: BuddyMood = .idle
    @Published var runtimeURL = URL(string: "http://127.0.0.1:4319")!
    @Published var latestReceipt = "Ready for the first receipt."

    let quickActions = [
        "Open workspace",
        "Create Buddy task",
        "Run command",
        "Review diff",
        "Inspect receipts"
    ]

    func openRuntime() {
        NSWorkspace.shared.open(runtimeURL)
    }

    func markWorking() {
        buddyMood = .working
        latestReceipt = "Buddy is checking the local runtime boundary."
    }

    func markHappy() {
        buddyMood = .happy
        latestReceipt = "Buddy action queued for the BeMore runtime."
    }
}
