import AppIntents
import Foundation

struct AskBuddyIntent: AppIntent {
    static var title: LocalizedStringResource = "Ask Buddy"
    static var description = IntentDescription("Ask Buddy for planning, follow-through, research, or practical help inside BeMoreAgent.")
    static var openAppWhenRun = true

    @Parameter(title: "Request", default: "")
    var request: String

    @MainActor
    func perform() async throws -> some IntentResult & ProvidesDialog {
        _ = BuddyIntentBridge.enqueue(BuddyIntentRequest(kind: .askBuddy, text: request))
        return .result(dialog: IntentDialog("Opening Buddy with your request."))
    }
}

struct TeachBuddyIntent: AppIntent {
    static var title: LocalizedStringResource = "Teach Buddy"
    static var description = IntentDescription("Teach Buddy a preference, routine, style rule, or correction.")
    static var openAppWhenRun = true

    @Parameter(title: "Teaching", default: "")
    var teaching: String

    @MainActor
    func perform() async throws -> some IntentResult & ProvidesDialog {
        _ = BuddyIntentBridge.enqueue(BuddyIntentRequest(kind: .teachBuddy, text: teaching))
        return .result(dialog: IntentDialog("Opening Buddy training."))
    }
}

struct OpenBuddyAgentBrowserIntent: AppIntent {
    static var title: LocalizedStringResource = "Open Buddy Agent Browser"
    static var description = IntentDescription("Open Buddy's guarded browser for research and user-approved tool actions.")
    static var openAppWhenRun = true

    @Parameter(title: "Search or URL", default: "")
    var query: String

    @MainActor
    func perform() async throws -> some IntentResult & ProvidesDialog {
        _ = BuddyIntentBridge.enqueue(BuddyIntentRequest(kind: .openAgentBrowser, text: query))
        return .result(dialog: IntentDialog("Opening Buddy Agent Browser."))
    }
}

struct SaveBuddyMemoryIntent: AppIntent {
    static var title: LocalizedStringResource = "Save Buddy Memory"
    static var description = IntentDescription("Ask Buddy to save a memory, preference, source, or note for later review.")
    static var openAppWhenRun = true

    @Parameter(title: "Memory", default: "")
    var memory: String

    @MainActor
    func perform() async throws -> some IntentResult & ProvidesDialog {
        _ = BuddyIntentBridge.enqueue(BuddyIntentRequest(kind: .saveMemory, text: memory))
        return .result(dialog: IntentDialog("Opening Buddy to save that memory."))
    }
}

struct CreateBuddyReminderIntent: AppIntent {
    static var title: LocalizedStringResource = "Create Buddy Reminder Draft"
    static var description = IntentDescription("Ask Buddy to prepare a reminder draft for you to review.")
    static var openAppWhenRun = true

    @Parameter(title: "Reminder", default: "")
    var reminder: String

    @MainActor
    func perform() async throws -> some IntentResult & ProvidesDialog {
        _ = BuddyIntentBridge.enqueue(BuddyIntentRequest(kind: .createReminderDraft, text: reminder))
        return .result(dialog: IntentDialog("Opening Buddy with a reminder draft."))
    }
}

struct DraftBuddyMessageIntent: AppIntent {
    static var title: LocalizedStringResource = "Draft Buddy Message"
    static var description = IntentDescription("Ask Buddy to prepare a message draft. Sending remains user-reviewed.")
    static var openAppWhenRun = true

    @Parameter(title: "Message", default: "")
    var message: String

    @MainActor
    func perform() async throws -> some IntentResult & ProvidesDialog {
        _ = BuddyIntentBridge.enqueue(BuddyIntentRequest(kind: .draftMessage, text: message))
        return .result(dialog: IntentDialog("Opening Buddy with a message draft."))
    }
}

struct DraftBuddyEmailIntent: AppIntent {
    static var title: LocalizedStringResource = "Draft Buddy Email"
    static var description = IntentDescription("Ask Buddy to prepare an email draft. Sending remains user-reviewed.")
    static var openAppWhenRun = true

    @Parameter(title: "Email", default: "")
    var email: String

    @MainActor
    func perform() async throws -> some IntentResult & ProvidesDialog {
        _ = BuddyIntentBridge.enqueue(BuddyIntentRequest(kind: .draftEmail, text: email))
        return .result(dialog: IntentDialog("Opening Buddy with an email draft."))
    }
}

struct StartBuddyFocusIntent: AppIntent {
    static var title: LocalizedStringResource = "Start Buddy Focus"
    static var description = IntentDescription("Start a Buddy focus session around a goal or task.")
    static var openAppWhenRun = true

    @Parameter(title: "Goal", default: "")
    var goal: String

    @MainActor
    func perform() async throws -> some IntentResult & ProvidesDialog {
        _ = BuddyIntentBridge.enqueue(BuddyIntentRequest(kind: .startFocus, text: goal))
        return .result(dialog: IntentDialog("Opening Buddy Focus."))
    }
}

struct OpenBuddyProjectRoomIntent: AppIntent {
    static var title: LocalizedStringResource = "Open Buddy Project Room"
    static var description = IntentDescription("Open a project context in Buddy so it can help with the next action.")
    static var openAppWhenRun = true

    @Parameter(title: "Project", default: "")
    var project: String

    @MainActor
    func perform() async throws -> some IntentResult & ProvidesDialog {
        _ = BuddyIntentBridge.enqueue(BuddyIntentRequest(kind: .openProjectRoom, text: project))
        return .result(dialog: IntentDialog("Opening that Buddy project room."))
    }
}

struct BuddyShortcutsProvider: AppShortcutsProvider {
    static var appShortcuts: [AppShortcut] {
        AppShortcut(
            intent: AskBuddyIntent(),
            phrases: [
                "Ask \(.applicationName)",
                "Ask Buddy in \(.applicationName)",
                "Talk to Buddy in \(.applicationName)"
            ],
            shortTitle: "Ask Buddy",
            systemImageName: "message.fill"
        )

        AppShortcut(
            intent: TeachBuddyIntent(),
            phrases: [
                "Teach Buddy in \(.applicationName)",
                "Train Buddy in \(.applicationName)"
            ],
            shortTitle: "Teach Buddy",
            systemImageName: "graduationcap.fill"
        )

        AppShortcut(
            intent: OpenBuddyAgentBrowserIntent(),
            phrases: [
                "Open Buddy browser in \(.applicationName)",
                "Open agent browser in \(.applicationName)"
            ],
            shortTitle: "Buddy Browser",
            systemImageName: "safari.fill"
        )

        AppShortcut(
            intent: SaveBuddyMemoryIntent(),
            phrases: [
                "Save to Buddy in \(.applicationName)",
                "Remember this with \(.applicationName)"
            ],
            shortTitle: "Save Memory",
            systemImageName: "brain.head.profile"
        )

        AppShortcut(
            intent: CreateBuddyReminderIntent(),
            phrases: [
                "Create a Buddy reminder in \(.applicationName)",
                "Ask Buddy to remind me in \(.applicationName)"
            ],
            shortTitle: "Reminder Draft",
            systemImageName: "bell.badge.fill"
        )

        AppShortcut(
            intent: DraftBuddyMessageIntent(),
            phrases: [
                "Draft a Buddy message in \(.applicationName)",
                "Ask Buddy to draft a message in \(.applicationName)"
            ],
            shortTitle: "Draft Message",
            systemImageName: "message.badge.fill"
        )

        AppShortcut(
            intent: DraftBuddyEmailIntent(),
            phrases: [
                "Draft a Buddy email in \(.applicationName)",
                "Ask Buddy to draft an email in \(.applicationName)"
            ],
            shortTitle: "Draft Email",
            systemImageName: "envelope.badge.fill"
        )

        AppShortcut(
            intent: StartBuddyFocusIntent(),
            phrases: [
                "Start Buddy focus in \(.applicationName)",
                "Focus with Buddy in \(.applicationName)"
            ],
            shortTitle: "Buddy Focus",
            systemImageName: "timer"
        )
    }
}
