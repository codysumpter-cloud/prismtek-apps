import AppIntents
import Foundation

@MainActor
struct BuddyShortcutService {
    func teachPlanningLoop(
        preferenceDetail: String,
        topPriority: String,
        supportStyle: String,
        createReminder: Bool = false
    ) async throws -> String {
        let contracts = try BuddyContractLoader.loadCanonicalResources()
        let store = BuddyInstanceStore()
        let runtime = OpenClawWorkspaceRuntime()
        runtime.bootstrap(config: .default, preferences: .default, routeSummary: "Shortcut")

        var libraryState = store.loadLibraryState() ?? BuddyLibraryState()
        var eventLog = store.loadEventLog() ?? BuddyRuntimeEventLog()
        let engine = BuddyEventEngine(contracts: contracts)

        if libraryState.activeBuddy == nil {
            let install = try engine.install(
                templateID: "bmo",
                currentState: libraryState,
                currentEvents: eventLog
            )
            _ = runtime.persistBuddyBundle(install, source: "buddy.shortcut")
            libraryState = install.libraryState
            eventLog = install.eventLog
        }

        guard let activeBuddy = libraryState.activeBuddy else {
            throw BuddyEventEngineError.instanceNotFound("active")
        }

        let bundle = try engine.teachPlanningLoop(
            instanceID: activeBuddy.instanceId,
            preferenceTitle: "Daily planning style",
            preferenceDetail: preferenceDetail,
            topPriority: topPriority,
            supportStyle: supportStyle,
            currentState: libraryState,
            currentEvents: eventLog
        )
        let receipt = runtime.persistBuddyBundle(bundle, source: "buddy.shortcut")

        let plan = bundle.libraryState.activeBuddy?.dailyPlans?.sorted(by: { $0.createdAt > $1.createdAt }).first
        var reminderResult = "Reminder not requested."
        if createReminder, let plan {
            do {
                _ = try await BuddyAppleIntegrationService().createReminder(
                    title: plan.reminderTitle,
                    notes: plan.journalPrompt,
                    dueDate: Calendar.current.date(byAdding: .hour, value: 2, to: .now)
                )
                reminderResult = "Reminder created."
            } catch {
                reminderResult = "Reminder not created: \(error.localizedDescription)"
            }
        }

        let buddyName = bundle.libraryState.activeBuddy?.displayName ?? "Buddy"
        return "\(buddyName) learned your planning style. \(receipt.summary) \(reminderResult)"
    }
}

struct TeachBuddyPlanningIntent: AppIntent {
    static var title: LocalizedStringResource = "Teach Buddy Planning"
    static var description = IntentDescription("Teach Buddy how you want to plan today, train the planning skill, and optionally create a Reminders item.")

    @Parameter(title: "Planning Preference", default: "Help me pick one calm, useful next step.")
    var preference: String

    @Parameter(title: "Top Priority", default: "Plan today")
    var topPriority: String

    @Parameter(title: "Support Style", default: "Calm, specific, and low-pressure")
    var supportStyle: String

    @Parameter(title: "Create Reminder", default: false)
    var createReminder: Bool

    static var parameterSummary: some ParameterSummary {
        Summary("Teach Buddy \(\.$preference) for \(\.$topPriority)")
    }

    func perform() async throws -> some IntentResult & ReturnsValue<String> {
        let result = try await BuddyShortcutService().teachPlanningLoop(
            preferenceDetail: preference,
            topPriority: topPriority,
            supportStyle: supportStyle,
            createReminder: createReminder
        )
        return .result(value: result)
    }
}

struct BuddyShortcutsProvider: AppShortcutsProvider {
    static var appShortcuts: [AppShortcut] {
        AppShortcut(
            intent: TeachBuddyPlanningIntent(),
            phrases: [
                "Teach \(.applicationName) Buddy planning",
                "Plan my day with \(.applicationName)",
                "Train Buddy in \(.applicationName)"
            ],
            shortTitle: "Teach Buddy",
            systemImageName: "sparkle.magnifyingglass"
        )
    }
}
