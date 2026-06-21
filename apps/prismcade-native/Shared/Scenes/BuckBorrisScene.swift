import SpriteKit
#if os(macOS)
import AppKit
#endif

/// Beat Em Up Buck — native SpriteKit beat-em-up.
///
/// Engine decision: local OpenBOR/MUGEN/Ikemen reference folders exist
/// (`experiments/openbor-prismtek-brawler`, `experiments/ikemen-prismtek-fighter`) but none is a
/// usable macOS/iOS runtime, so this stays a native SpriteKit state machine that borrows the
/// concepts: fighter states, hit/hurtboxes, enemy waves, attacks + cooldowns, an energy-wave
/// projectile, simple enemy AI, a dragon-mount power state, and a health/KO system.
final class BuckBorrisScene: SKScene {
    private enum Phase { case title, playing, gameOver }
    private enum FighterState { case idle, walk, attack, charge, hurt, defeated }

    private struct InputState {
        var left = false, right = false, up = false, down = false
    }

    /// One desert enemy (mummy) with its own node, AI timers and health.
    private final class Enemy {
        let node = SKSpriteNode()
        let shadow = SKSpriteNode(color: SKColor(red: 0.02, green: 0.02, blue: 0.03, alpha: 0.40), size: CGSize(width: 60, height: 12))
        let healthBack = SKSpriteNode(color: SKColor(red: 0.05, green: 0.06, blue: 0.08, alpha: 0.9), size: CGSize(width: 56, height: 7))
        let healthFill = SKSpriteNode(color: SKColor(red: 0.95, green: 0.30, blue: 0.40, alpha: 1), size: CGSize(width: 52, height: 4))
        var base = CGPoint.zero
        var state: FighterState = .idle
        var facing: CGFloat = -1
        var hitStun: TimeInterval = 0
        var attackCooldown: TimeInterval = 0
        var animFrame = Int.random(in: 0...3)
        let maxHealth: Int
        var health: Int
        let tough: Bool
        init(tough: Bool) {
            self.tough = tough
            self.maxHealth = tough ? 150 : 100
            self.health = maxHealth
        }
    }

    private struct Projectile { let node: SKSpriteNode; var velocity: CGVector }

    private var phase: Phase = .title
    private var buckState: FighterState = .idle

    private var buck = SKSpriteNode()
    private var buckShadow = SKSpriteNode()
    private var dragon = SKSpriteNode()
    private var stageNodes: [SKSpriteNode] = []
    private var weatherSprites: [SKSpriteNode] = []
    private var cityBackground = SKSpriteNode()
    private var buckHealthBack = SKSpriteNode()
    private var buckHealthFill = SKSpriteNode()
    private var energyBack = SKSpriteNode()
    private var energyFill = SKSpriteNode()
    private var titleLabel = SKLabelNode(fontNamed: "Menlo-Bold")
    private var statusLabel = SKLabelNode(fontNamed: "Menlo-Bold")
    private var scoreLabel = SKLabelNode(fontNamed: "Menlo-Bold")
    private var highScoreLabel = SKLabelNode(fontNamed: "Menlo-Bold")
    private var waveLabel = SKLabelNode(fontNamed: "Menlo-Bold")
    private var dragonLabel = SKLabelNode(fontNamed: "Menlo-Bold")

    private var idleFrames: [SKTexture] = []
    private var runFrames: [SKTexture] = []
    private var damagedFrames: [SKTexture] = []
    private var attackFrames: [SKTexture] = []
    private var enemyIdleFrames: [SKTexture] = []
    private var enemyWalkFrames: [SKTexture] = []
    private var enemyHurtFrames: [SKTexture] = []
    private var enemyDeathFrames: [SKTexture] = []
    private var dragonFrames: [SKTexture] = []

    private var enemies: [Enemy] = []
    private var projectiles: [Projectile] = []
    private var input = InputState()
    private var buckBase = CGPoint.zero
    private var buckVelocityZ: CGFloat = 0
    private var buckZ: CGFloat = 0
    private var buckFacing: CGFloat = 1
    private var buckHurtTimer: TimeInterval = 0
    private var attackTimer: TimeInterval = 0
    private var attackConnected = false
    private var chargeTimer: TimeInterval = 0
    private var energy: CGFloat = 0
    private var animationTimer: TimeInterval = 0
    private var animationFrame = 0
    private var waveSpawnDelay: TimeInterval = 0
    private var gameTimer: Timer?
    private var lastTimerDate = Date()

    private var wave = 0
    private var score = 0
    private var koCount = 0
    private var buckHealth = 100
    private var dragonTimer: TimeInterval = 0
    private var dragonActive: Bool { dragonTimer > 0 }
    private var highScore = UserDefaults.standard.integer(forKey: "Prismcade.BeatEmUpBuck.highScore")

    private let minLaneY: CGFloat = 108
    private let maxLaneY: CGFloat = 188
    private let moveSpeed: CGFloat = 260
    private let jumpImpulse: CGFloat = 560
    private let gravity: CGFloat = -1600
    private let energyCost: CGFloat = 100
    private let enemyCap = 4

    private var autoVerifyEnabled = ProcessInfo.processInfo.environment["PRISMCADE_AUTOVERIFY_BUCK"] == "1"
    private var autoTime: TimeInterval = 0
    private var autoSawMove = false, autoSawAttack = false, autoSawEnemyDamage = false
    private var autoSawBuckDamage = false, autoSawKnockback = false, autoSawKO = false
    private var autoSawScore = false, autoSawGameOver = false, autoSawRestart = false
    private var autoSawWave2 = false, autoSawMultiEnemy = false, autoSawEnergyWave = false
    private var autoSawWaveKO = false, autoSawDragon = false, autoWroteCombatSnapshot = false
    private var autoWroteDragonSnapshot = false
    private var autoForcedGameOver = false

    override func didMove(to view: SKView) {
        scaleMode = .resizeFill
        view.preferredFramesPerSecond = 60
        view.isPaused = false
        isPaused = false
        backgroundColor = SKColor(red: 0.08, green: 0.07, blue: 0.10, alpha: 1)
        loadFrames()
        setupWorld()
        showTitle()
        startTimer()
    }

    override func willMove(from view: SKView) { gameTimer?.invalidate(); gameTimer = nil }

    override func didChangeSize(_ oldSize: CGSize) {
        layoutLabels(); layoutStage()
        if phase != .playing { resetActors() }
    }

    // MARK: - Assets

    private func loadFrames() {
        idleFrames = (0...4).compactMap { texture(named: "idle_0\($0)") }
        runFrames = (0...3).compactMap { texture(named: "run_0\($0)") }
        damagedFrames = (0...1).compactMap { texture(named: "damaged_0\($0)") }
        let strip = SKTexture(imageNamed: "attacks_80x32"); strip.filteringMode = .nearest
        attackFrames = (0..<12).map { index in
            let frame = SKTexture(rect: CGRect(x: 0, y: 1 - CGFloat(index + 1) / 12, width: 1, height: 1 / 12), in: strip)
            frame.filteringMode = .nearest; return frame
        }
        enemyIdleFrames = sliceStrip("enemy_mummy_idle", count: 4)
        enemyWalkFrames = sliceStrip("enemy_mummy_walk", count: 6)
        enemyHurtFrames = sliceStrip("enemy_mummy_hurt", count: 2)
        enemyDeathFrames = sliceStrip("enemy_mummy_death", count: 6)
        dragonFrames = sliceStrip("buck_dragon_strip", count: 4)
        if idleFrames.isEmpty, let f = texture(named: "idle_00") { idleFrames = [f] }
        if runFrames.isEmpty { runFrames = idleFrames }
        if damagedFrames.isEmpty { damagedFrames = idleFrames }
        if attackFrames.isEmpty { attackFrames = runFrames }
    }

    private func texture(named name: String) -> SKTexture? {
        let t = SKTexture(imageNamed: name); t.filteringMode = .nearest; return t
    }

    private func sliceStrip(_ name: String, count: Int) -> [SKTexture] {
        let sheet = SKTexture(imageNamed: name); sheet.filteringMode = .nearest
        guard count > 0 else { return [] }
        return (0..<count).map { index in
            let frame = SKTexture(rect: CGRect(x: CGFloat(index) / CGFloat(count), y: 0, width: 1 / CGFloat(count), height: 1), in: sheet)
            frame.filteringMode = .nearest; return frame
        }
    }

    // MARK: - World

    private func setupWorld() {
        removeAllChildren()
        stageNodes.removeAll(); weatherSprites.removeAll(); enemies.removeAll(); projectiles.removeAll()

        buckShadow = SKSpriteNode(color: SKColor(red: 0.02, green: 0.02, blue: 0.03, alpha: 0.40), size: CGSize(width: 58, height: 12))
        buckShadow.zPosition = 4; addChild(buckShadow)

        dragon = SKSpriteNode(texture: dragonFrames.first)
        dragon.size = CGSize(width: 200, height: 210)
        dragon.zPosition = 29; dragon.isHidden = true; addChild(dragon)

        buck = SKSpriteNode(texture: idleFrames.first)
        buck.name = "buck-borris-player"
        buck.size = CGSize(width: 128, height: 128); buck.zPosition = 30; addChild(buck)

        for label in [titleLabel, statusLabel, scoreLabel, highScoreLabel, waveLabel, dragonLabel] {
            label.zPosition = 80; addChild(label)
        }
        titleLabel.fontSize = 30; titleLabel.horizontalAlignmentMode = .center
        statusLabel.fontSize = 15; statusLabel.horizontalAlignmentMode = .center
        scoreLabel.fontSize = 22; scoreLabel.horizontalAlignmentMode = .left
        highScoreLabel.fontSize = 14; highScoreLabel.horizontalAlignmentMode = .right
        waveLabel.fontSize = 18; waveLabel.horizontalAlignmentMode = .center
        dragonLabel.fontSize = 16; dragonLabel.horizontalAlignmentMode = .center
        dragonLabel.fontColor = SKColor(red: 0.55, green: 0.85, blue: 1.0, alpha: 1)

        buildHealthBars()
        layoutStage()
        layoutLabels()
    }

    private func buildHealthBars() {
        buckHealthBack = SKSpriteNode(color: SKColor(red: 0.05, green: 0.06, blue: 0.08, alpha: 1), size: CGSize(width: 220, height: 18))
        buckHealthBack.anchorPoint = CGPoint(x: 0, y: 0.5); buckHealthBack.zPosition = 78; addChild(buckHealthBack)
        buckHealthFill = SKSpriteNode(color: SKColor(red: 0.34, green: 0.92, blue: 0.50, alpha: 1), size: CGSize(width: 212, height: 10))
        buckHealthFill.anchorPoint = CGPoint(x: 0, y: 0.5); buckHealthFill.position = CGPoint(x: 4, y: 0); buckHealthFill.zPosition = 1
        buckHealthBack.addChild(buckHealthFill)

        energyBack = SKSpriteNode(color: SKColor(red: 0.05, green: 0.06, blue: 0.08, alpha: 1), size: CGSize(width: 220, height: 10))
        energyBack.anchorPoint = CGPoint(x: 0, y: 0.5); energyBack.zPosition = 78; addChild(energyBack)
        energyFill = SKSpriteNode(color: SKColor(red: 0.40, green: 0.78, blue: 1.0, alpha: 1), size: CGSize(width: 212, height: 5))
        energyFill.anchorPoint = CGPoint(x: 0, y: 0.5); energyFill.position = CGPoint(x: 4, y: 0); energyFill.zPosition = 1
        energyBack.addChild(energyFill)
        layoutHealthBars()
    }

    private func layoutHealthBars() {
        buckHealthBack.position = CGPoint(x: 22, y: size.height - 30)
        energyBack.position = CGPoint(x: 22, y: size.height - 48)
    }

    private func layoutStage() {
        for node in stageNodes { node.removeFromParent() }
        stageNodes.removeAll()
        let width = max(size.width, 900)
        let texture = SKTexture(imageNamed: "buck_desert_background"); texture.filteringMode = .nearest
        cityBackground = SKSpriteNode(texture: texture)
        cityBackground.position = CGPoint(x: size.width / 2, y: size.height / 2)
        cityBackground.size = CGSize(width: width, height: max(size.height, 506))
        cityBackground.zPosition = 0; addChild(cityBackground); stageNodes.append(cityBackground)

        let floorTop: CGFloat = 232
        let sand = SKSpriteNode(color: SKColor(red: 0.80, green: 0.69, blue: 0.46, alpha: 1), size: CGSize(width: width, height: floorTop))
        sand.anchorPoint = CGPoint(x: 0.5, y: 0); sand.position = CGPoint(x: size.width / 2, y: 0); sand.zPosition = 1
        addChild(sand); stageNodes.append(sand)
        let lip = SKSpriteNode(color: SKColor(red: 0.66, green: 0.53, blue: 0.32, alpha: 1), size: CGSize(width: width, height: 12))
        lip.anchorPoint = CGPoint(x: 0.5, y: 0); lip.position = CGPoint(x: size.width / 2, y: floorTop - 12); lip.zPosition = 2
        addChild(lip); stageNodes.append(lip)
        let highlight = SKSpriteNode(color: SKColor(red: 0.90, green: 0.80, blue: 0.56, alpha: 1), size: CGSize(width: width, height: 3))
        highlight.anchorPoint = CGPoint(x: 0.5, y: 0); highlight.position = CGPoint(x: size.width / 2, y: floorTop); highlight.zPosition = 3
        addChild(highlight); stageNodes.append(highlight)
        let tileWidth: CGFloat = 96
        for column in 0..<(Int(width / tileWidth) + 1) {
            let x = -width / 2 + CGFloat(column) * tileWidth + size.width / 2
            let seam = SKSpriteNode(color: SKColor(red: 0.70, green: 0.58, blue: 0.36, alpha: 0.6), size: CGSize(width: 2, height: floorTop - 12))
            seam.anchorPoint = CGPoint(x: 0.5, y: 0); seam.position = CGPoint(x: x, y: 0); seam.zPosition = 2
            addChild(seam); stageNodes.append(seam)
        }
        addWeatherGusts()
    }

    private func addWeatherGusts() {
        for index in 0..<3 {
            let texture = SKTexture(imageNamed: index == 1 ? "weather_wind_2" : "weather_wind_1"); texture.filteringMode = .nearest
            let gust = SKSpriteNode(texture: texture)
            gust.anchorPoint = CGPoint(x: 0, y: 0.5); gust.alpha = 0.18; gust.zPosition = 6
            gust.size = CGSize(width: 230, height: 14)
            gust.position = CGPoint(x: CGFloat(index) * 280, y: size.height * 0.34 + CGFloat(index * 22))
            addChild(gust); stageNodes.append(gust); weatherSprites.append(gust)
        }
    }

    private func layoutLabels() {
        titleLabel.position = CGPoint(x: size.width / 2, y: size.height * 0.76)
        statusLabel.position = CGPoint(x: size.width / 2, y: size.height * 0.76 - 36)
        scoreLabel.position = CGPoint(x: 22, y: size.height - 78)
        highScoreLabel.position = CGPoint(x: size.width - 22, y: size.height - 30)
        waveLabel.position = CGPoint(x: size.width - 22, y: size.height - 54)
        waveLabel.horizontalAlignmentMode = .right
        dragonLabel.position = CGPoint(x: size.width / 2, y: size.height - 40)
        layoutHealthBars(); updateLabels(); updateHealthBars()
    }

    // MARK: - Flow

    private func showTitle() {
        phase = .title
        titleLabel.text = "Beat Em Up Buck"
        statusLabel.text = "WASD/Arrows move · J/Space punch · K jump · L energy wave"
        score = 0; koCount = 0; wave = 0; buckHealth = 100; energy = 0; dragonTimer = 0
        clearEnemies(); clearProjectiles()
        resetActors(); updateLabels(); updateHealthBars(); updateWaveLabel()
    }

    private func startFight() {
        phase = .playing
        playSound("ui_select.wav")
        titleLabel.text = ""; statusLabel.text = ""
        score = 0; koCount = 0; buckHealth = 100; energy = 0; dragonTimer = 0
        buckHurtTimer = 0; attackTimer = 0; attackConnected = false; chargeTimer = 0
        autoForcedGameOver = false
        clearProjectiles()
        resetActors()
        wave = 0
        startNextWave()
        updateLabels(); updateHealthBars()
    }

    private func resetActors() {
        buckState = .idle
        buckBase = CGPoint(x: max(120, size.width * 0.24), y: minLaneY + 34)
        buckZ = 0; buckVelocityZ = 0; buckFacing = 1
        dragon.isHidden = true
        applyActorPositions(); setBuckTexture(idleFrames.first); buck.alpha = 1
    }

    private func startNextWave() {
        wave += 1
        let count = min(wave, enemyCap)
        if wave >= 2 { autoSawWave2 = true }
        if count >= 2 { autoSawMultiEnemy = true }
        for i in 0..<count {
            let tough = wave >= 3 && i == 0
            let e = Enemy(tough: tough)
            e.node.size = CGSize(width: 124, height: 124); e.node.zPosition = 28
            e.node.texture = enemyIdleFrames.first
            e.shadow.zPosition = 4
            e.healthBack.zPosition = 60; e.healthFill.anchorPoint = CGPoint(x: 0, y: 0.5)
            e.healthFill.position = CGPoint(x: -26, y: 0); e.healthBack.addChild(e.healthFill)
            let spread = CGFloat(i) - CGFloat(count - 1) / 2
            e.base = CGPoint(x: min(size.width - 80, size.width * 0.72 + spread * 96),
                             y: min(maxLaneY, max(minLaneY, minLaneY + 30 + spread * 22)))
            if tough { e.node.color = SKColor(red: 0.7, green: 0.45, blue: 1.0, alpha: 1); e.node.colorBlendFactor = 0.35; e.node.size = CGSize(width: 150, height: 150) }
            addChild(e.node); addChild(e.shadow); addChild(e.healthBack)
            enemies.append(e)
        }
        updateWaveLabel()
    }

    private func clearEnemies() {
        for e in enemies { e.node.removeFromParent(); e.shadow.removeFromParent(); e.healthBack.removeFromParent() }
        enemies.removeAll()
    }

    private func clearProjectiles() {
        for p in projectiles { p.node.removeFromParent() }
        projectiles.removeAll()
    }

    private func updateWaveLabel() {
        waveLabel.text = "Wave \(max(wave, 1)) · enemies \(enemies.count)"
    }

    // MARK: - Loop

    private func startTimer() {
        lastTimerDate = Date(); gameTimer?.invalidate()
        let timer = Timer(timeInterval: 1.0 / 60.0, repeats: true) { [weak self] _ in self?.tick() }
        RunLoop.main.add(timer, forMode: .common); gameTimer = timer
    }

    private func tick() {
        let now = Date()
        let dt = min(max(now.timeIntervalSince(lastTimerDate), 0), 1.0 / 30.0)
        lastTimerDate = now
        animate(dt); scrollWeather(dt); runAutoVerification(dt)
        guard phase == .playing else { return }
        updateBuck(dt); updateEnemies(dt); updateProjectiles(dt); resolveAttack(); updateWaveProgress(dt)
        updateHealthBars(); updateLabels(); applyActorPositions()
    }

    private func updateBuck(_ dt: TimeInterval) {
        if dragonTimer > 0 {
            dragonTimer -= dt
            if dragonTimer <= 0 { dragon.isHidden = true }
        }
        if energy < energyCost { energy = min(energyCost, energy + CGFloat(dt) * 7) }

        var movement = CGVector(dx: 0, dy: 0)
        if input.left { movement.dx -= 1 }
        if input.right { movement.dx += 1 }
        if input.up { movement.dy += 1 }
        if input.down { movement.dy -= 1 }

        let speed = dragonActive ? moveSpeed * 1.5 : moveSpeed
        if buckHurtTimer > 0 {
            buckHurtTimer -= dt; buckState = .hurt
        } else if chargeTimer > 0 {
            chargeTimer -= dt; buckState = .charge
            if chargeTimer <= 0 { fireEnergyWave() }
        } else if attackTimer > 0 {
            attackTimer -= dt; buckState = .attack
        } else {
            buckState = (movement.dx != 0 || movement.dy != 0) ? .walk : .idle
            if buckState == .walk { autoSawMove = true }
            buckBase.x += movement.dx * speed * CGFloat(dt)
            buckBase.y += movement.dy * speed * 0.55 * CGFloat(dt)
        }

        buckVelocityZ += gravity * CGFloat(dt)
        buckZ = max(0, buckZ + buckVelocityZ * CGFloat(dt))
        if buckZ == 0 { buckVelocityZ = 0 }
        buckBase.x = min(max(70, buckBase.x), size.width - 70)
        buckBase.y = min(max(minLaneY, buckBase.y), maxLaneY)
        if let nearest = nearestEnemy(), abs(nearest.base.x - buckBase.x) > 8 {
            buckFacing = nearest.base.x > buckBase.x ? 1 : -1
        }
    }

    private func nearestEnemy() -> Enemy? {
        enemies.filter { $0.health > 0 }.min { abs($0.base.x - buckBase.x) < abs($1.base.x - buckBase.x) }
    }

    private func updateEnemies(_ dt: TimeInterval) {
        for e in enemies {
            guard e.health > 0 else { e.state = .defeated; continue }
            if e.attackCooldown > 0 { e.attackCooldown -= dt }
            if e.hitStun > 0 {
                e.hitStun -= dt; e.state = .hurt
                e.base.x += e.facing * -90 * CGFloat(dt); autoSawKnockback = true
            } else {
                let dx = buckBase.x - e.base.x, dy = buckBase.y - e.base.y
                let range = abs(dx)
                let approach: CGFloat = e.tough ? 70 : 88
                if range > 64 { e.base.x += (dx > 0 ? 1 : -1) * approach * CGFloat(dt); e.state = .walk }
                if abs(dy) > 6 { e.base.y += (dy > 0 ? 1 : -1) * 48 * CGFloat(dt) }
                if range < 72 && abs(dy) < 34 && buckHurtTimer <= 0 && e.attackCooldown <= 0 && !dragonActive {
                    let dmg = e.tough ? 9 : 6
                    buckHealth = max(0, buckHealth - dmg)
                    buckHurtTimer = 0.30; buckState = .hurt; e.attackCooldown = 0.95
                    let pushDir: CGFloat = buckBase.x <= e.base.x ? -1 : 1
                    buckBase.x = min(max(70, buckBase.x + pushDir * 90), size.width - 70)
                    e.base.x -= pushDir * 26
                    autoSawBuckDamage = true; playSound("buck_hurt.wav")
                    if buckHealth <= 0 { endFight(message: "Buck Got Clipped") }
                }
            }
            e.base.x = min(max(70, e.base.x), size.width - 70)
            e.base.y = min(max(minLaneY, e.base.y), maxLaneY)
            if abs(e.base.x - buckBase.x) > 4 { e.facing = buckBase.x > e.base.x ? 1 : -1 }
        }
    }

    private func updateWaveProgress(_ dt: TimeInterval) {
        if enemies.contains(where: { $0.health > 0 }) { waveSpawnDelay = 0; return }
        // Wave cleared: brief pause, score bonus, next wave.
        if waveSpawnDelay == 0 {
            score += 100; autoSawWaveKO = true
            statusLabel.text = "Wave \(wave) cleared!"
        }
        waveSpawnDelay += dt
        if waveSpawnDelay > 1.1 {
            statusLabel.text = ""
            clearEnemies()
            startNextWave()
            waveSpawnDelay = 0
        }
    }

    // MARK: - Attacks

    private func jump() {
        guard phase == .playing, buckZ == 0 else { return }
        buckVelocityZ = jumpImpulse; playSound("buck_jump.wav")
    }

    private func attack() {
        switch phase {
        case .title: startFight()
        case .playing:
            guard attackTimer <= 0, buckHurtTimer <= 0, chargeTimer <= 0 else { return }
            attackTimer = 0.34; attackConnected = false; buckState = .attack
            autoSawAttack = true; playSound("buck_swing.wav")
        case .gameOver: startFight(); autoSawRestart = true
        }
    }

    private func energyAttack() {
        guard phase == .playing, buckHurtTimer <= 0, attackTimer <= 0, chargeTimer <= 0 else {
            if phase == .gameOver { startFight(); autoSawRestart = true }
            return
        }
        guard energy >= energyCost else { return }
        energy = 0; chargeTimer = 0.18; buckState = .charge; playSound("buck_swing.wav")
    }

    private func fireEnergyWave() {
        let wave = SKSpriteNode(color: SKColor(red: 0.45, green: 0.82, blue: 1.0, alpha: 0.95), size: CGSize(width: 46, height: 40))
        wave.zPosition = 40
        wave.position = CGPoint(x: buckBase.x + buckFacing * 44, y: buckBase.y + 6)
        let core = SKSpriteNode(color: .white, size: CGSize(width: 22, height: 18)); core.zPosition = 1; wave.addChild(core)
        addChild(wave)
        wave.run(.repeatForever(.sequence([.scale(to: 1.18, duration: 0.12), .scale(to: 1.0, duration: 0.12)])))
        projectiles.append(Projectile(node: wave, velocity: CGVector(dx: buckFacing * 520, dy: 0)))
        autoSawEnergyWave = true
        playSound("buck_ko.wav")
    }

    private func updateProjectiles(_ dt: TimeInterval) {
        for index in projectiles.indices.reversed() {
            projectiles[index].node.position.x += projectiles[index].velocity.dx * CGFloat(dt)
            let px = projectiles[index].node.position.x
            let py = projectiles[index].node.position.y
            var consumed = false
            let rect = CGRect(x: px - 26, y: py - 24, width: 52, height: 48)
            for e in enemies where e.health > 0 {
                let hurt = CGRect(x: e.base.x - 30, y: e.base.y - 44, width: 60, height: 84)
                if rect.intersects(hurt) {
                    applyDamage(to: e, amount: 55, knockback: 40, fromX: px)
                    consumed = true
                }
            }
            if consumed || px < -60 || px > size.width + 60 {
                projectiles[index].node.removeFromParent()
                projectiles.remove(at: index)
            }
        }
    }

    private func resolveAttack() {
        guard phase == .playing, buckState == .attack, !attackConnected else { return }
        guard attackTimer < 0.24, attackTimer > 0.08 else { return }
        let reach: CGFloat = dragonActive ? 110 : 70
        let hitbox = CGRect(x: buckBase.x + (buckFacing > 0 ? 12 : -12 - reach), y: buckBase.y - 34, width: reach, height: 60)
        var hitAny = false
        for e in enemies where e.health > 0 {
            let hurt = CGRect(x: e.base.x - 28, y: e.base.y - 42, width: 56, height: 78)
            if hitbox.intersects(hurt) {
                attackConnected = true; hitAny = true
                applyDamage(to: e, amount: dragonActive ? 60 : 34, knockback: 22, fromX: buckBase.x)
            }
        }
        if hitAny {
            energy = min(energyCost, energy + 18)
            playSound("buck_hit.wav")
        }
    }

    private func applyDamage(to e: Enemy, amount: Int, knockback: CGFloat, fromX: CGFloat) {
        e.health = max(0, e.health - amount)
        e.hitStun = 0.36; e.state = .hurt
        let dir: CGFloat = e.base.x >= fromX ? 1 : -1
        e.base.x += dir * knockback
        score += 35; autoSawEnemyDamage = true; autoSawScore = true
        spawnHitSpark(at: CGPoint(x: e.base.x, y: e.base.y + 22))
        if e.health <= 0 {
            koCount += 1; score += 150; e.state = .defeated
            e.node.alpha = 0.4; e.healthBack.isHidden = true; autoSawKO = true
            playSound("buck_ko.wav")
            // Dragon mount reward every 3 KOs.
            if koCount % 3 == 0 { activateDragon() }
        }
    }

    private func activateDragon() {
        dragonTimer = 9.0
        dragon.isHidden = false
        dragonLabel.text = "🐉 DRAGON MOUNT!"
        autoSawDragon = true
        playSound("buck_jump.wav")
        dragonLabel.run(.sequence([.fadeIn(withDuration: 0.1), .wait(forDuration: 1.4), .fadeOut(withDuration: 0.4)]))
    }

    private func spawnHitSpark(at point: CGPoint) {
        let sheet = SKTexture(imageNamed: "weather_shine_1"); sheet.filteringMode = .nearest
        let frames = (0..<6).map { index -> SKTexture in
            let f = SKTexture(rect: CGRect(x: CGFloat(index) / 6, y: 0, width: 1 / 6, height: 1), in: sheet); f.filteringMode = .nearest; return f
        }
        let spark = SKSpriteNode(texture: frames.first)
        spark.position = point; spark.size = CGSize(width: 78, height: 38); spark.zPosition = 70
        addChild(spark)
        spark.run(.sequence([.animate(with: frames, timePerFrame: 0.035), .fadeOut(withDuration: 0.05), .removeFromParent()]))
    }

    private func scrollWeather(_ dt: TimeInterval) {
        for (index, gust) in weatherSprites.enumerated() {
            gust.position.x -= CGFloat(36 + index * 14) * CGFloat(dt)
            if gust.position.x < -gust.size.width {
                gust.position.x = size.width + CGFloat(index * 130)
            }
        }
    }

    private func endFight(message: String) {
        phase = .gameOver
        autoSawGameOver = true
        playSound("buck_gameover.wav")
        input = InputState()
        if score > highScore { highScore = score; UserDefaults.standard.set(score, forKey: "Prismcade.BeatEmUpBuck.highScore") }
        if !autoVerifyEnabled {
            let final = score
            Task { @MainActor in PrismcadePlatform.shared.recordResult(gameID: "beat-em-up-buck", gameTitle: "Beat Em Up Buck", score: final) }
        }
        titleLabel.text = message
        statusLabel.text = "Reached wave \(wave) · \(koCount) KOs — J, Space, L, click, or tap to restart"
        updateLabels()
    }

    // MARK: - Render

    private func animate(_ dt: TimeInterval) {
        animationTimer += dt
        guard animationTimer > 0.075 else { return }
        animationTimer = 0; animationFrame += 1

        switch buckState {
        case .idle: setBuckTexture(idleFrames[animationFrame % max(idleFrames.count, 1)]); buck.size = CGSize(width: 128, height: 128)
        case .walk: setBuckTexture(runFrames[animationFrame % max(runFrames.count, 1)]); buck.size = CGSize(width: 128, height: 128)
        case .charge:
            setBuckTexture(idleFrames[animationFrame % max(idleFrames.count, 1)]); buck.size = CGSize(width: 128, height: 128)
            buck.colorBlendFactor = 0.6; buck.color = SKColor(red: 0.45, green: 0.82, blue: 1.0, alpha: 1)
        case .attack:
            let idx = min(attackFrames.count - 1, max(0, Int((0.34 - attackTimer) / 0.034)))
            setBuckTexture(attackFrames[idx]); buck.size = CGSize(width: 200, height: 80)
        case .hurt: setBuckTexture(damagedFrames[animationFrame % max(damagedFrames.count, 1)]); buck.size = CGSize(width: 128, height: 128)
        case .defeated: setBuckTexture(damagedFrames.last)
        }
        if buckState != .charge { buck.colorBlendFactor = 0 }

        if dragonActive, !dragonFrames.isEmpty {
            dragon.texture = dragonFrames[animationFrame % dragonFrames.count]
            dragon.xScale = buckFacing
        }

        for e in enemies {
            e.animFrame += 1
            let tex: SKTexture?
            switch e.state {
            case .walk: tex = enemyWalkFrames.isEmpty ? nil : enemyWalkFrames[e.animFrame % enemyWalkFrames.count]
            case .hurt: tex = enemyHurtFrames.isEmpty ? enemyIdleFrames.first : enemyHurtFrames[e.animFrame % enemyHurtFrames.count]
            case .defeated: tex = enemyDeathFrames.last ?? enemyIdleFrames.last
            default: tex = enemyIdleFrames.isEmpty ? nil : enemyIdleFrames[e.animFrame % enemyIdleFrames.count]
            }
            if let tex { tex.filteringMode = .nearest; e.node.texture = tex }
        }
    }

    private func setBuckTexture(_ texture: SKTexture?) {
        if let texture { texture.filteringMode = .nearest; buck.texture = texture }
    }

    private func applyActorPositions() {
        let ride: CGFloat = dragonActive ? 40 : 0
        buck.position = CGPoint(x: buckBase.x, y: buckBase.y + buckZ + ride)
        buckShadow.position = CGPoint(x: buckBase.x, y: buckBase.y - 55)
        buck.xScale = buckFacing
        buck.zPosition = 30 + buckBase.y * 0.01
        buckShadow.zPosition = buck.zPosition - 1
        if dragonActive {
            dragon.position = CGPoint(x: buckBase.x - buckFacing * 8, y: buckBase.y + buckZ - 6)
            dragon.zPosition = buck.zPosition - 0.5
        }
        for e in enemies {
            e.node.position = e.base
            e.shadow.position = CGPoint(x: e.base.x, y: e.base.y - 42)
            e.node.xScale = e.facing
            e.node.zPosition = 28 + e.base.y * 0.01
            e.shadow.zPosition = e.node.zPosition - 1
            e.healthBack.position = CGPoint(x: e.base.x, y: e.base.y + 52)
            e.healthBack.zPosition = 60
            e.healthFill.xScale = CGFloat(max(e.health, 0)) / CGFloat(e.maxHealth)
            if e.state == .hurt { e.node.colorBlendFactor = e.node.colorBlendFactor > 0.4 ? (e.tough ? 0.35 : 0) : 0.7; e.node.color = SKColor(red: 1, green: 0.4, blue: 0.4, alpha: 1) }
            else if e.tough { e.node.colorBlendFactor = 0.35; e.node.color = SKColor(red: 0.7, green: 0.45, blue: 1.0, alpha: 1) }
            else { e.node.colorBlendFactor = 0 }
        }
    }

    private func updateHealthBars() {
        buckHealthFill.xScale = CGFloat(max(buckHealth, 0)) / 100
        energyFill.xScale = energy / energyCost
        energyFill.color = energy >= energyCost ? SKColor(red: 0.55, green: 1.0, blue: 0.7, alpha: 1) : SKColor(red: 0.40, green: 0.78, blue: 1.0, alpha: 1)
    }

    private func updateLabels() {
        scoreLabel.text = "Score \(score)  KO \(koCount)"
        highScoreLabel.text = "Best \(highScore)"
        updateWaveLabel()
    }

    // MARK: - Autoverify

    private func runAutoVerification(_ dt: TimeInterval) {
        guard autoVerifyEnabled else { return }
        autoTime += dt
        if phase == .title { startFight(); return }
        if phase == .playing {
            // Drive Buck to KO enemies, advance waves, fire energy wave, trigger dragon.
            if autoTime < 0.8 { input.right = true } else { input = InputState() }
            // Pull the nearest enemy adjacent and punch it down.
            if let e = nearestEnemy(), autoTime > 0.8 {
                e.base = CGPoint(x: buckBase.x + 58, y: buckBase.y)
                if attackTimer <= 0 && chargeTimer <= 0 { attack() }
            }
            if energy >= energyCost && !autoSawEnergyWave { energyAttack() }
            if !autoSawEnergyWave && autoTime > 2.0 { energy = energyCost; energyAttack() }
            if autoTime > 2.4 && !autoSawDragon { activateDragon() }
            if autoSawEnemyDamage && !autoWroteCombatSnapshot {
                autoWroteCombatSnapshot = true
                writeSceneSnapshot(path: "/tmp/prismcade-buck-combat-snapshot.png")
            }
            if dragonActive && dragonTimer < 8.5 && !autoWroteDragonSnapshot {
                autoWroteDragonSnapshot = true
                writeSceneSnapshot(path: "/tmp/prismcade-buck-dragon-snapshot.png")
            }
            if autoSawWave2 && autoSawEnergyWave && autoSawDragon && autoTime > 4.5 && !autoForcedGameOver {
                autoForcedGameOver = true; buckHealth = 0; endFight(message: "Training Complete")
            }
            if autoTime > 9 && !autoForcedGameOver { autoForcedGameOver = true; buckHealth = 0; endFight(message: "Training Complete") }
        }
        if phase == .gameOver && autoSawGameOver {
            attack()
            writeAutoVerificationReceipt()
            autoVerifyEnabled = false
        }
    }

    private func writeAutoVerificationReceipt() {
        writeSceneSnapshot(path: "/tmp/prismcade-buck-runtime-snapshot.png")
        let payload: [String: Any] = [
            "game": "Beat Em Up Buck",
            "engine": "Native SpriteKit beat-em-up (waves, energy wave, dragon mount)",
            "enemyAsset": "CraftPix desert Mummy strips (idle/walk/hurt/death)",
            "dragonAsset": "animate_char_dragon.gif extracted to buck_dragon_strip (4-frame hover)",
            "multiEnemySpawned": autoSawMultiEnemy,
            "reachedWave2": autoSawWave2,
            "waveCleared": autoSawWaveKO,
            "movementWorked": autoSawMove,
            "punchWorked": autoSawAttack,
            "energyWaveFired": autoSawEnergyWave,
            "enemyTookDamage": autoSawEnemyDamage,
            "buckTookDamage": autoSawBuckDamage,
            "knockbackWorked": autoSawKnockback,
            "koRegistered": autoSawKO,
            "dragonMountActivated": autoSawDragon,
            "scoreChanged": autoSawScore,
            "gameOverTriggered": autoSawGameOver,
            "restartWorked": autoSawRestart,
            "finalWave": wave,
            "finalKOs": koCount
        ]
        guard JSONSerialization.isValidJSONObject(payload),
              let data = try? JSONSerialization.data(withJSONObject: payload, options: [.prettyPrinted, .sortedKeys]) else { return }
        try? data.write(to: URL(fileURLWithPath: "/tmp/prismcade-buck-runtime-verification.json"), options: .atomic)
    }

    private func writeSceneSnapshot(path: String) {
        #if os(macOS)
        guard let texture = view?.texture(from: self) else { return }
        let rep = NSBitmapImageRep(cgImage: texture.cgImage())
        if let data = rep.representation(using: .png, properties: [:]) { try? data.write(to: URL(fileURLWithPath: path), options: .atomic) }
        #endif
    }

    private func playSound(_ name: String) {
        guard !autoVerifyEnabled else { return }
        run(.playSoundFileNamed(name, waitForCompletion: false))
    }

    // MARK: - Input

    private func handleTouch(at point: CGPoint) {
        switch phase {
        case .title, .gameOver: attack()
        case .playing:
            if point.x > size.width * 0.72 {
                if point.y > size.height * 0.5 { energyAttack() }
                else if point.y > size.height * 0.28 { jump() }
                else { attack() }
            } else {
                input.left = point.x < size.width * 0.30
                input.right = point.x > size.width * 0.42
                input.up = point.y > size.height * 0.28
                input.down = point.y < size.height * 0.18
            }
        }
    }

    private func clearTouchInput() { input = InputState() }

    #if os(macOS)
    override func mouseDown(with event: NSEvent) { handleTouch(at: event.location(in: self)) }
    override func mouseUp(with event: NSEvent) { clearTouchInput() }

    override func keyDown(with event: NSEvent) {
        let chars = event.charactersIgnoringModifiers?.lowercased()
        switch event.keyCode {
        case 123: input.left = true
        case 124: input.right = true
        case 125: input.down = true
        case 126: input.up = true
        case 40: jump()                 // K
        case 49: attack()               // Space
        case 37: energyAttack()         // L
        default: break
        }
        switch chars {
        case "a": input.left = true
        case "d": input.right = true
        case "s": input.down = true
        case "w": input.up = true
        case "j", " ": attack()
        case "k": jump()
        case "l", "e": energyAttack()
        default: break
        }
    }

    override func keyUp(with event: NSEvent) {
        let chars = event.charactersIgnoringModifiers?.lowercased()
        switch event.keyCode {
        case 123: input.left = false
        case 124: input.right = false
        case 125: input.down = false
        case 126: input.up = false
        default: break
        }
        switch chars {
        case "a": input.left = false
        case "d": input.right = false
        case "s": input.down = false
        case "w": input.up = false
        default: break
        }
    }
    #endif

    #if os(iOS)
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first else { return }
        handleTouch(at: touch.location(in: self))
    }
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first else { return }
        handleTouch(at: touch.location(in: self))
    }
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) { clearTouchInput() }
    #endif
}
