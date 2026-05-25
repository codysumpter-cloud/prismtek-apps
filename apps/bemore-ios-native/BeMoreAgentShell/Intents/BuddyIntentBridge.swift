import Foundation

// MARK: - Buddy intent bridge

struct BuddyIntentRequest: Identifiable, Codable, Equatable {
    enum Kind: String, Codable, CaseIterable {
        case askBuddy
        case teachBuddy
        case openAgentBrowser
        case saveMemory
        case createReminderDraft
        case draftMessage
        case draftEmail
        case startFocus
        case openProjectRoom
    }

    var id: UUID = UUID()
    var kind: Kind
    var text: String
    var createdAt: Date = Date()
    var source: String = "AppIntent"

    var promptForChat: String {
        let trimmed = text.trimmingCharacters(in: .whitespacesAndNewlines)
        switch kind {
        case .askBuddy:
            return trimmed.isEmpty ? "Help me decide what Buddy should do next." : trimmed
        case .teachBuddy:
            return trimmed.isEmpty ? "Help me teach Buddy a new preference or routine." : "Teach Buddy this: \(trimmed)"
        case .saveMemory:
            return trimmed.isEmpty ? "Save a new Buddy memory." : "Save this to Buddy memory: \(trimmed)"
        case .createReminderDraft:
            return trimmed.isEmpty ? "Prepare a reminder draft for me to review." : "Prepare a reminder draft: \(trimmed)"
        case .draftMessage:
            return trimmed.isEmpty ? "Prepare a message draft for me to review." : "Prepare a message draft: \(trimmed)"
        case .draftEmail:
            return trimmed.isEmpty ? "Prepare an email draft for me to review." : "Prepare an email draft: \(trimmed)"
        case .startFocus:
            return trimmed.isEmpty ? "Start Buddy Focus Mode and help me pick the next task." : "Start Buddy Focus Mode for: \(trimmed)"
        case .openProjectRoom:
            return trimmed.isEmpty ? "Open my Buddy project room and show me what needs attention." : "Open the Buddy project room for: \(trimmed)"
        case .openAgentBrowser:
            return trimmed.isEmpty ? "Open the guarded Buddy Agent browser." : "Open the guarded Buddy Agent browser for: \(trimmed)"
        }
    }
}

enum BuddyIntentBridge {
    static let callbackScheme = "bemoreagent"
    private static let fileName = "buddy-intent-requests.json"

    static var requestFile: URL {
        Paths.stateDirectory.appendingPathComponent(fileName)
    }

    @discardableResult
    static func enqueue(_ request: BuddyIntentRequest) -> BuddyIntentRequest {
        var requests = loadRequests()
        requests.insert(request, at: 0)
        requests = Array(requests.prefix(50))
        persist(requests)
        return request
    }

    static func loadRequests() -> [BuddyIntentRequest] {
        guard let data = try? Data(contentsOf: requestFile) else { return [] }
        return (try? JSONDecoder().decode([BuddyIntentRequest].self, from: data)) ?? []
    }

    static func consumeLatest() -> BuddyIntentRequest? {
        var requests = loadRequests()
        guard !requests.isEmpty else { return nil }
        let latest = requests.removeFirst()
        persist(requests)
        return latest
    }

    private static func persist(_ requests: [BuddyIntentRequest]) {
        do {
            let data = try JSONEncoder().encode(requests)
            try data.write(to: requestFile, options: [.atomic])
        } catch {
            // Intent persistence should never break app launch or Siri routing.
        }
    }
}

extension BuddyIntentRequest.Kind {
    var urlHost: String {
        switch self {
        case .askBuddy: return "ask"
        case .teachBuddy: return "teach"
        case .openAgentBrowser: return "agent"
        case .saveMemory: return "memory"
        case .createReminderDraft: return "reminder"
        case .draftMessage: return "message"
        case .draftEmail: return "email"
        case .startFocus: return "focus"
        case .openProjectRoom: return "project"
        }
    }

    init?(urlHost: String) {
        switch urlHost.lowercased() {
        case "ask", "chat": self = .askBuddy
        case "teach", "train": self = .teachBuddy
        case "agent", "browser": self = .openAgentBrowser
        case "memory", "remember": self = .saveMemory
        case "reminder", "reminders": self = .createReminderDraft
        case "message", "text": self = .draftMessage
        case "email", "mail": self = .draftEmail
        case "focus": self = .startFocus
        case "project", "room": self = .openProjectRoom
        default: return nil
        }
    }
}

@MainActor
extension AppState {
    func handleBuddyIntentURL(_ url: URL) {
        guard let scheme = url.scheme?.lowercased(), ["bemoreagent", "ibemore", "bemore"].contains(scheme) else {
            return
        }

        let host = url.host ?? "ask"
        let kind = BuddyIntentRequest.Kind(urlHost: host) ?? .askBuddy
        let components = URLComponents(url: url, resolvingAgainstBaseURL: false)
        let text = components?.queryItems?.first(where: { ["text", "prompt", "q"].contains($0.name.lowercased()) })?.value ?? ""
        let request = BuddyIntentRequest(kind: kind, text: text, source: "URLScheme")
        routeForBuddyIntent(request)
    }

    func consumePendingBuddyIntentIfNeeded() {
        guard let request = BuddyIntentBridge.consumeLatest() else { return }
        routeForBuddyIntent(request)
    }

    func routeForBuddyIntent(_ request: BuddyIntentRequest) {
        switch request.kind {
        case .openAgentBrowser:
            if !request.text.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                pendingPrompt = request.promptForChat
            }
            route(to: .agent)
        case .saveMemory, .createReminderDraft, .draftMessage, .draftEmail, .startFocus, .openProjectRoom, .teachBuddy, .askBuddy:
            openChat(with: request.promptForChat)
        }
    }
}
