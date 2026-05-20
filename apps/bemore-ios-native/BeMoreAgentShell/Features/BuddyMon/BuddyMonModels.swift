import Foundation

// MARK: - BuddyMon legal/IP boundary
//
// BuddyMon is original Prismtek/Buddy IP. The care, training, evolution, and battle
// mechanics are genre-level virtual-pet mechanics; names, forms, terminology, art,
// and progression data are intentionally original and must not copy licensed monster IP.

enum BuddyMonLifeStage: String, Codable, CaseIterable, Identifiable {
    case egg
    case hatchling
    case rookie
    case variant

    var id: String { rawValue }

    var displayName: String {
        switch self {
        case .egg: return "Egg"
        case .hatchling: return "Hatchling"
        case .rookie: return "Rookie"
        case .variant: return "Variant"
        }
    }
}

enum BuddyMonMood: String, Codable, CaseIterable, Identifiable {
    case idle
    case happy
    case hungry
    case sleepy
    case dirty
    case stressed
    case training
    case battle
    case evolving

    var id: String { rawValue }

    var label: String {
        switch self {
        case .idle: return "Idle"
        case .happy: return "Happy"
        case .hungry: return "Hungry"
        case .sleepy: return "Sleepy"
        case .dirty: return "Needs cleaning"
        case .stressed: return "Stressed"
        case .training: return "Training"
        case .battle: return "Battle ready"
        case .evolving: return "Evolving"
        }
    }
}

struct BuddyMonStats: Codable, Equatable {
    var hunger: Double
    var happiness: Double
    var hygiene: Double
    var energy: Double
    var strength: Double
    var bond: Double
    var discipline: Double
    var stress: Double
    var careMistakes: Int
    var battlesWon: Int
    var ageMinutes: Double

    static let starter = BuddyMonStats(
        hunger: 84,
        happiness: 74,
        hygiene: 88,
        energy: 68,
        strength: 18,
        bond: 18,
        discipline: 14,
        stress: 8,
        careMistakes: 0,
        battlesWon: 0,
        ageMinutes: 0
    )

    var averageCare: Double {
        (hunger + happiness + hygiene + energy + bond + discipline + max(0, 100 - stress)) / 7
    }

    var battlePower: Double {
        strength * 1.4 + bond * 0.8 + discipline * 0.6 + energy * 0.35 - stress * 0.4
    }

    var needsAttention: Bool {
        hunger < 35 || happiness < 35 || hygiene < 35 || energy < 20 || stress > 70
    }
}

struct BuddyMonMove: Codable, Identifiable, Equatable {
    let id: String
    let name: String
    let type: String
    let power: Int
    let accuracy: Int
    let energyCost: Int
}

struct BuddyMonForm: Codable, Identifiable, Equatable {
    let id: String
    let speciesID: String
    let name: String
    let stage: BuddyMonLifeStage
    let tagline: String
    let asciiArt: [String]
    let idleGlyph: String
    let moves: [BuddyMonMove]
}

struct BuddyMonPet: Codable, Identifiable, Equatable {
    let id: UUID
    var nickname: String
    var speciesID: String
    var formID: String
    var personality: String
    var mood: BuddyMonMood
    var stats: BuddyMonStats
    var createdAt: Date
    var lastUpdatedAt: Date
    var lastCareAt: Date
    var evolutionLog: [String]

    static func starterEgg(now: Date) -> BuddyMonPet {
        BuddyMonPet(
            id: UUID(),
            nickname: "Sproutbyte",
            speciesID: "sproutbyte",
            formID: "egg-sproutbyte",
            personality: "curious",
            mood: .idle,
            stats: .starter,
            createdAt: now,
            lastUpdatedAt: now,
            lastCareAt: now,
            evolutionLog: ["A tiny Prism Egg started humming."]
        )
    }
}

enum BuddyMonCareAction: String, Codable, CaseIterable, Identifiable {
    case feed
    case clean
    case play
    case rest
    case train
    case medicine

    var id: String { rawValue }

    var title: String {
        switch self {
        case .feed: return "Feed"
        case .clean: return "Clean"
        case .play: return "Play"
        case .rest: return "Rest"
        case .train: return "Train"
        case .medicine: return "Medicine"
        }
    }

    var systemImage: String {
        switch self {
        case .feed: return "fork.knife.circle.fill"
        case .clean: return "sparkles"
        case .play: return "gamecontroller.fill"
        case .rest: return "moon.zzz.fill"
        case .train: return "figure.run.circle.fill"
        case .medicine: return "cross.case.fill"
        }
    }
}

struct BuddyMonBattleResult: Codable, Identifiable, Equatable {
    let id: UUID
    let opponentName: String
    let result: String
    let summary: String
    let xpGained: Int
    let occurredAt: Date
}

struct BuddyMonGameState: Codable, Equatable {
    var version: String
    var activePet: BuddyMonPet
    var collection: [BuddyMonPet]
    var battleLog: [BuddyMonBattleResult]
    var lastNotificationAt: Date?
    var lastReceipt: String?

    static func newGame(now: Date) -> BuddyMonGameState {
        let pet = BuddyMonPet.starterEgg(now: now)
        return BuddyMonGameState(
            version: "0.1.0",
            activePet: pet,
            collection: [pet],
            battleLog: [],
            lastNotificationAt: nil,
            lastReceipt: "New Prism Egg received. Care for it to hatch Sproutbyte."
        )
    }
}

enum BuddyMonEngine {
    static let hatchAgeMinutes: Double = 2
    static let evolutionAgeMinutes: Double = 45

    static let starterMoves = [
        BuddyMonMove(id: "spark-nudge", name: "Spark Nudge", type: "spark", power: 12, accuracy: 96, energyCost: 8),
        BuddyMonMove(id: "leaf-guard", name: "Leaf Guard", type: "leaf", power: 8, accuracy: 100, energyCost: 6),
        BuddyMonMove(id: "heart-ping", name: "Heart Ping", type: "heart", power: 10, accuracy: 98, energyCost: 7)
    ]

    static let forms: [BuddyMonForm] = [
        BuddyMonForm(
            id: "egg-sproutbyte",
            speciesID: "sproutbyte",
            name: "Prism Egg",
            stage: .egg,
            tagline: "A warm pocket egg with a soft signal inside.",
            asciiArt: [
                "  .---.  ",
                " /     \\ ",
                "|  ◇ ◇  |",
                "|   ~   |",
                " \\_____/ "
            ],
            idleGlyph: "◇",
            moves: []
        ),
        BuddyMonForm(
            id: "sproutbyte",
            speciesID: "sproutbyte",
            name: "Sproutbyte",
            stage: .hatchling,
            tagline: "A little seed-signal Buddy that grows from consistent care.",
            asciiArt: [
                "   /\\   ",
                "  (..)  ",
                " <|  |> ",
                "  /__\\ "
            ],
            idleGlyph: "✦",
            moves: starterMoves
        ),
        BuddyMonForm(
            id: "bravebyte",
            speciesID: "sproutbyte",
            name: "Bravebyte",
            stage: .rookie,
            tagline: "A bold little guardian grown through training and trust.",
            asciiArt: [
                "  /\\_/\\ ",
                " ( •ᴗ• )",
                " /|⚔︎ |\\",
                "  /___\\ "
            ],
            idleGlyph: "⚔︎",
            moves: starterMoves + [BuddyMonMove(id: "courage-burst", name: "Courage Burst", type: "spark", power: 20, accuracy: 90, energyCost: 14)]
        ),
        BuddyMonForm(
            id: "glowpetal",
            speciesID: "sproutbyte",
            name: "Glowpetal",
            stage: .rookie,
            tagline: "A gentle bloom Buddy raised through happiness and clean care.",
            asciiArt: [
                "  .✿.  ",
                " (•ᴗ•) ",
                " /|♡|\\ ",
                "  /_\\  "
            ],
            idleGlyph: "✿",
            moves: starterMoves + [BuddyMonMove(id: "kindle-bloom", name: "Kindle Bloom", type: "heart", power: 18, accuracy: 94, energyCost: 12)]
        ),
        BuddyMonForm(
            id: "glitchling",
            speciesID: "sproutbyte",
            name: "Glitchling",
            stage: .variant,
            tagline: "A weird but lovable variant born from stress and recovery.",
            asciiArt: [
                "  [@@]  ",
                " <(~~)> ",
                " /|##|\\",
                "  /__\\ "
            ],
            idleGlyph: "#",
            moves: starterMoves + [BuddyMonMove(id: "static-hop", name: "Static Hop", type: "glitch", power: 22, accuracy: 84, energyCost: 13)]
        )
    ]

    static func form(for formID: String) -> BuddyMonForm {
        forms.first(where: { $0.id == formID }) ?? forms[0]
    }

    static func tick(_ pet: BuddyMonPet, now: Date) -> BuddyMonPet {
        var updated = pet
        let elapsedMinutes = max(0, now.timeIntervalSince(updated.lastUpdatedAt) / 60)
        guard elapsedMinutes > 0 else { return updated }

        updated.stats.ageMinutes += elapsedMinutes
        updated.stats.hunger = clamp(updated.stats.hunger - elapsedMinutes * 0.16)
        updated.stats.happiness = clamp(updated.stats.happiness - elapsedMinutes * 0.045)
        updated.stats.hygiene = clamp(updated.stats.hygiene - elapsedMinutes * 0.06)
        updated.stats.energy = clamp(updated.stats.energy + elapsedMinutes * 0.10)
        updated.stats.stress = clamp(updated.stats.stress + elapsedMinutes * 0.025)

        if elapsedMinutes >= 180, updated.stats.needsAttention {
            let missedWindows = Int(elapsedMinutes / 180)
            updated.stats.careMistakes += min(3, max(1, missedWindows))
            updated.stats.stress = clamp(updated.stats.stress + Double(missedWindows) * 3)
        }

        updated.lastUpdatedAt = now
        updated.mood = mood(for: updated)
        return maybeEvolve(updated, now: now)
    }

    static func perform(_ action: BuddyMonCareAction, on pet: BuddyMonPet, now: Date) -> BuddyMonPet {
        var updated = tick(pet, now: now)

        switch action {
        case .feed:
            updated.stats.hunger = clamp(updated.stats.hunger + 24)
            updated.stats.happiness = clamp(updated.stats.happiness + 4)
            updated.stats.stress = clamp(updated.stats.stress - 3)
        case .clean:
            updated.stats.hygiene = clamp(updated.stats.hygiene + 30)
            updated.stats.happiness = clamp(updated.stats.happiness + 5)
            updated.stats.stress = clamp(updated.stats.stress - 4)
        case .play:
            updated.stats.happiness = clamp(updated.stats.happiness + 18)
            updated.stats.bond = clamp(updated.stats.bond + 8)
            updated.stats.energy = clamp(updated.stats.energy - 8)
            updated.stats.stress = clamp(updated.stats.stress - 8)
        case .rest:
            updated.stats.energy = clamp(updated.stats.energy + 28)
            updated.stats.stress = clamp(updated.stats.stress - 10)
        case .train:
            updated.stats.strength = clamp(updated.stats.strength + 12)
            updated.stats.discipline = clamp(updated.stats.discipline + 7)
            updated.stats.energy = clamp(updated.stats.energy - 14)
            updated.stats.hunger = clamp(updated.stats.hunger - 8)
            updated.mood = .training
        case .medicine:
            updated.stats.stress = clamp(updated.stats.stress - 18)
            updated.stats.happiness = clamp(updated.stats.happiness - 2)
            updated.stats.careMistakes = max(0, updated.stats.careMistakes - 1)
        }

        updated.stats.bond = clamp(updated.stats.bond + 2)
        updated.lastCareAt = now
        updated.lastUpdatedAt = now
        updated.mood = action == .train ? .training : mood(for: updated)
        return maybeEvolve(updated, now: now)
    }

    static func battle(_ pet: BuddyMonPet, now: Date) -> (BuddyMonPet, BuddyMonBattleResult) {
        var updated = tick(pet, now: now)
        let opponent = "Dust Bunny"
        let won = updated.stats.battlePower >= 82 || updated.stats.battlesWon == 0
        let xp = won ? 18 : 7

        if won {
            updated.stats.battlesWon += 1
            updated.stats.strength = clamp(updated.stats.strength + 8)
            updated.stats.bond = clamp(updated.stats.bond + 5)
            updated.stats.discipline = clamp(updated.stats.discipline + 3)
        } else {
            updated.stats.bond = clamp(updated.stats.bond + 3)
            updated.stats.stress = clamp(updated.stats.stress + 6)
        }

        updated.stats.energy = clamp(updated.stats.energy - 18)
        updated.stats.hunger = clamp(updated.stats.hunger - 10)
        updated.mood = .battle
        updated.lastUpdatedAt = now
        updated = maybeEvolve(updated, now: now)

        let result = BuddyMonBattleResult(
            id: UUID(),
            opponentName: opponent,
            result: won ? "victory" : "lesson",
            summary: won
                ? "\(updated.nickname) won a friendly pocket spar and gained confidence."
                : "\(updated.nickname) lost safely, learned a pattern, and still gained bond.",
            xpGained: xp,
            occurredAt: now
        )
        return (updated, result)
    }

    static func mood(for pet: BuddyMonPet) -> BuddyMonMood {
        if pet.formID.hasPrefix("egg") { return .idle }
        if pet.stats.stress > 70 { return .stressed }
        if pet.stats.hunger < 30 { return .hungry }
        if pet.stats.hygiene < 30 { return .dirty }
        if pet.stats.energy < 22 { return .sleepy }
        if pet.stats.happiness > 78 && pet.stats.bond > 45 { return .happy }
        return .idle
    }

    static func minutesUntilAttentionNeeded(for pet: BuddyMonPet) -> Double {
        let hungerMinutes = max(0, (pet.stats.hunger - 35) / 0.16)
        let hygieneMinutes = max(0, (pet.stats.hygiene - 35) / 0.06)
        let happyMinutes = max(0, (pet.stats.happiness - 35) / 0.045)
        let stressMinutes = max(0, (70 - pet.stats.stress) / 0.025)
        return max(20, min(hungerMinutes, hygieneMinutes, happyMinutes, stressMinutes))
    }

    private static func maybeEvolve(_ pet: BuddyMonPet, now: Date) -> BuddyMonPet {
        var updated = pet

        if updated.formID == "egg-sproutbyte", updated.stats.ageMinutes >= hatchAgeMinutes {
            updated.formID = "sproutbyte"
            updated.mood = .happy
            updated.evolutionLog.append("Sproutbyte hatched from the Prism Egg.")
            updated.lastUpdatedAt = now
            return updated
        }

        guard updated.formID == "sproutbyte", updated.stats.ageMinutes >= evolutionAgeMinutes else {
            return updated
        }

        let nextFormID: String?
        if updated.stats.stress >= 65 || updated.stats.careMistakes >= 4 {
            nextFormID = "glitchling"
        } else if updated.stats.strength >= 55 && updated.stats.bond >= 40 {
            nextFormID = "bravebyte"
        } else if updated.stats.happiness >= 70 && updated.stats.hygiene >= 70 {
            nextFormID = "glowpetal"
        } else {
            nextFormID = nil
        }

        if let nextFormID {
            let form = form(for: nextFormID)
            updated.formID = nextFormID
            updated.mood = .evolving
            updated.evolutionLog.append("Sproutbyte grew into \(form.name).")
            updated.lastUpdatedAt = now
        }
        return updated
    }

    private static func clamp(_ value: Double) -> Double {
        min(100, max(0, value))
    }
}
