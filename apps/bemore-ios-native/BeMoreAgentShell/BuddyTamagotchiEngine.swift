import Foundation

// MARK: - Tamagotchi State Models

struct BuddyPassiveState: Codable, Hashable {
    var energy: Int // 0-100, drains over time
    var mood: String // happy, neutral, lonely, neglected, excited
    var attention: Int // 0-100, measures interaction quality
    var lastInteractionAt: Date?
    var lastFedAt: Date?
    var streakDays: Int // consecutive daily check-ins
    var totalInteractions: Int
    var thriving: Bool // true when well-cared for
    var neglected: Bool // true when ignored too long
    var checkInPrompted: Bool // whether we've shown a check-in suggestion
}

struct BuddyDailyRhythm: Codable, Hashable {
    var morningCheckIn: Bool
    var eveningWindDown: Bool
    var trainingSessionsToday: Int
    var lastTrainingAt: Date?
    var dailyGoalMet: Bool
}

// MARK: - Tamagotchi Engine

enum BuddyTamagotchiEngine {
    
    // MARK: - Passive State Calculation
    
    static func calculateCurrentPassiveState(
        for instance: BuddyInstance,
        currentState: BuddyPassiveState,
        now: Date = .now
    ) -> BuddyPassiveState {
        var state = currentState
        let lastInteractionTime = state.lastInteractionAt ?? instance.state.lastActiveAt ?? now
        let hoursSinceInteraction = now.timeIntervalSince(lastInteractionTime) / 3600
        
        // Energy drift: drains ~5 per hour, faster if neglected
        let energyDecayRate = state.neglected ? 8.0 : 5.0
        let energyLoss = Int(hoursSinceInteraction * energyDecayRate)
        state.energy = max(0, min(100, state.energy - energyLoss))
        
        // Mood transitions based on time and care
        state.mood = calculateMood(
            energy: state.energy,
            attention: state.attention,
            hoursSinceInteraction: hoursSinceInteraction,
            streak: state.streakDays
        )
        
        // Attention slowly decays
        state.attention = max(0, state.attention - Int(hoursSinceInteraction * 2))
        
        // Neglect threshold: 24 hours without interaction
        state.neglected = hoursSinceInteraction > 24
        
        // Thriving threshold: high energy + recent interaction + streak
        state.thriving = state.energy > 70 && hoursSinceInteraction < 8 && state.streakDays > 0
        
        // Check-in prompt: after 12 hours no interaction
        state.checkInPrompted = hoursSinceInteraction > 12 && !state.checkInPrompted
        
        return state
    }
    
    static func calculateMood(energy: Int, attention: Int, hoursSinceInteraction: Double, streak: Int) -> String {
        if energy > 80 && streak > 2 {
            return "excited"
        } else if energy > 60 && hoursSinceInteraction < 8 {
            return "happy"
        } else if hoursSinceInteraction > 24 {
            return "neglected"
        } else if hoursSinceInteraction > 12 {
            return "lonely"
        } else if energy < 30 {
            return "tired"
        } else {
            return "neutral"
        }
    }
    
    // MARK: - Care Actions
    
    static func feed(
        instance: inout BuddyInstance,
        passiveState: inout BuddyPassiveState,
        now: Date = .now
    ) -> BuddyCareResult {
        // Can only feed every 4 hours
        if let lastFed = passiveState.lastFedAt,
           now.timeIntervalSince(lastFed) < 14400 {
            return .failure("\(instance.displayName) isn't hungry yet. Try again later.")
        }
        
        passiveState.energy = min(100, passiveState.energy + 25)
        passiveState.lastFedAt = now
        passiveState.lastInteractionAt = now
        passiveState.attention = min(100, passiveState.attention + 10)
        
        return .success("Fed \(instance.displayName). Energy restored!", mood: "happy")
    }
    
    static func play(
        instance: inout BuddyInstance,
        passiveState: inout BuddyPassiveState,
        now: Date = .now
    ) -> BuddyCareResult {
        passiveState.energy = max(0, passiveState.energy - 10) // Playing costs energy
        passiveState.attention = min(100, passiveState.attention + 25)
        passiveState.lastInteractionAt = now
        passiveState.totalInteractions += 1
        
        return .success("Played with \(instance.displayName). Bond strengthened!", mood: "excited")
    }
    
    static func train(
        instance: inout BuddyInstance,
        passiveState: inout BuddyPassiveState,
        skillFocus: String,
        now: Date = .now
    ) -> BuddyCareResult {
        passiveState.energy = max(0, passiveState.energy - 15)
        passiveState.attention = min(100, passiveState.attention + 20)
        passiveState.lastInteractionAt = now
        passiveState.totalInteractions += 1
        
        // Update proficiencies
        instance.progression.proficiencies.train(skill: skillFocus)
        
        return .success("Trained \(instance.displayName) in \(skillFocus). Skills improving!", mood: "working")
    }
    
    static func checkIn(
        instance: inout BuddyInstance,
        passiveState: inout BuddyPassiveState,
        rhythm: inout BuddyDailyRhythm,
        now: Date = .now
    ) -> BuddyCareResult {
        passiveState.lastInteractionAt = now
        
        // Calculate streak
        let calendar = Calendar.current
        if let lastInteraction = passiveState.lastInteractionAt,
           calendar.isDate(lastInteraction, inSameDayAs: calendar.date(byAdding: .day, value: -1, to: now)!) {
            passiveState.streakDays += 1
        } else if passiveState.lastInteractionAt == nil {
            passiveState.streakDays = 1
        }
        
        passiveState.checkInPrompted = false
        passiveState.attention = min(100, passiveState.attention + 15)
        
        let message = passiveState.streakDays > 1 
            ? "Daily check-in complete! \(passiveState.streakDays) day streak! 🔥"
            : "Daily check-in complete! Build your streak tomorrow."
        
        return .success(message, mood: "happy")
    }
    
    // MARK: - Daily Rhythm
    
    static func getDailyRhythm(for instance: BuddyInstance, passiveState: BuddyPassiveState, now: Date = .now) -> BuddyDailyRhythm {
        let calendar = Calendar.current
        let hour = calendar.component(.hour, from: now)
        
        return BuddyDailyRhythm(
            morningCheckIn: hour < 12 && passiveState.lastInteractionAt.map { calendar.isDate($0, inSameDayAs: now) } ?? false,
            eveningWindDown: hour > 18,
            trainingSessionsToday: instance.progression.proficiencies.currentFocus != nil ? 1 : 0,
            lastTrainingAt: passiveState.lastInteractionAt,
            dailyGoalMet: passiveState.energy > 50 && passiveState.attention > 30
        )
    }
    
    // MARK: - Suggestions
    
    static func getSuggestedAction(for passiveState: BuddyPassiveState) -> TamagotchiSuggestion {
        if passiveState.neglected {
            return .urgent("\(passiveState.mood.capitalized). Check in now or risk losing your streak!")
        } else if passiveState.energy < 30 {
            return .feed("Getting tired. Time for a snack!")
        } else if passiveState.attention < 40 {
            return .play("Feeling a bit lonely. Let's play!")
        } else if passiveState.streakDays > 0 {
            return .train("Ready to learn! Pick a skill to train.")
        } else {
            return .checkIn("Daily check-in available. Start your streak!")
        }
    }
}

enum BuddyCareResult {
    case success(String, mood: String)
    case failure(String)
}

enum TamagotchiSuggestion {
    case urgent(String)
    case feed(String)
    case play(String)
    case train(String)
    case checkIn(String)
    
    var priority: Int {
        switch self {
        case .urgent: return 3
        case .feed: return 2
        case .play: return 1
        case .train: return 0
        case .checkIn: return 0
        }
    }
    
    var message: String {
        switch self {
        case .urgent(let m), .feed(let m), .play(let m), .train(let m), .checkIn(let m):
            return m
        }
    }
}

// MARK: - Passive State Persistence

extension BuddyPassiveState {
    static let key = "BuddyPassiveStates"
    
    static func load(for instanceId: String, storage: UserDefaults = .standard) -> BuddyPassiveState {
        let all = storage.dictionary(forKey: key) as? [String: Data] ?? [:]
        guard let data = all[instanceId],
              let state = try? JSONDecoder().decode(BuddyPassiveState.self, from: data) else {
            return BuddyPassiveState(
                energy: 75,
                mood: "neutral",
                attention: 50,
                lastInteractionAt: nil,
                lastFedAt: nil,
                streakDays: 0,
                totalInteractions: 0,
                thriving: false,
                neglected: false,
                checkInPrompted: false
            )
        }
        return state
    }
    
    func save(for instanceId: String, storage: UserDefaults = .standard) {
        var all = storage.dictionary(forKey: BuddyPassiveState.key) as? [String: Data] ?? [:]
        if let data = try? JSONEncoder().encode(self) {
            all[instanceId] = data
            storage.set(all, forKey: BuddyPassiveState.key)
        }
    }
}

// MARK: - UI Integration Helpers

struct BuddyTamagotchiMetrics {
    let energyBar: Double // 0.0-1.0
    let attentionBar: Double // 0.0-1.0
    let moodIcon: String
    let moodColor: String
    let streakText: String
    let statusBadge: String
    
    init(from passiveState: BuddyPassiveState) {
        self.energyBar = Double(passiveState.energy) / 100.0
        self.attentionBar = Double(passiveState.attention) / 100.0
        
        switch passiveState.mood {
        case "excited":
            self.moodIcon = "sparkles"
            self.moodColor = "accent"
            self.statusBadge = "Thriving"
        case "happy":
            self.moodIcon = "smiley.fill"
            self.moodColor = "success"
            self.statusBadge = "Happy"
        case "working":
            self.moodIcon = "brain.head.profile"
            self.moodColor = "accent"
            self.statusBadge = "Focused"
        case "tired":
            self.moodIcon = "moon.fill"
            self.moodColor = "warning"
            self.statusBadge = "Tired"
        case "lonely":
            self.moodIcon = "person.slash"
            self.moodColor = "warning"
            self.statusBadge = "Lonely"
        case "neglected":
            self.moodIcon = "exclamationmark.triangle.fill"
            self.moodColor = "error"
            self.statusBadge = "Needs Care"
        default:
            self.moodIcon = "face.smiling"
            self.moodColor = "neutral"
            self.statusBadge = "Neutral"
        }
        
        self.streakText = passiveState.streakDays > 0 ? "\(passiveState.streakDays)🔥" : "Start streak"
    }
}
