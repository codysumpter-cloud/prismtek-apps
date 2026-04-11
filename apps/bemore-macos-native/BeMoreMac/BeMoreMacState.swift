import AppKit
import Foundation

enum BeMoreMacSection: String, CaseIterable, Identifiable {
    case home = "Buddy Home"
    case buddy = "My Buddy"
    case chat = "Chat"
    case workspace = "Workspace"
    case tasks = "Tasks"
    case skills = "Skills"
    case results = "Results"
    case marketplace = "Marketplace"
    case pricing = "Pricing"
    case settings = "Settings"

    var id: String { rawValue }

    var symbol: String {
        switch self {
        case .home: return "heart.text.square.fill"
        case .buddy: return "person.crop.circle.badge.checkmark"
        case .chat: return "message.fill"
        case .workspace: return "folder.fill"
        case .tasks: return "checklist.checked"
        case .skills: return "sparkles.rectangle.stack.fill"
        case .results: return "doc.richtext.fill"
        case .marketplace: return "bag.fill"
        case .pricing: return "creditcard.fill"
        case .settings: return "gearshape.fill"
        }
    }
}

@MainActor
final class BeMoreMacState: ObservableObject {
    @Published var selectedSection: BeMoreMacSection = .home
    @Published var buddyMood: BuddyMood = .idle
    @Published var runtimeURL = URL(string: "http://127.0.0.1:4319")!
    @Published var activeBuddyName = "Prism"
    @Published var activeBuddyRole = "Builder companion"
    @Published var activeBuddyFocus = "Keep today focused, useful, and receipt-backed."
    @Published var latestReceipt = "Prism is ready for the next useful step."

    let quickActions = [
        "Chat with Prism",
        "Train Buddy",
        "Run a skill",
        "Review results",
        "Pair Mac power"
    ]

    let ownedBuddies = ["Prism", "Moe"]
    let marketplaceBuddies = ["Prism Builder", "Moe Repair", "Scout Reviewer", "Nimbus Planner"]

    func openRuntime() {
        NSWorkspace.shared.open(runtimeURL)
    }

    func markWorking() {
        buddyMood = .working
        latestReceipt = "\(activeBuddyName) is checking the local runtime boundary."
    }

    func markHappy() {
        buddyMood = .happy
        latestReceipt = "\(activeBuddyName) action queued for the BeMore runtime."
    }
}
