import SwiftUI

// MARK: - Pixel Fruit Arena Prototype
// Original arena-fighter MVP. No copyrighted names, characters, locations, or assets.
// To add a fruit, create a PixelFruitKind case, add metadata in PixelFruitLibrary,
// and map its three specials in PixelFruitArenaStore.performSpecial(_:for:).

enum PixelArenaScreen {
    case menu
    case characterCreator
    case fruitSelect
    case matchSetup
    case match
}

enum PixelPalette: String, Codable, CaseIterable, Identifiable {
    case ember
    case sky
    case moss
    case grape
    case cocoa
    case moon

    var id: String { rawValue }

    var displayName: String {
        switch self {
        case .ember: return "Ember"
        case .sky: return "Sky"
        case .moss: return "Moss"
        case .grape: return "Grape"
        case .cocoa: return "Cocoa"
        case .moon: return "Moon"
        }
    }

    var color: Color {
        switch self {
        case .ember: return Color(red: 0.92, green: 0.28, blue: 0.20)
        case .sky: return Color(red: 0.25, green: 0.62, blue: 0.95)
        case .moss: return Color(red: 0.26, green: 0.72, blue: 0.34)
        case .grape: return Color(red: 0.55, green: 0.34, blue: 0.92)
        case .cocoa: return Color(red: 0.55, green: 0.34, blue: 0.20)
        case .moon: return Color(red: 0.86, green: 0.86, blue: 0.78)
        }
    }
}

struct PixelFighterProfile: Codable, Hashable {
    var name: String
    var bodyPalette: PixelPalette
    var hairPalette: PixelPalette
    var outfitPalette: PixelPalette

    static let starter = PixelFighterProfile(
        name: "Buddy Brawler",
        bodyPalette: .moon,
        hairPalette: .grape,
        outfitPalette: .sky
    )
}

enum PixelFruitKind: String, Codable, CaseIterable, Identifiable, Hashable {
    case flame
    case frost
    case volt
    case shadow
    case rubber
    case gravity

    var id: String { rawValue }
}

struct FruitAbilityDefinition: Identifiable, Hashable {
    let id: String
    let name: String
    let summary: String
}

struct FruitMastery: Codable, Hashable, Identifiable {
    var fruit: PixelFruitKind
    var level: Int
    var experience: Int
    var id: PixelFruitKind { fruit }
}

struct PixelFruitDefinition: Identifiable {
    let kind: PixelFruitKind
    let displayName: String
    let themeColor: Color
    let passive: String
    let abilities: [FruitAbilityDefinition]
    var id: PixelFruitKind { kind }
}

enum PixelFruitLibrary {
    static let all: [PixelFruitDefinition] = [
        PixelFruitDefinition(kind: .flame, displayName: "Flame Fruit", themeColor: .orange, passive: "Burn hits add extra launch pressure.", abilities: [
            FruitAbilityDefinition(id: "flame-projectile", name: "Fire Projectile", summary: "Fast ember shot."),
            FruitAbilityDefinition(id: "flame-dash", name: "Flame Dash", summary: "Forward burst with a hot trail."),
            FruitAbilityDefinition(id: "burn-hit", name: "Burn Hit", summary: "Close-range burst with burn stun.")
        ]),
        PixelFruitDefinition(kind: .frost, displayName: "Frost Fruit", themeColor: .cyan, passive: "Creates zones that slow fighters.", abilities: [
            FruitAbilityDefinition(id: "ice-spike", name: "Ice Spike", summary: "Rising spike projectile."),
            FruitAbilityDefinition(id: "freeze-zone", name: "Freeze Zone", summary: "Lingering cold field."),
            FruitAbilityDefinition(id: "slippery-dash", name: "Slippery Dash", summary: "Low-friction sliding strike.")
        ]),
        PixelFruitDefinition(kind: .volt, displayName: "Volt Fruit", themeColor: .yellow, passive: "Lightning links nearby targets.", abilities: [
            FruitAbilityDefinition(id: "lightning-bolt", name: "Lightning Bolt", summary: "Instant horizontal zap."),
            FruitAbilityDefinition(id: "blink-dash", name: "Blink Dash", summary: "Short teleport poke."),
            FruitAbilityDefinition(id: "chain-shock", name: "Chain Shock", summary: "Area shock with chain knockback.")
        ]),
        PixelFruitDefinition(kind: .shadow, displayName: "Shadow Fruit", themeColor: .purple, passive: "Null fields briefly disrupt movement.", abilities: [
            FruitAbilityDefinition(id: "pull-field", name: "Pull Field", summary: "Draws enemies inward."),
            FruitAbilityDefinition(id: "dark-burst", name: "Dark Burst", summary: "Short-range blast."),
            FruitAbilityDefinition(id: "null-effect", name: "Null Effect", summary: "Stops momentum nearby."),
        ]),
        PixelFruitDefinition(kind: .rubber, displayName: "Rubber Fruit", themeColor: .pink, passive: "Elastic attacks bounce and recover well.", abilities: [
            FruitAbilityDefinition(id: "stretch-punch", name: "Stretch Punch", summary: "Long straight punch."),
            FruitAbilityDefinition(id: "bounce-jump", name: "Bounce Jump", summary: "Huge vertical rebound."),
            FruitAbilityDefinition(id: "giant-fist", name: "Giant Fist", summary: "Slow heavy smack."),
        ]),
        PixelFruitDefinition(kind: .gravity, displayName: "Gravity Fruit", themeColor: .indigo, passive: "Controls enemy vertical space.", abilities: [
            FruitAbilityDefinition(id: "gravity-pull", name: "Pull", summary: "Drags targets toward you."),
            FruitAbilityDefinition(id: "gravity-slam", name: "Slam", summary: "Drops nearby fighters downward."),
            FruitAbilityDefinition(id: "float-heavy", name: "Floating Heavy", summary: "Hovering heavy strike."),
        ]),
    ]

    static func definition(for kind: PixelFruitKind) -> PixelFruitDefinition {
        all.first { $0.kind == kind } ?? all[0]
    }
}

struct ArenaPlatform: Identifiable {
    let id = UUID()
    let rect: CGRect
}

struct PixelArenaStage: Identifiable {
    let id: String
    let name: String
    let size: CGSize
    let spawnPoints: [CGPoint]
    let platforms: [ArenaPlatform]
    let hazard: CGRect

    static let prismPier = PixelArenaStage(
        id: "prism-pier",
        name: "Prism Pier",
        size: CGSize(width: 900, height: 520),
        spawnPoints: [
            CGPoint(x: 230, y: 300), CGPoint(x: 670, y: 300),
            CGPoint(x: 360, y: 190), CGPoint(x: 540, y: 190)
        ],
        platforms: [
            ArenaPlatform(rect: CGRect(x: 190, y: 390, width: 520, height: 34)),
            ArenaPlatform(rect: CGRect(x: 250, y: 275, width: 160, height: 22)),
            ArenaPlatform(rect: CGRect(x: 490, y: 275, width: 160, height: 22)),
            ArenaPlatform(rect: CGRect(x: 375, y: 170, width: 150, height: 20))
        ],
        hazard: CGRect(x: 415, y: 424, width: 70, height: 24)
    )
}

struct VisibleEffect: Identifiable {
    let id = UUID()
    var origin: CGPoint
    var velocity: CGVector
    var size: CGSize
    var color: Color
    var label: String
    var remaining: Double
    var damage: Double
    var knockback: Double
    var ownerID: Int
    var pulls: Bool = false
    var freezes: Bool = false
    var nulls: Bool = false
}

struct ArenaPlayerState: Identifiable {
    let id: Int
    var profile: PixelFighterProfile
    var fruit: PixelFruitKind
    var mastery: FruitMastery
    var position: CGPoint
    var velocity: CGVector = .zero
    var damage: Double = 0
    var stocks: Int = 3
    var hitStun: Double = 0
    var respawnTimer: Double = 0
    var facing: CGFloat = 1
    var isCPU: Bool = false
    var specialCooldowns: [Double] = [0, 0, 0]
    var statusText: String = "Ready"

    var isOut: Bool { stocks <= 0 }
    var isRespawning: Bool { respawnTimer > 0 }
}

@MainActor
final class PixelFruitArenaStore: ObservableObject {
    @Published var screen: PixelArenaScreen = .menu
    @Published var profile: PixelFighterProfile = .starter
    @Published var unlockedFruits: Set<PixelFruitKind> = Set(PixelFruitKind.allCases)
    @Published var mastery: [FruitMastery] = PixelFruitKind.allCases.map { FruitMastery(fruit: $0, level: 1, experience: 0) }
    @Published var selectedFruit: PixelFruitKind = .flame
    @Published var localPlayerCount: Int = 2
    @Published var players: [ArenaPlayerState] = []
    @Published var effects: [VisibleEffect] = []
    @Published var matchTimeRemaining: Double = 180
    @Published var message: String = "Choose a fruit and start a match."

    let stage = PixelArenaStage.prismPier
    private let tickSeconds = 1.0 / 30.0
    private var cpuAttackClock: Double = 0

    var selectedFruitDefinition: PixelFruitDefinition { PixelFruitLibrary.definition(for: selectedFruit) }

    func mastery(for fruit: PixelFruitKind) -> FruitMastery {
        mastery.first { $0.fruit == fruit } ?? FruitMastery(fruit: fruit, level: 1, experience: 0)
    }

    func unlock(_ fruit: PixelFruitKind) {
        unlockedFruits.insert(fruit)
        if !mastery.contains(where: { $0.fruit == fruit }) {
            mastery.append(FruitMastery(fruit: fruit, level: 1, experience: 0))
        }
    }

    func equip(_ fruit: PixelFruitKind) {
        guard unlockedFruits.contains(fruit) else { return }
        selectedFruit = fruit
        message = "Equipped \(PixelFruitLibrary.definition(for: fruit).displayName)."
    }

    func startMatch() {
        effects.removeAll()
        matchTimeRemaining = 180
        players = (0..<4).map { index in
            let fruit = index == 0 ? selectedFruit : PixelFruitKind.allCases[index % PixelFruitKind.allCases.count]
            return ArenaPlayerState(
                id: index + 1,
                profile: index == 0 ? profile : PixelFighterProfile(
                    name: "CPU \(index + 1)",
                    bodyPalette: PixelPalette.allCases[index % PixelPalette.allCases.count],
                    hairPalette: PixelPalette.allCases[(index + 2) % PixelPalette.allCases.count],
                    outfitPalette: PixelPalette.allCases[(index + 3) % PixelPalette.allCases.count]
                ),
                fruit: fruit,
                mastery: mastery(for: fruit),
                position: stage.spawnPoints[index],
                isCPU: index >= localPlayerCount
            )
        }
        message = "Battle on \(stage.name)!"
        screen = .match
    }

    func tick() {
        guard screen == .match else { return }
        matchTimeRemaining = max(0, matchTimeRemaining - tickSeconds)
        cpuAttackClock += tickSeconds
        advanceEffects()
        for index in players.indices {
            advancePlayer(at: index)
        }
        runCPUPlaceholders()
        if matchTimeRemaining <= 0 || players.filter({ !$0.isOut }).count <= 1 {
            message = winningMessage()
        }
    }

    func move(playerID: Int, direction: CGFloat) {
        guard let index = players.firstIndex(where: { $0.id == playerID }), !players[index].isOut else { return }
        players[index].velocity.dx = direction * 7
        if direction != 0 { players[index].facing = direction > 0 ? 1 : -1 }
        players[index].statusText = direction == 0 ? "Ready" : "Moving"
    }

    func jump(playerID: Int) {
        guard let index = players.firstIndex(where: { $0.id == playerID }), !players[index].isOut else { return }
        if isGrounded(players[index]) {
            players[index].velocity.dy = -15
            players[index].statusText = "Jump"
        }
    }

    func dodge(playerID: Int) {
        guard let index = players.firstIndex(where: { $0.id == playerID }), !players[index].isOut else { return }
        players[index].velocity.dx = -players[index].facing * 12
        players[index].hitStun = 0
        players[index].statusText = "Dodge"
    }

    func basicAttack(playerID: Int) {
        guard let player = players.first(where: { $0.id == playerID }), !player.isOut else { return }
        let point = CGPoint(x: player.position.x + player.facing * 38, y: player.position.y - 26)
        spawnEffect(origin: point, velocity: .zero, size: CGSize(width: 54, height: 34), color: .white, label: "POW", duration: 0.16, damage: 7, knockback: 12, ownerID: playerID)
    }

    func special(_ slot: Int, playerID: Int) {
        guard let index = players.firstIndex(where: { $0.id == playerID }), !players[index].isOut else { return }
        guard slot >= 0 && slot < players[index].specialCooldowns.count else { return }
        guard players[index].specialCooldowns[slot] <= 0 else { return }
        players[index].specialCooldowns[slot] = [0.42, 0.62, 0.9][slot]
        performSpecial(slot, for: index)
    }

    private func performSpecial(_ slot: Int, for index: Int) {
        let player = players[index]
        let direction = player.facing
        let front = CGPoint(x: player.position.x + direction * 46, y: player.position.y - 30)
        let fruit = PixelFruitLibrary.definition(for: player.fruit)
        players[index].statusText = fruit.abilities[slot].name

        switch (player.fruit, slot) {
        case (.flame, 0):
            spawnEffect(origin: front, velocity: CGVector(dx: direction * 16, dy: 0), size: CGSize(width: 30, height: 20), color: .orange, label: "🔥", duration: 0.65, damage: 9, knockback: 17, ownerID: player.id)
        case (.flame, 1):
            players[index].velocity.dx = direction * 20
            spawnEffect(origin: player.position, velocity: .zero, size: CGSize(width: 92, height: 42), color: .orange, label: "DASH", duration: 0.22, damage: 8, knockback: 20, ownerID: player.id)
        case (.flame, 2):
            spawnEffect(origin: front, velocity: .zero, size: CGSize(width: 88, height: 58), color: .red, label: "BURN", duration: 0.28, damage: 13, knockback: 22, ownerID: player.id)
        case (.frost, 0):
            spawnEffect(origin: front, velocity: CGVector(dx: direction * 9, dy: -3), size: CGSize(width: 28, height: 48), color: .cyan, label: "ICE", duration: 0.7, damage: 8, knockback: 15, ownerID: player.id, freezes: true)
        case (.frost, 1):
            spawnEffect(origin: CGPoint(x: player.position.x + direction * 70, y: player.position.y - 6), velocity: .zero, size: CGSize(width: 132, height: 36), color: .cyan, label: "FREEZE", duration: 1.0, damage: 4, knockback: 6, ownerID: player.id, freezes: true)
        case (.frost, 2):
            players[index].velocity.dx = direction * 17
            players[index].velocity.dy = -3
            spawnEffect(origin: player.position, velocity: .zero, size: CGSize(width: 88, height: 30), color: .cyan, label: "SLIDE", duration: 0.32, damage: 7, knockback: 16, ownerID: player.id)
        case (.volt, 0):
            spawnEffect(origin: CGPoint(x: player.position.x + direction * 95, y: player.position.y - 34), velocity: .zero, size: CGSize(width: 160, height: 18), color: .yellow, label: "ZAP", duration: 0.18, damage: 10, knockback: 19, ownerID: player.id)
        case (.volt, 1):
            players[index].position.x += direction * 105
            spawnEffect(origin: players[index].position, velocity: .zero, size: CGSize(width: 70, height: 70), color: .yellow, label: "BLINK", duration: 0.22, damage: 7, knockback: 15, ownerID: player.id)
        case (.volt, 2):
            spawnEffect(origin: player.position, velocity: .zero, size: CGSize(width: 150, height: 95), color: .yellow, label: "CHAIN", duration: 0.28, damage: 12, knockback: 18, ownerID: player.id)
        case (.shadow, 0):
            spawnEffect(origin: front, velocity: .zero, size: CGSize(width: 150, height: 95), color: .purple, label: "PULL", duration: 0.8, damage: 2, knockback: -8, ownerID: player.id, pulls: true)
        case (.shadow, 1):
            spawnEffect(origin: front, velocity: .zero, size: CGSize(width: 95, height: 95), color: .purple, label: "BURST", duration: 0.24, damage: 12, knockback: 21, ownerID: player.id)
        case (.shadow, 2):
            spawnEffect(origin: player.position, velocity: .zero, size: CGSize(width: 125, height: 80), color: .black, label: "NULL", duration: 0.45, damage: 3, knockback: 2, ownerID: player.id, nulls: true)
        case (.rubber, 0):
            spawnEffect(origin: CGPoint(x: player.position.x + direction * 86, y: player.position.y - 26), velocity: .zero, size: CGSize(width: 145, height: 28), color: .pink, label: "STRETCH", duration: 0.22, damage: 9, knockback: 18, ownerID: player.id)
        case (.rubber, 1):
            players[index].velocity.dy = -22
            spawnEffect(origin: player.position, velocity: .zero, size: CGSize(width: 78, height: 44), color: .pink, label: "BOING", duration: 0.24, damage: 5, knockback: 14, ownerID: player.id)
        case (.rubber, 2):
            spawnEffect(origin: front, velocity: .zero, size: CGSize(width: 118, height: 88), color: .pink, label: "FIST", duration: 0.34, damage: 16, knockback: 29, ownerID: player.id)
        case (.gravity, 0):
            spawnEffect(origin: front, velocity: .zero, size: CGSize(width: 170, height: 120), color: .indigo, label: "PULL", duration: 0.75, damage: 3, knockback: -10, ownerID: player.id, pulls: true)
        case (.gravity, 1):
            spawnEffect(origin: CGPoint(x: player.position.x, y: player.position.y + 35), velocity: .zero, size: CGSize(width: 130, height: 120), color: .indigo, label: "SLAM", duration: 0.28, damage: 12, knockback: 25, ownerID: player.id)
        case (.gravity, 2):
            players[index].velocity.dy = -7
            spawnEffect(origin: front, velocity: CGVector(dx: 0, dy: 3), size: CGSize(width: 118, height: 70), color: .indigo, label: "HEAVY", duration: 0.45, damage: 15, knockback: 24, ownerID: player.id)
        default:
            break
        }
    }

    private func spawnEffect(origin: CGPoint, velocity: CGVector, size: CGSize, color: Color, label: String, duration: Double, damage: Double, knockback: Double, ownerID: Int, pulls: Bool = false, freezes: Bool = false, nulls: Bool = false) {
        effects.append(VisibleEffect(origin: origin, velocity: velocity, size: size, color: color, label: label, remaining: duration, damage: damage, knockback: knockback, ownerID: ownerID, pulls: pulls, freezes: freezes, nulls: nulls))
    }

    private func advanceEffects() {
        for effectIndex in effects.indices {
            effects[effectIndex].remaining -= tickSeconds
            effects[effectIndex].origin.x += effects[effectIndex].velocity.dx
            effects[effectIndex].origin.y += effects[effectIndex].velocity.dy
            apply(effect: effects[effectIndex])
        }
        effects.removeAll { $0.remaining <= 0 }
    }

    private func apply(effect: VisibleEffect) {
        let effectRect = CGRect(
            x: effect.origin.x - effect.size.width / 2,
            y: effect.origin.y - effect.size.height / 2,
            width: effect.size.width,
            height: effect.size.height
        )
        for index in players.indices where players[index].id != effect.ownerID && !players[index].isOut && !players[index].isRespawning {
            let targetRect = fighterRect(players[index])
            guard effectRect.intersects(targetRect) else { continue }
            let owner = players.first { $0.id == effect.ownerID }
            let direction = CGFloat(players[index].position.x >= (owner?.position.x ?? effect.origin.x) ? 1 : -1)
            if effect.nulls {
                players[index].velocity = .zero
                players[index].hitStun = max(players[index].hitStun, 0.18)
            } else if effect.pulls {
                players[index].velocity.dx -= direction * 4
                players[index].velocity.dy -= 1
            } else {
                players[index].damage += effect.damage * tickSeconds * 6
                let scaling = 1 + players[index].damage / 110
                players[index].velocity.dx = direction * CGFloat(effect.knockback * scaling)
                players[index].velocity.dy = CGFloat(-min(22, effect.knockback * 0.45 * scaling))
                players[index].hitStun = effect.freezes ? 0.5 : 0.22
            }
            if effect.freezes { players[index].statusText = "Frozen" }
        }
    }

    private func advancePlayer(at index: Int) {
        guard !players[index].isOut else { return }
        if players[index].respawnTimer > 0 {
            players[index].respawnTimer -= tickSeconds
            if players[index].respawnTimer <= 0 {
                players[index].position = stage.spawnPoints[(players[index].id - 1) % stage.spawnPoints.count]
                players[index].velocity = .zero
                players[index].damage = 0
                players[index].statusText = "Respawn"
            }
            return
        }

        for slot in players[index].specialCooldowns.indices {
            players[index].specialCooldowns[slot] = max(0, players[index].specialCooldowns[slot] - tickSeconds)
        }
        players[index].hitStun = max(0, players[index].hitStun - tickSeconds)
        players[index].velocity.dy += 0.85
        players[index].velocity.dx *= 0.88
        players[index].position.x += players[index].velocity.dx
        players[index].position.y += players[index].velocity.dy
        resolvePlatforms(for: index)
        applyHazardIfNeeded(index)
        ringOutIfNeeded(index)
    }

    private func resolvePlatforms(for index: Int) {
        var fighter = fighterRect(players[index])
        for platform in stage.platforms {
            let wasAbove = fighter.maxY - players[index].velocity.dy <= platform.rect.minY + 8
            if fighter.intersects(platform.rect), players[index].velocity.dy >= 0, wasAbove {
                players[index].position.y = platform.rect.minY
                players[index].velocity.dy = 0
                fighter = fighterRect(players[index])
            }
        }
    }

    private func applyHazardIfNeeded(_ index: Int) {
        guard fighterRect(players[index]).intersects(stage.hazard) else { return }
        players[index].damage += 0.22
        players[index].velocity.dy = min(players[index].velocity.dy, -4)
        players[index].statusText = "Hazard"
    }

    private func ringOutIfNeeded(_ index: Int) {
        let position = players[index].position
        let margin: CGFloat = 140
        guard position.x < -margin || position.x > stage.size.width + margin || position.y > stage.size.height + margin else { return }
        players[index].stocks -= 1
        players[index].respawnTimer = players[index].stocks > 0 ? 1.2 : 0
        players[index].statusText = players[index].stocks > 0 ? "Ring-out" : "KO"
    }

    private func runCPUPlaceholders() {
        guard cpuAttackClock >= 0.55 else { return }
        cpuAttackClock = 0
        for cpu in players.filter({ $0.isCPU && !$0.isOut && !$0.isRespawning }) {
            guard let target = players.first(where: { !$0.isCPU && !$0.isOut }) else { continue }
            let direction: CGFloat = target.position.x > cpu.position.x ? 1 : -1
            move(playerID: cpu.id, direction: direction)
            if abs(target.position.x - cpu.position.x) < 150 {
                special(Int.random(in: 0...2), playerID: cpu.id)
            } else if Int.random(in: 0...4) == 0 {
                jump(playerID: cpu.id)
            }
        }
    }

    private func isGrounded(_ player: ArenaPlayerState) -> Bool {
        let rect = fighterRect(player).offsetBy(dx: 0, dy: 4)
        return stage.platforms.contains { rect.intersects($0.rect) }
    }

    private func fighterRect(_ player: ArenaPlayerState) -> CGRect {
        CGRect(x: player.position.x - 17, y: player.position.y - 48, width: 34, height: 48)
    }

    private func winningMessage() -> String {
        let leader = players.max { left, right in
            if left.stocks == right.stocks { return left.damage > right.damage }
            return left.stocks < right.stocks
        }
        return leader.map { "\($0.profile.name) leads the arena!" } ?? "Match complete."
    }
}

struct PixelFruitArenaRootView: View {
    @StateObject private var store = PixelFruitArenaStore()
    private let timer = Timer.publish(every: 1.0 / 30.0, on: .main, in: .common).autoconnect()

    var body: some View {
        ZStack {
            LinearGradient(colors: [Color.black, Color(red: 0.08, green: 0.07, blue: 0.16)], startPoint: .top, endPoint: .bottom)
                .ignoresSafeArea()
            switch store.screen {
            case .menu:
                PixelArenaMenuView(store: store)
            case .characterCreator:
                PixelCharacterCreatorView(store: store)
            case .fruitSelect:
                PixelFruitSelectView(store: store)
            case .matchSetup:
                PixelMatchSetupView(store: store)
            case .match:
                PixelMatchView(store: store)
            }
        }
        .foregroundColor(.white)
        .onReceive(timer) { _ in store.tick() }
    }
}

struct PixelArenaMenuView: View {
    @ObservedObject var store: PixelFruitArenaStore

    var body: some View {
        VStack(spacing: 18) {
            Text("Pixel Fruit Arena")
                .font(.system(size: 38, weight: .black, design: .monospaced))
            Text("Original Mystic Fruit platform-fighting prototype")
                .font(.callout.monospaced())
                .foregroundColor(.white.opacity(0.75))
            PixelCharacterSprite(profile: store.profile, fruit: store.selectedFruit, scale: 3)
                .padding(.vertical, 12)
            PixelArenaButton(title: "Character Creator") { store.screen = .characterCreator }
            PixelArenaButton(title: "Fruit Select") { store.screen = .fruitSelect }
            PixelArenaButton(title: "Local Match Setup") { store.screen = .matchSetup }
            PixelArenaButton(title: "Start Match") { store.startMatch() }
            Text(store.message)
                .font(.caption.monospaced())
                .foregroundColor(.white.opacity(0.7))
                .multilineTextAlignment(.center)
        }
        .padding(24)
    }
}

struct PixelCharacterCreatorView: View {
    @ObservedObject var store: PixelFruitArenaStore

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 18) {
                PixelBackButton { store.screen = .menu }
                Text("Character Creator")
                    .font(.title.bold().monospaced())
                TextField("Fighter name", text: $store.profile.name)
                    .textFieldStyle(.roundedBorder)
                    .foregroundColor(.black)
                PixelCharacterSprite(profile: store.profile, fruit: store.selectedFruit, scale: 4)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.white.opacity(0.06))
                    .clipShape(RoundedRectangle(cornerRadius: 16))
                PalettePicker(title: "Body palette", selection: $store.profile.bodyPalette)
                PalettePicker(title: "Hair palette", selection: $store.profile.hairPalette)
                PalettePicker(title: "Outfit color", selection: $store.profile.outfitPalette)
                Text("Identity stays separate from fruit power: \(store.profile.name) can equip any unlocked fruit.")
                    .font(.caption.monospaced())
                    .foregroundColor(.white.opacity(0.72))
                PixelArenaButton(title: "Save Fighter") { store.screen = .fruitSelect }
            }
            .padding(20)
        }
    }
}

struct PixelFruitSelectView: View {
    @ObservedObject var store: PixelFruitArenaStore

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 14) {
                PixelBackButton { store.screen = .menu }
                Text("Mystic Fruit Select")
                    .font(.title.bold().monospaced())
                ForEach(PixelFruitLibrary.all) { fruit in
                    FruitCard(definition: fruit, unlocked: store.unlockedFruits.contains(fruit.kind), equipped: store.selectedFruit == fruit.kind, mastery: store.mastery(for: fruit.kind)) {
                        store.unlock(fruit.kind)
                        store.equip(fruit.kind)
                    }
                }
                PixelArenaButton(title: "Continue to Match Setup") { store.screen = .matchSetup }
            }
            .padding(20)
        }
    }
}

struct PixelMatchSetupView: View {
    @ObservedObject var store: PixelFruitArenaStore

    var body: some View {
        VStack(alignment: .leading, spacing: 18) {
            PixelBackButton { store.screen = .menu }
            Text("Local Match Setup")
                .font(.title.bold().monospaced())
            Text("Stage: \(store.stage.name)")
                .font(.headline.monospaced())
            Stepper("Local inputs: \(store.localPlayerCount) / 4", value: $store.localPlayerCount, in: 1...4)
                .font(.body.monospaced())
            Text("Unused slots spawn CPU placeholders. MVP controls use touch buttons, and controller/keyboard mapping can plug into PixelArenaInput later without changing fruit data.")
                .font(.caption.monospaced())
                .foregroundColor(.white.opacity(0.72))
            FruitMiniSummary(definition: store.selectedFruitDefinition, mastery: store.mastery(for: store.selectedFruit))
            PixelArenaButton(title: "Start Local Match") { store.startMatch() }
            Spacer()
        }
        .padding(20)
    }
}

struct PixelMatchView: View {
    @ObservedObject var store: PixelFruitArenaStore

    var body: some View {
        VStack(spacing: 8) {
            MatchHUD(store: store)
            GeometryReader { proxy in
                let scale = min(proxy.size.width / store.stage.size.width, proxy.size.height / store.stage.size.height)
                ZStack(alignment: .topLeading) {
                    PixelStageBackdrop()
                    ForEach(store.stage.platforms) { platform in
                        PixelRect(color: .mint)
                            .frame(width: platform.rect.width * scale, height: platform.rect.height * scale)
                            .position(x: platform.rect.midX * scale, y: platform.rect.midY * scale)
                    }
                    PixelRect(color: .red.opacity(0.65))
                        .frame(width: store.stage.hazard.width * scale, height: store.stage.hazard.height * scale)
                        .position(x: store.stage.hazard.midX * scale, y: store.stage.hazard.midY * scale)
                    ForEach(store.effects) { effect in
                        EffectView(effect: effect, scale: scale)
                    }
                    ForEach(store.players) { player in
                        VStack(spacing: 1) {
                            Text("P\(player.id)")
                                .font(.system(size: 8, weight: .bold, design: .monospaced))
                                .foregroundColor(.white)
                            PixelCharacterSprite(profile: player.profile, fruit: player.fruit, scale: 1.4)
                                .opacity(player.isRespawning ? 0.35 : 1)
                        }
                        .position(x: player.position.x * scale, y: (player.position.y - 28) * scale)
                    }
                }
                .frame(width: store.stage.size.width * scale, height: store.stage.size.height * scale)
                .clipShape(Rectangle())
                .overlay(Rectangle().stroke(Color.white.opacity(0.25), lineWidth: 2))
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            }
            PlayerOneControls(store: store)
        }
        .padding(10)
    }
}

struct MatchHUD: View {
    @ObservedObject var store: PixelFruitArenaStore

    var body: some View {
        VStack(spacing: 6) {
            HStack {
                PixelBackButton { store.screen = .menu }
                Spacer()
                Text("\(Int(store.matchTimeRemaining))s")
                    .font(.headline.monospacedDigit())
                Spacer()
                Text(store.message)
                    .font(.caption.monospaced())
                    .lineLimit(1)
            }
            LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 4), spacing: 6) {
                ForEach(store.players) { player in
                    VStack(alignment: .leading, spacing: 2) {
                        Text(player.profile.name)
                            .font(.caption2.bold().monospaced())
                            .lineLimit(1)
                        Text("\(PixelFruitLibrary.definition(for: player.fruit).displayName) · Lv \(player.mastery.level)")
                            .font(.system(size: 8, design: .monospaced))
                            .foregroundColor(.white.opacity(0.72))
                            .lineLimit(1)
                        Text("\(Int(player.damage))% · \(player.stocks) stock")
                            .font(.caption2.monospacedDigit())
                        Text(player.statusText)
                            .font(.system(size: 8, design: .monospaced))
                            .foregroundColor(.white.opacity(0.6))
                    }
                    .padding(6)
                    .background(PixelFruitLibrary.definition(for: player.fruit).themeColor.opacity(0.28))
                    .clipShape(RoundedRectangle(cornerRadius: 8))
                }
            }
        }
    }
}

struct PlayerOneControls: View {
    @ObservedObject var store: PixelFruitArenaStore

    var body: some View {
        VStack(spacing: 8) {
            HStack(spacing: 8) {
                PixelArenaButton(title: "◀︎") { store.move(playerID: 1, direction: -1) }
                PixelArenaButton(title: "Stop") { store.move(playerID: 1, direction: 0) }
                PixelArenaButton(title: "▶︎") { store.move(playerID: 1, direction: 1) }
                PixelArenaButton(title: "Jump") { store.jump(playerID: 1) }
            }
            HStack(spacing: 8) {
                PixelArenaButton(title: "Attack") { store.basicAttack(playerID: 1) }
                PixelArenaButton(title: "S1") { store.special(0, playerID: 1) }
                PixelArenaButton(title: "S2") { store.special(1, playerID: 1) }
                PixelArenaButton(title: "S3") { store.special(2, playerID: 1) }
                PixelArenaButton(title: "Dodge") { store.dodge(playerID: 1) }
            }
        }
    }
}

struct FruitCard: View {
    let definition: PixelFruitDefinition
    let unlocked: Bool
    let equipped: Bool
    let mastery: FruitMastery
    let action: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Circle().fill(definition.themeColor).frame(width: 18, height: 18)
                Text(definition.displayName)
                    .font(.headline.monospaced())
                Spacer()
                Text(equipped ? "Equipped" : unlocked ? "Unlocked" : "Locked")
                    .font(.caption.bold().monospaced())
            }
            Text(definition.passive)
                .font(.caption.monospaced())
                .foregroundColor(.white.opacity(0.72))
            ForEach(definition.abilities) { ability in
                Text("• \(ability.name): \(ability.summary)")
                    .font(.caption2.monospaced())
                    .foregroundColor(.white.opacity(0.72))
            }
            Text("Mastery Lv \(mastery.level) · XP \(mastery.experience)")
                .font(.caption2.monospacedDigit())
            PixelArenaButton(title: equipped ? "Ready" : "Unlock + Equip", action: action)
        }
        .padding(14)
        .background(definition.themeColor.opacity(0.20))
        .overlay(RoundedRectangle(cornerRadius: 14).stroke(definition.themeColor.opacity(0.55), lineWidth: 2))
        .clipShape(RoundedRectangle(cornerRadius: 14))
    }
}

struct FruitMiniSummary: View {
    let definition: PixelFruitDefinition
    let mastery: FruitMastery

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text("Equipped: \(definition.displayName)")
                .font(.headline.monospaced())
            Text("Mastery Lv \(mastery.level), XP \(mastery.experience)")
                .font(.caption.monospacedDigit())
            Text(definition.abilities.map(\.name).joined(separator: " · "))
                .font(.caption.monospaced())
                .foregroundColor(.white.opacity(0.72))
        }
        .padding(14)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(definition.themeColor.opacity(0.22))
        .clipShape(RoundedRectangle(cornerRadius: 14))
    }
}

struct PalettePicker: View {
    let title: String
    @Binding var selection: PixelPalette

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title).font(.caption.bold().monospaced())
            HStack {
                ForEach(PixelPalette.allCases) { palette in
                    Button {
                        selection = palette
                    } label: {
                        VStack(spacing: 4) {
                            PixelRect(color: palette.color)
                                .frame(width: 34, height: 34)
                                .overlay(Rectangle().stroke(selection == palette ? Color.white : Color.clear, lineWidth: 3))
                            Text(palette.displayName)
                                .font(.system(size: 8, design: .monospaced))
                        }
                    }
                    .buttonStyle(.plain)
                }
            }
        }
    }
}

struct PixelCharacterSprite: View {
    let profile: PixelFighterProfile
    let fruit: PixelFruitKind
    let scale: CGFloat

    var body: some View {
        let fruitColor = PixelFruitLibrary.definition(for: fruit).themeColor
        ZStack {
            PixelRect(color: profile.hairPalette.color)
                .frame(width: 15 * scale, height: 8 * scale)
                .offset(y: -23 * scale)
            PixelRect(color: profile.bodyPalette.color)
                .frame(width: 18 * scale, height: 18 * scale)
                .offset(y: -12 * scale)
            PixelRect(color: profile.outfitPalette.color)
                .frame(width: 22 * scale, height: 22 * scale)
                .offset(y: 8 * scale)
            PixelRect(color: profile.bodyPalette.color)
                .frame(width: 7 * scale, height: 18 * scale)
                .offset(x: -16 * scale, y: 4 * scale)
            PixelRect(color: profile.bodyPalette.color)
                .frame(width: 7 * scale, height: 18 * scale)
                .offset(x: 16 * scale, y: 4 * scale)
            PixelRect(color: fruitColor)
                .frame(width: 8 * scale, height: 8 * scale)
                .offset(x: 18 * scale, y: -9 * scale)
            PixelRect(color: .black)
                .frame(width: 3 * scale, height: 3 * scale)
                .offset(x: -4 * scale, y: -14 * scale)
            PixelRect(color: .black)
                .frame(width: 3 * scale, height: 3 * scale)
                .offset(x: 5 * scale, y: -14 * scale)
        }
        .frame(width: 54 * scale, height: 66 * scale)
        .drawingGroup(opaque: false, colorMode: .nonLinear)
    }
}

struct PixelStageBackdrop: View {
    var body: some View {
        ZStack {
            LinearGradient(colors: [Color(red: 0.06, green: 0.08, blue: 0.22), Color(red: 0.12, green: 0.11, blue: 0.20)], startPoint: .top, endPoint: .bottom)
            VStack(spacing: 18) {
                ForEach(0..<8, id: \.self) { row in
                    HStack(spacing: 18) {
                        ForEach(0..<14, id: \.self) { column in
                            PixelRect(color: (row + column).isMultiple(of: 3) ? .white.opacity(0.08) : .clear)
                                .frame(width: 8, height: 8)
                        }
                    }
                }
            }
        }
    }
}

struct EffectView: View {
    let effect: VisibleEffect
    let scale: CGFloat

    var body: some View {
        Text(effect.label)
            .font(.system(size: max(9, effect.size.height * 0.35 * scale), weight: .black, design: .monospaced))
            .padding(3)
            .frame(width: effect.size.width * scale, height: effect.size.height * scale)
            .background(effect.color.opacity(0.72))
            .overlay(Rectangle().stroke(Color.white.opacity(0.55), lineWidth: 1))
            .position(x: effect.origin.x * scale, y: effect.origin.y * scale)
    }
}

struct PixelRect: View {
    let color: Color
    var body: some View { Rectangle().fill(color) }
}

struct PixelArenaButton: View {
    let title: String
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Text(title)
                .font(.caption.bold().monospaced())
                .foregroundColor(.white)
                .padding(.vertical, 10)
                .padding(.horizontal, 12)
                .frame(maxWidth: .infinity)
                .background(Color.white.opacity(0.12))
                .overlay(Rectangle().stroke(Color.white.opacity(0.35), lineWidth: 2))
        }
        .buttonStyle(.plain)
    }
}

struct PixelBackButton: View {
    let action: () -> Void
    var body: some View {
        Button(action: action) {
            Label("Back", systemImage: "chevron.left")
                .font(.caption.bold().monospaced())
        }
        .buttonStyle(.plain)
        .foregroundColor(.white.opacity(0.85))
    }
}
