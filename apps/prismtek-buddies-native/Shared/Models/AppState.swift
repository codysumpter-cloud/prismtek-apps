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
        flash(.jumping, for: 2.5, thenReturnTo: .idle)
    }

    func greeted() { flash(.waving, for: 2.0) }

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
