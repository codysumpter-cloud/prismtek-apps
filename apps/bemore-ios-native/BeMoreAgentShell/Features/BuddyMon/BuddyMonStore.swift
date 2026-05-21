import Foundation
import UserNotifications

struct BuddyMonPersistenceStore {
    private let encoder: JSONEncoder = {
        let encoder = JSONEncoder()
        encoder.outputFormatting = [.prettyPrinted, .sortedKeys]
        encoder.dateEncodingStrategy = .iso8601
        return encoder
    }()

    private let decoder: JSONDecoder = {
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        return decoder
    }()

    var stateURL: URL {
        Paths.stateDirectory.appendingPathComponent("buddymon-state.json")
    }

    func load() -> BuddyMonGameState? {
        guard let data = try? Data(contentsOf: stateURL) else { return nil }
        return try? decoder.decode(BuddyMonGameState.self, from: data)
    }

    func persist(_ state: BuddyMonGameState) throws {
        let data = try encoder.encode(state)
        try FileManager.default.createDirectory(at: stateURL.deletingLastPathComponent(), withIntermediateDirectories: true)
        try data.write(to: stateURL, options: [.atomic])
    }
}

@MainActor
final class BuddyMonStore: ObservableObject {
    @Published private(set) var state: BuddyMonGameState
    @Published private(set) var saveError: String?

    private let persistence = BuddyMonPersistenceStore()
    private let notificationCenter: UNUserNotificationCenter

    init(now: Date = Date(), notificationCenter: UNUserNotificationCenter = .current()) {
        self.notificationCenter = notificationCenter
        self.state = persistence.load() ?? BuddyMonGameState.newGame(now: now)
        self.state.activePet = BuddyMonEngine.tick(self.state.activePet, now: now)
        self.state.collection = syncCollection(self.state.collection, activePet: self.state.activePet)
        try? persistence.persist(self.state)
    }

    var activePet: BuddyMonPet {
        state.activePet
    }

    var activeForm: BuddyMonForm {
        BuddyMonEngine.form(for: state.activePet.formID)
    }

    var attentionSummary: String {
        let pet = state.activePet
        if pet.formID.hasPrefix("egg") { return "Egg is warming up. Keep it nearby." }
        if pet.stats.hunger < 30 { return "Hungry. A snack would help." }
        if pet.stats.hygiene < 30 { return "Messy. Needs a clean-up." }
        if pet.stats.energy < 22 { return "Sleepy. Rest is the play." }
        if pet.stats.stress > 70 { return "Overloaded. Medicine or rest will calm it." }
        return "Stable and ready for gentle growth."
    }

    func refresh(now: Date = Date()) {
        mutate(now: now) { state in
            state.activePet = BuddyMonEngine.tick(state.activePet, now: now)
            state.lastReceipt = "Updated offline care drift."
        }
    }

    func reset(now: Date = Date()) {
        state = BuddyMonGameState.newGame(now: now)
        persist()
    }

    func perform(_ action: BuddyMonCareAction, now: Date = Date()) {
        mutate(now: now) { state in
            let before = state.activePet.formID
            state.activePet = BuddyMonEngine.perform(action, on: state.activePet, now: now)
            let after = state.activePet.formID
            let evolvedText = before == after ? "" : " Evolution triggered."
            state.lastReceipt = "\(action.title) completed for \(state.activePet.nickname).\(evolvedText)"
        }
        scheduleAttentionNotificationIfAllowed(now: now)
    }

    func runBattle(now: Date = Date()) {
        mutate(now: now) { state in
            let outcome = BuddyMonEngine.battle(state.activePet, now: now)
            state.activePet = outcome.0
            state.battleLog.insert(outcome.1, at: 0)
            state.battleLog = Array(state.battleLog.prefix(20))
            state.lastReceipt = outcome.1.summary
        }
        scheduleAttentionNotificationIfAllowed(now: now)
    }

    private func mutate(now: Date, update: (inout BuddyMonGameState) -> Void) {
        var next = state
        update(&next)
        next.activePet.lastUpdatedAt = now
        if next.activePet.mood != .evolving, next.activePet.mood != .training, next.activePet.mood != .battle {
            next.activePet.mood = BuddyMonEngine.mood(for: next.activePet)
        }
        next.collection = syncCollection(next.collection, activePet: next.activePet)
        state = next
        persist()
    }

    private func persist() {
        do {
            try persistence.persist(state)
            saveError = nil
        } catch {
            saveError = error.localizedDescription
        }
    }

    private func syncCollection(_ collection: [BuddyMonPet], activePet: BuddyMonPet) -> [BuddyMonPet] {
        var next = collection.filter { $0.id != activePet.id }
        next.insert(activePet, at: 0)
        return next
    }

    private func scheduleAttentionNotificationIfAllowed(now: Date) {
        guard !state.activePet.formID.hasPrefix("egg") else { return }
        guard state.activePet.stats.needsAttention == false else { return }
        if let lastNotificationAt = state.lastNotificationAt, now.timeIntervalSince(lastNotificationAt) < 60 * 60 * 3 {
            return
        }

        let center = notificationCenter
        let minutes = BuddyMonEngine.minutesUntilAttentionNeeded(for: state.activePet)
        let content = UNMutableNotificationContent()
        content.title = "\(state.activePet.nickname) may need you soon"
        content.body = "Check hunger, hygiene, energy, and stress when you are free."
        content.sound = .default

        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: max(60 * 20, minutes * 60), repeats: false)
        let request = UNNotificationRequest(identifier: "buddymon-attention", content: content, trigger: trigger)
        center.requestAuthorization(options: [.alert, .sound, .badge]) { granted, _ in
            guard granted else { return }
            center.removePendingNotificationRequests(withIdentifiers: ["buddymon-attention"])
            center.add(request)
        }

        state.lastNotificationAt = now
        persist()
    }
}
