import AppKit
import Foundation

enum BeMoreMacSection: String, CaseIterable, Identifiable {
    case home = "Prism"
    case chat = "Chat"
    case work = "Work"
    case results = "Results"
    case discover = "Discover"
    case settings = "Settings"

    var id: String { rawValue }

    var symbol: String {
        switch self {
        case .home: return "heart.text.square.fill"
        case .chat: return "message.fill"
        case .work: return "checklist.checked"
        case .results: return "doc.richtext.fill"
        case .discover: return "bag.fill"
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
    @Published var energy = 72
    @Published var bond = 61
    @Published var focus = 68
    @Published var care = 58
    @Published var attention = 12

    let quickActions = [
        "Check in with Prism",
        "Train Prism",
        "Rest Prism",
        "Run a mission"
    ]

    let ownedBuddies = ["Prism", "Moe"]
    let marketplaceBuddies = ["Prism Builder", "Moe Repair", "Scout Reviewer", "Nimbus Planner"]

    func openRuntime() {
        NSWorkspace.shared.open(runtimeURL)
    }

    func markWorking() {
        buddyMood = .working
        energy = max(0, energy - 6)
        focus = min(100, focus + 4)
        latestReceipt = "\(activeBuddyName) is checking the local runtime boundary."
    }

    func markHappy() {
        buddyMood = .happy
        bond = min(100, bond + 4)
        attention = max(0, attention - 8)
        latestReceipt = "\(activeBuddyName) action queued for the BeMore runtime."
    }

    func checkIn() {
        buddyMood = .happy
        care = min(100, care + 5)
        bond = min(100, bond + 6)
        attention = max(0, attention - 14)
        latestReceipt = "You checked in with \(activeBuddyName)."
    }

    func train() {
        buddyMood = .working
        focus = min(100, focus + 8)
        energy = max(0, energy - 7)
        latestReceipt = "\(activeBuddyName) trained with a focused mission."
    }

    func rest() {
        buddyMood = .sleepy
        energy = min(100, energy + 18)
        care = min(100, care + 5)
        latestReceipt = "\(activeBuddyName) is resting before the next run."
    }

    func needsAttention() {
        buddyMood = .needsAttention
        attention = min(100, attention + 16)
        latestReceipt = "\(activeBuddyName) needs a check-in before more work."
    }
}
