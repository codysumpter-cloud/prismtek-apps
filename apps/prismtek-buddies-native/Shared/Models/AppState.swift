import Foundation
import SwiftUI
import Combine

/// Buddy animation states. Maps app events to Bitbud atlas rows.
enum BuddyState: String, CaseIterable {
    case idle
    case waving
    case waiting
    case running
    case review
    case failed
    case jumping
}

/// Central observable state for the cozy room. Persists tasks, memo, ambience and
/// progression via @AppStorage-backed UserDefaults JSON. Owns the buddy state and the
/// event -> buddy-state mapping.
@MainActor
final class AppState: ObservableObject {
    // MARK: Buddy
    @Published var buddyState: BuddyState = .idle

    // MARK: Interactive room
    /// Furniture/prop registry loaded from default-room-objects.json at launch.
    @Published var roomObjects: [RoomObject] = []
    /// Currently selected object id (for the accent outline / scale state). nil = none.
    @Published var selectedObjectID: String? = nil
    /// Bitbud's normalized position in the room (feet anchor). Animated on interaction.
    @Published var buddyAnchor: CGPoint = CGPoint(x: 0.52, y: 0.80)
    /// Human-readable label of the current action, e.g. "Bitbud is sitting". Empty = idle.
    @Published var actionLabel: String = ""

    // MARK: Tasks (JSON-encoded in UserDefaults)
    @Published var tasks: [BuddyTask] = [] {
        didSet { persistTasks() }
    }

    // MARK: Memo
    @AppStorage("buddy.memo") var memo: String = ""

    // MARK: Ambience toggles
    @AppStorage("buddy.ambience.rain") var rainOn: Bool = false
    @AppStorage("buddy.ambience.keyboard") var keyboardOn: Bool = false
    @AppStorage("buddy.ambience.fireplace") var fireplaceOn: Bool = false
    @AppStorage("buddy.ambience.cafe") var cafeOn: Bool = false

    // MARK: Progression (JSON-encoded in UserDefaults)
    @Published var progression: Progression = Progression() {
        didSet { persistProgression() }
    }
    /// Set true briefly after crossing a gift threshold; UI shows a placeholder banner.
    @Published var showGiftUnlock: Bool = false

    private let tasksKey = "buddy.tasks.json"
    private let progressionKey = "buddy.progression.json"
    private var revertTask: DispatchWorkItem?

    init() {
        loadTasks()
        loadProgression()
        roomObjects = RoomObject.loadDefaultRoom()
    }

    // MARK: - Buddy state transitions

    /// Set a transient buddy state that reverts to a base state after `seconds`.
    func flash(_ state: BuddyState, for seconds: Double = 2.0, thenReturnTo base: BuddyState = .idle) {
        revertTask?.cancel()
        buddyState = state
        let work = DispatchWorkItem { [weak self] in
            guard let self else { return }
            // Only revert if nothing else changed the state in the meantime.
            if self.buddyState == state { self.buddyState = base }
        }
        revertTask = work
        DispatchQueue.main.asyncAfter(deadline: .now() + seconds, execute: work)
    }

    func setBuddy(_ state: BuddyState) {
        revertTask?.cancel()
        buddyState = state
    }

    // MARK: - Buddy action controller (object kind -> interaction -> state + label)

    /// Maps a `BuddyInteraction` to the Bitbud animation row that best represents it.
    /// Some interactions have no dedicated atlas row yet and reuse the closest match
    /// (see TODOs — a future pet atlas can add sit/sleep/dance/etc.).
    static func state(for interaction: BuddyInteraction) -> BuddyState {
        switch interaction {
        case .sit:        return .waiting   // TODO: dedicated sit animation in future pet atlas
        case .work:       return .running
        case .rest:       return .waiting
        case .wave:       return .waving
        case .inspect:    return .review
        case .waterPlant: return .review    // TODO: dedicated watering animation in future pet atlas
        case .listen:     return .waving    // TODO: dedicated listen/bop animation in future pet atlas
        case .celebrate:  return .jumping
        case .wait:       return .waiting
        }
    }

    /// Human-readable label for an interaction at a named object.
    static func label(for interaction: BuddyInteraction, objectName: String) -> String {
        switch interaction {
        case .sit:        return "Bitbud is sitting"
        case .work:       return "Bitbud is working at the \(objectName.lowercased())"
        case .rest:       return "Bitbud is resting"
        case .wave:       return "Bitbud waves hello"
        case .inspect:    return "Bitbud is inspecting the \(objectName.lowercased())"
        case .waterPlant: return "Bitbud waters the plant"
        case .listen:     return "Bitbud is listening to music"
        case .celebrate:  return "Bitbud is celebrating!"
        case .wait:       return "Bitbud is waiting"
        }
    }

    /// Handle a tap on a room object: select it, move Bitbud to its anchor, set the
    /// animation state, and surface an action label.
    func interact(with object: RoomObject) {
        selectedObjectID = object.id
        buddyAnchor = object.buddyAnchor
        setBuddy(AppState.state(for: object.interaction))
        actionLabel = AppState.label(for: object.interaction, objectName: object.name)
    }

    /// Manual emote (from the emote buttons). Sets the Bitbud state + a label, and
    /// clears any object selection so the room shows a neutral selected state.
    func emote(_ interaction: BuddyInteraction) {
        selectedObjectID = nil
        let label: String
        switch interaction {
        case .wave:       label = "Bitbud waves hello"
        case .celebrate:  label = "Bitbud is celebrating!"
        case .inspect:    label = "Bitbud is thinking it over"
        case .work:       label = "Bitbud is working"
        case .wait:       label = "Bitbud is waiting"
        case .sit:        label = "Bitbud is sitting"
        case .rest:       label = "Bitbud is resting"
        case .listen:     label = "Bitbud is listening"
        case .waterPlant: label = "Bitbud waters the plant"
        }
        setBuddy(AppState.state(for: interaction))
        actionLabel = label
    }

    /// Manual "fail/sad" emote — distinct because it maps to the `.failed` row directly.
    func emoteFailed() {
        selectedObjectID = nil
        setBuddy(.failed)
        actionLabel = "Bitbud feels sad"
    }

    // MARK: - Events (wired from views)

    func timerStarted() { setBuddy(.running) }
    func timerPaused() { setBuddy(.waiting) }
    func timerReset() { setBuddy(.idle) }

    func focusSessionCompleted() {
        let previous = progression.focusSessions
        progression.completeFocusSession()
        if progression.justUnlockedGift(previousSessions: previous) {
            showGiftUnlock = true
        }
        // focus complete -> celebrate -> jumping
        selectedObjectID = nil
        actionLabel = "Bitbud is celebrating a finished focus session!"
        flash(.jumping, for: 2.5, thenReturnTo: .idle)
    }

    func greeted() {
        actionLabel = "Bitbud waves hello"
        flash(.waving, for: 2.0)
    }

    func ambienceToggled(on: Bool) {
        if on { flash(.waving, for: 1.5) }
    }

    // MARK: - Tasks

    func addTask(_ title: String) {
        let trimmed = title.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return }
        tasks.append(BuddyTask(title: trimmed))
    }

    func toggleDone(_ task: BuddyTask) {
        guard let idx = tasks.firstIndex(where: { $0.id == task.id }) else { return }
        tasks[idx].isDone.toggle()
        if tasks[idx].isDone {
            flash(.review, for: 1.5)
        }
    }

    func deleteTask(_ task: BuddyTask) {
        tasks.removeAll { $0.id == task.id }
        // delete/fail task -> failed
        selectedObjectID = nil
        actionLabel = "Bitbud reacts to a deleted task"
        flash(.failed, for: 1.5)
    }

    func reviewingTasks() { setBuddy(.review) }

    // MARK: - Persistence

    private func persistTasks() {
        if let data = try? JSONEncoder().encode(tasks) {
            UserDefaults.standard.set(data, forKey: tasksKey)
        }
    }

    private func loadTasks() {
        guard let data = UserDefaults.standard.data(forKey: tasksKey),
              let decoded = try? JSONDecoder().decode([BuddyTask].self, from: data) else { return }
        tasks = decoded
    }

    private func persistProgression() {
        if let data = try? JSONEncoder().encode(progression) {
            UserDefaults.standard.set(data, forKey: progressionKey)
        }
    }

    private func loadProgression() {
        guard let data = UserDefaults.standard.data(forKey: progressionKey),
              let decoded = try? JSONDecoder().decode(Progression.self, from: data) else { return }
        progression = decoded
    }
}
