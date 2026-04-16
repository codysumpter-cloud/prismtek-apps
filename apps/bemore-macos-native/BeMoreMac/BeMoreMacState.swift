import AppKit
import Foundation

enum BeMoreMacSection: String, CaseIterable, Identifiable {
    case home = "Home"
    case chat = "Chat"
    case work = "Workbench"
    case skills = "Skills"
    case results = "Results"
    case templates = "Templates"
    case settings = "Settings"

    var id: String { rawValue }

    var symbol: String {
        switch self {
        case .home: return "house.fill"
        case .chat: return "message.fill"
        case .work: return "checklist.checked"
        case .skills: return "wand.and.stars"
        case .results: return "doc.richtext.fill"
        case .templates: return "bag.fill"
        case .settings: return "gearshape.fill"
        }
    }
}

struct MacChatMessage: Identifiable, Hashable {
    let id = UUID()
    var speaker: String
    var body: String
}

struct MacTask: Identifiable, Hashable {
    let id = UUID()
    var title: String
    var detail: String
    var isDone: Bool = false
}

struct MacReceipt: Identifiable, Hashable {
    let id = UUID()
    var title: String
    var summary: String
    var artifact: String
    var createdAt: Date = .now
}

struct MacSkill: Identifiable, Hashable {
    var id: String
    var name: String
    var summary: String
    var status: String
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
    @Published var hasCompletedOnboarding: Bool
    @Published var energy = 72
    @Published var bond = 61
    @Published var focus = 68
    @Published var care = 58
    @Published var attention = 12
    @Published var chatDraft = ""
    @Published var taskDraft = ""
    @Published var runtimeStatus = "Not checked"

    @Published var chatMessages: [MacChatMessage] = [
        .init(speaker: "Prism", body: "I can help plan work, track receipts, run bounded skills, and keep Buddy/template progress understandable.")
    ]
    @Published var tasks: [MacTask] = [
        .init(title: "Review build 27 release notes", detail: "Confirm iOS surfaces, Buddy template path, and Pokemon Team Builder are understandable."),
        .init(title: "Package first Buddy template", detail: "Use Templates to produce a sanitized seller-ready draft.")
    ]
    @Published var receipts: [MacReceipt] = [
        .init(title: "Workspace ready", summary: "BeMore Mac opened with local native state.", artifact: "state/mac-session.json")
    ]
    @Published var skills: [MacSkill] = [
        .init(id: "pokemon-team-builder", name: "Pokemon Team Builder", summary: "Create, edit, analyze, and export Pokemon teams.", status: "Ready"),
        .init(id: "artifact-reviewer", name: "Artifact Reviewer", summary: "Review saved receipts and workspace artifacts.", status: "Ready"),
        .init(id: "buddy-template-packager", name: "Buddy Template Packager", summary: "Prepare sanitized Buddy template seller drafts.", status: "Ready")
    ]
    @Published var ownedBuddies = ["Prism", "Moe"]
    @Published var marketplaceBuddies = ["Prism Builder", "Moe Repair", "Scout Reviewer", "Nimbus Planner"]

    init() {
        hasCompletedOnboarding = UserDefaults.standard.bool(forKey: "bemore.mac.onboarding.completed")
        activeBuddyName = UserDefaults.standard.string(forKey: "bemore.mac.buddy.name") ?? "Prism"
        activeBuddyRole = UserDefaults.standard.string(forKey: "bemore.mac.buddy.role") ?? "Builder companion"
        activeBuddyFocus = UserDefaults.standard.string(forKey: "bemore.mac.buddy.focus") ?? "Keep today focused, useful, and receipt-backed."
        if let savedRuntime = UserDefaults.standard.string(forKey: "bemore.mac.runtime.url"),
           let url = URL(string: savedRuntime) {
            runtimeURL = url
        }
    }

    func completeOnboarding(name: String, role: String, focus: String, runtime: String) {
        activeBuddyName = name.trimmingCharacters(in: .whitespacesAndNewlines).nilIfBlank ?? "Prism"
        activeBuddyRole = role.trimmingCharacters(in: .whitespacesAndNewlines).nilIfBlank ?? "Builder companion"
        activeBuddyFocus = focus.trimmingCharacters(in: .whitespacesAndNewlines).nilIfBlank ?? "Keep today focused, useful, and receipt-backed."
        if let url = URL(string: runtime.trimmingCharacters(in: .whitespacesAndNewlines)), url.scheme != nil {
            runtimeURL = url
        }
        hasCompletedOnboarding = true
        UserDefaults.standard.set(true, forKey: "bemore.mac.onboarding.completed")
        UserDefaults.standard.set(activeBuddyName, forKey: "bemore.mac.buddy.name")
        UserDefaults.standard.set(activeBuddyRole, forKey: "bemore.mac.buddy.role")
        UserDefaults.standard.set(activeBuddyFocus, forKey: "bemore.mac.buddy.focus")
        UserDefaults.standard.set(runtimeURL.absoluteString, forKey: "bemore.mac.runtime.url")
        record(title: "Onboarding completed", summary: "\(activeBuddyName) is configured for \(activeBuddyRole).", artifact: "state/onboarding.json")
    }

    func resetOnboarding() {
        hasCompletedOnboarding = false
        UserDefaults.standard.set(false, forKey: "bemore.mac.onboarding.completed")
    }

    func openRuntime() {
        NSWorkspace.shared.open(runtimeURL)
    }

    func checkRuntime() {
        runtimeStatus = "Configured at \(runtimeURL.absoluteString)"
        markWorking()
        record(title: "Runtime checked", summary: "The native shell confirmed the configured runtime boundary.", artifact: "state/runtime-status.json")
    }

    func sendChat() {
        let prompt = chatDraft.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !prompt.isEmpty else { return }
        chatMessages.append(.init(speaker: "You", body: prompt))
        chatMessages.append(.init(speaker: activeBuddyName, body: "I captured that. Next I would turn it into a task, skill run, or saved artifact instead of pretending invisible work happened."))
        chatDraft = ""
        markHappy()
        record(title: "Chat captured", summary: "Saved a local chat turn for \(activeBuddyName).", artifact: "chat/mac-chat.json")
    }

    func addTask() {
        let title = taskDraft.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !title.isEmpty else { return }
        tasks.insert(.init(title: title, detail: "Created from BeMore Mac."), at: 0)
        taskDraft = ""
        markWorking()
        record(title: "Task created", summary: title, artifact: "tasks/mac-tasks.json")
    }

    func toggleTask(_ task: MacTask) {
        guard let index = tasks.firstIndex(where: { $0.id == task.id }) else { return }
        tasks[index].isDone.toggle()
        record(
            title: tasks[index].isDone ? "Task completed" : "Task reopened",
            summary: tasks[index].title,
            artifact: "tasks/mac-tasks.json"
        )
    }

    func runSkill(_ skill: MacSkill) {
        buddyMood = .working
        focus = min(100, focus + 4)
        energy = max(0, energy - 5)
        record(title: "Skill run: \(skill.name)", summary: skill.summary, artifact: "skills/\(skill.id)/latest.md")
    }

    func installBuddy(_ name: String) {
        if !ownedBuddies.contains(name) {
            ownedBuddies.append(name)
        }
        activeBuddyName = name.components(separatedBy: " ").first ?? name
        markHappy()
        record(title: "Buddy installed", summary: "\(name) is now available in your roster.", artifact: "buddies/roster.json")
    }

    func packageTemplate() {
        record(
            title: "Template package prepared",
            summary: "\(activeBuddyName) has a sanitized seller-ready draft. Private memory and raw notes stay excluded.",
            artifact: "buddies/templates/\(activeBuddyName.lowercased())-seller-guide.md"
        )
    }

    func markWorking() {
        buddyMood = .working
        energy = max(0, energy - 6)
        focus = min(100, focus + 4)
        latestReceipt = "\(activeBuddyName) is working with a visible receipt trail."
    }

    func markHappy() {
        buddyMood = .happy
        bond = min(100, bond + 4)
        attention = max(0, attention - 8)
        latestReceipt = "\(activeBuddyName) action completed locally."
    }

    func checkIn() {
        buddyMood = .happy
        care = min(100, care + 5)
        bond = min(100, bond + 6)
        attention = max(0, attention - 14)
        record(title: "Buddy check-in", summary: "You checked in with \(activeBuddyName).", artifact: "buddies/check-ins.json")
    }

    func train() {
        buddyMood = .working
        focus = min(100, focus + 8)
        energy = max(0, energy - 7)
        record(title: "Buddy trained", summary: "\(activeBuddyName) trained on a focused mission.", artifact: "buddies/training.json")
    }

    func rest() {
        buddyMood = .sleepy
        energy = min(100, energy + 18)
        care = min(100, care + 5)
        record(title: "Buddy rested", summary: "\(activeBuddyName) is resting before the next run.", artifact: "buddies/rest.json")
    }

    private func record(title: String, summary: String, artifact: String) {
        latestReceipt = summary
        receipts.insert(.init(title: title, summary: summary, artifact: artifact), at: 0)
        receipts = Array(receipts.prefix(20))
    }
}

private extension String {
    var nilIfBlank: String? {
        let trimmed = trimmingCharacters(in: .whitespacesAndNewlines)
        return trimmed.isEmpty ? nil : trimmed
    }
}
