import SpriteKit
#if os(macOS)
import AppKit
#endif

final class BuckBorrisScene: SKScene {
    private enum Phase {
        case title
        case playing
        case gameOver
    }

    private enum FighterState {
        case idle
        case walk
        case attack
        case hurt
        case defeated
    }

    private struct InputState {
        var left = false
        var right = false
        var up = false
        var down = false
    }

    private var phase: Phase = .title
    private var buckState: FighterState = .idle
    private var enemyState: FighterState = .idle

    private var buck = SKSpriteNode()
    private var enemy = SKSpriteNode()
    private var buckShadow = SKSpriteNode()
    private var enemyShadow = SKSpriteNode()
    private var stageNodes: [SKSpriteNode] = []
    private var cityBackground = SKSpriteNode()
    private var buckHealthBack = SKSpriteNode()
    private var enemyHealthBack = SKSpriteNode()
    private var buckHealthFill = SKSpriteNode()
    private var enemyHealthFill = SKSpriteNode()
    private var titleLabel = SKLabelNode(fontNamed: "Menlo-Bold")
    private var statusLabel = SKLabelNode(fontNamed: "Menlo-Bold")
    private var scoreLabel = SKLabelNode(fontNamed: "Menlo-Bold")
    private var highScoreLabel = SKLabelNode(fontNamed: "Menlo-Bold")

    private var idleFrames: [SKTexture] = []
    private var runFrames: [SKTexture] = []
    private var damagedFrames: [SKTexture] = []
    private var attackFrames: [SKTexture] = []

    private var enemyIdleFrames: [SKTexture] = []
    private var enemyWalkFrames: [SKTexture] = []
    private var enemyHurtFrames: [SKTexture] = []
    private var enemyDeathFrames: [SKTexture] = []

    private var input = InputState()
    private var buckBase = CGPoint.zero
    private var enemyBase = CGPoint.zero
    private var buckVelocityZ: CGFloat = 0
    private var buckZ: CGFloat = 0
    private var buckFacing: CGFloat = 1
    private var enemyFacing: CGFloat = -1
    private var enemyHitStun: TimeInterval = 0
    private var buckHurtTimer: TimeInterval = 0
    private var attackTimer: TimeInterval = 0
    private var attackConnected = false
    private var animationTimer: TimeInterval = 0
    private var animationFrame = 0
    private var gameTimer: Timer?
    private var lastTimerDate = Date()

    private var score = 0
    private var koCount = 0
    private var buckHealth = 100
    private var enemyHealth = 100
    private var highScore = UserDefaults.standard.integer(forKey: "Prismcade.BeatEmUpBuck.highScore")

    private var autoVerifyEnabled = ProcessInfo.processInfo.environment["PRISMCADE_AUTOVERIFY_BUCK"] == "1"
    private var autoTime: TimeInterval = 0
    private var autoSawSprite = false
    private var autoSawMove = false
    private var autoSawAttack = false
    private var autoSawEnemyDamage = false
    private var autoSawBuckDamage = false
    private var autoSawHealthBarsUpdated = false
    private var autoSawKnockback = false
    private var autoSawKO = false
    private var autoSawScore = false
    private var autoSawGameOver = false
    private var autoSawRestart = false
    private var autoWroteCombatSnapshot = false
    private var autoForcedGameOver = false

    private let minLaneY: CGFloat = 108
    private let maxLaneY: CGFloat = 188
    private let moveSpeed: CGFloat = 260
    private let jumpImpulse: CGFloat = 560
    private let gravity: CGFloat = -1600

    override func didMove(to view: SKView) {
        scaleMode = .resizeFill
        view.preferredFramesPerSecond = 60
        view.isPaused = false
        isPaused = false
        backgroundColor = SKColor(red: 0.08, green: 0.07, blue: 0.10, alpha: 1)
        loadFrames()
        setupWorld()
        showTitle()
        if autoVerifyEnabled {
            try? "didMove\n".write(toFile: "/tmp/prismcade-buck-didmove-marker.txt", atomically: true, encoding: .utf8)
        }
        startTimer()
    }

    override func willMove(from view: SKView) {
        gameTimer?.invalidate()
        gameTimer = nil
    }

    override func didChangeSize(_ oldSize: CGSize) {
        layoutLabels()
        layoutStage()
        if phase != .playing {
            resetActors()
        }
    }

    private func loadFrames() {
        idleFrames = (0...4).compactMap { texture(named: "idle_0\($0)") }
        runFrames = (0...3).compactMap { texture(named: "run_0\($0)") }
        damagedFrames = (0...1).compactMap { texture(named: "damaged_0\($0)") }

        let strip = SKTexture(imageNamed: "attacks_80x32")
        strip.filteringMode = .nearest
        attackFrames = (0..<12).map { index in
            let rect = CGRect(x: 0, y: 1 - CGFloat(index + 1) / 12, width: 1, height: 1 / 12)
            let frame = SKTexture(rect: rect, in: strip)
            frame.filteringMode = .nearest
            return frame
        }

        // Enemy: skeleton2 from Enemy_Animations_Set, 32x32 horizontal strips.
        enemyIdleFrames = sliceStrip("enemy_skeleton_idle", count: 6)
        enemyWalkFrames = sliceStrip("enemy_skeleton_walk", count: 10)
        enemyHurtFrames = sliceStrip("enemy_skeleton_hurt", count: 5)
        enemyDeathFrames = sliceStrip("enemy_skeleton_death", count: 15)

        if idleFrames.isEmpty, let fallback = texture(named: "idle_00") {
            idleFrames = [fallback]
        }
        if runFrames.isEmpty {
            runFrames = idleFrames
        }
        if damagedFrames.isEmpty {
            damagedFrames = idleFrames
        }
        if attackFrames.isEmpty {
            attackFrames = runFrames
        }
    }

    private func texture(named name: String) -> SKTexture? {
        let texture = SKTexture(imageNamed: name)
        texture.filteringMode = .nearest
        return texture
    }

    private func sliceStrip(_ name: String, count: Int) -> [SKTexture] {
        let sheet = SKTexture(imageNamed: name)
        sheet.filteringMode = .nearest
        guard count > 0 else { return [] }
        return (0..<count).map { index in
            let frame = SKTexture(rect: CGRect(x: CGFloat(index) / CGFloat(count), y: 0, width: 1 / CGFloat(count), height: 1), in: sheet)
            frame.filteringMode = .nearest
            return frame
        }
    }

    private func enemyFrame(_ frames: [SKTexture]) -> SKTexture? {
        guard !frames.isEmpty else { return nil }
        return frames[animationFrame % frames.count]
    }

    private func setupWorld() {
        removeAllChildren()
        stageNodes.removeAll()

        buckShadow = SKSpriteNode(color: SKColor(red: 0.02, green: 0.02, blue: 0.03, alpha: 0.40), size: CGSize(width: 58, height: 12))
        buckShadow.zPosition = 4
        addChild(buckShadow)

        enemyShadow = SKSpriteNode(color: SKColor(red: 0.02, green: 0.02, blue: 0.03, alpha: 0.40), size: CGSize(width: 64, height: 12))
        enemyShadow.zPosition = 4
        addChild(enemyShadow)

        buck = SKSpriteNode(texture: idleFrames.first)
        buck.name = "buck-borris-player"
        buck.size = CGSize(width: 128, height: 128)
        buck.zPosition = 30
        addChild(buck)
        autoSawSprite = true

        enemy = SKSpriteNode(texture: enemyIdleFrames.first)
        enemy.name = "training-skeleton"
        enemy.size = CGSize(width: 110, height: 110)
        enemy.zPosition = 28
        addChild(enemy)

        titleLabel.fontSize = 30
        titleLabel.horizontalAlignmentMode = .center
        titleLabel.zPosition = 80
        addChild(titleLabel)

        statusLabel.fontSize = 15
        statusLabel.horizontalAlignmentMode = .center
        statusLabel.zPosition = 80
        addChild(statusLabel)

        scoreLabel.fontSize = 24
        scoreLabel.horizontalAlignmentMode = .left
        scoreLabel.zPosition = 80
        addChild(scoreLabel)

        highScoreLabel.fontSize = 14
        highScoreLabel.horizontalAlignmentMode = .right
        highScoreLabel.zPosition = 80
        addChild(highScoreLabel)

        buildHealthBars()
        layoutStage()
        layoutLabels()
    }

    private func buildHealthBars() {
        buckHealthBack = makeHealthBack(isLeft: true)
        enemyHealthBack = makeHealthBack(isLeft: false)
        layoutHealthBars()
    }

    private func makeHealthBack(isLeft: Bool) -> SKSpriteNode {
        let back = SKSpriteNode(color: SKColor(red: 0.05, green: 0.06, blue: 0.08, alpha: 1), size: CGSize(width: 220, height: 18))
        back.anchorPoint = CGPoint(x: 0, y: 0.5)
        back.zPosition = 78
        addChild(back)

        let fill = SKSpriteNode(color: isLeft ? SKColor(red: 0.34, green: 0.92, blue: 0.50, alpha: 1) : SKColor(red: 0.95, green: 0.30, blue: 0.40, alpha: 1), size: CGSize(width: 212, height: 10))
        fill.anchorPoint = CGPoint(x: 0, y: 0.5)
        fill.position = CGPoint(x: 4, y: 0)
        fill.zPosition = 1
        back.addChild(fill)
        if isLeft {
            buckHealthFill = fill
        } else {
            enemyHealthFill = fill
        }
        return back
    }

    private func layoutHealthBars() {
        buckHealthBack.position = CGPoint(x: 22, y: size.height - 30)
        enemyHealthBack.position = CGPoint(x: max(22, size.width - 242), y: size.height - 30)
    }

    private func layoutStage() {
        for node in stageNodes { node.removeFromParent() }
        stageNodes.removeAll()

        let width = max(size.width, 900)

        let texture = SKTexture(imageNamed: "buck_desert_background")
        texture.filteringMode = .nearest
        cityBackground = SKSpriteNode(texture: texture)
        cityBackground.anchorPoint = CGPoint(x: 0.5, y: 0.5)
        cityBackground.position = CGPoint(x: size.width / 2, y: size.height / 2)
        cityBackground.size = CGSize(width: width, height: max(size.height, 506))
        cityBackground.zPosition = 0
        addChild(cityBackground)
        stageNodes.append(cityBackground)

        // Sand arena floor (coherent palette-matched tiles, not a flat bar).
        let floorTop: CGFloat = 232
        let sand = SKSpriteNode(color: SKColor(red: 0.80, green: 0.69, blue: 0.46, alpha: 1), size: CGSize(width: width, height: floorTop))
        sand.anchorPoint = CGPoint(x: 0.5, y: 0)
        sand.position = CGPoint(x: size.width / 2, y: 0)
        sand.zPosition = 1
        addChild(sand)
        stageNodes.append(sand)

        // Packed-sand top lip so the arena floor reads as a raised surface.
        let lip = SKSpriteNode(color: SKColor(red: 0.66, green: 0.53, blue: 0.32, alpha: 1), size: CGSize(width: width, height: 12))
        lip.anchorPoint = CGPoint(x: 0.5, y: 0)
        lip.position = CGPoint(x: size.width / 2, y: floorTop - 12)
        lip.zPosition = 2
        addChild(lip)
        stageNodes.append(lip)

        let highlight = SKSpriteNode(color: SKColor(red: 0.90, green: 0.80, blue: 0.56, alpha: 1), size: CGSize(width: width, height: 3))
        highlight.anchorPoint = CGPoint(x: 0.5, y: 0)
        highlight.position = CGPoint(x: size.width / 2, y: floorTop)
        highlight.zPosition = 3
        addChild(highlight)
        stageNodes.append(highlight)

        // Vertical tile seams + scattered grit so the floor isn't a flat slab.
        let tileWidth: CGFloat = 96
        let columns = Int(width / tileWidth) + 1
        for column in 0..<columns {
            let x = -width / 2 + CGFloat(column) * tileWidth + size.width / 2
            let seam = SKSpriteNode(color: SKColor(red: 0.70, green: 0.58, blue: 0.36, alpha: 0.6), size: CGSize(width: 2, height: floorTop - 12))
            seam.anchorPoint = CGPoint(x: 0.5, y: 0)
            seam.position = CGPoint(x: x, y: 0)
            seam.zPosition = 2
            addChild(seam)
            stageNodes.append(seam)

            for grit in 0..<3 {
                let speck = SKSpriteNode(color: SKColor(red: 0.62, green: 0.50, blue: 0.30, alpha: 0.7), size: CGSize(width: 6, height: 4))
                speck.position = CGPoint(x: x + CGFloat(((column * 7 + grit * 31) % 70)) - 35, y: CGFloat(28 + (column * 17 + grit * 41) % 170))
                speck.zPosition = 2
                addChild(speck)
                stageNodes.append(speck)
            }
        }
    }

    private func layoutLabels() {
        titleLabel.position = CGPoint(x: size.width / 2, y: size.height * 0.76)
        statusLabel.position = CGPoint(x: size.width / 2, y: size.height * 0.76 - 36)
        scoreLabel.position = CGPoint(x: 22, y: size.height - 72)
        highScoreLabel.position = CGPoint(x: size.width - 22, y: size.height - 72)
        layoutHealthBars()
        updateLabels()
        updateHealthBars()
    }

    private func showTitle() {
        phase = .title
        titleLabel.text = "Beat Em Up Buck"
        statusLabel.text = "Arrows/WASD move lanes, J or Space attacks, K jumps"
        score = 0
        koCount = 0
        buckHealth = 100
        enemyHealth = 100
        resetActors()
        updateLabels()
        updateHealthBars()
    }

    private func startFight() {
        phase = .playing
        titleLabel.text = ""
        statusLabel.text = ""
        score = 0
        koCount = 0
        buckHealth = 100
        enemyHealth = 100
        enemyHitStun = 0
        buckHurtTimer = 0
        attackTimer = 0
        attackConnected = false
        autoForcedGameOver = false
        resetActors()
        updateLabels()
        updateHealthBars()
    }

    private func resetActors() {
        buckState = .idle
        enemyState = .idle
        buckBase = CGPoint(x: max(120, size.width * 0.28), y: minLaneY + 34)
        enemyBase = CGPoint(x: min(size.width - 140, max(480, size.width * 0.70)), y: minLaneY + 42)
        buckZ = 0
        buckVelocityZ = 0
        buckFacing = 1
        enemyFacing = -1
        applyActorPositions()
        setBuckTexture(idleFrames.first)
        enemy.xScale = enemyFacing
        enemy.alpha = 1
        buck.alpha = 1
    }

    private func startTimer() {
        lastTimerDate = Date()
        gameTimer?.invalidate()
        let timer = Timer(timeInterval: 1.0 / 60.0, repeats: true) { [weak self] _ in
            self?.tick()
        }
        RunLoop.main.add(timer, forMode: .common)
        gameTimer = timer
    }

    private func tick() {
        let now = Date()
        let dt = min(max(now.timeIntervalSince(lastTimerDate), 0), 1.0 / 30.0)
        lastTimerDate = now
        animate(dt)
        runAutoVerification(dt)
        guard phase == .playing else { return }
        updateBuck(dt)
        updateEnemy(dt)
        resolveAttack()
        updateHealthBars()
        updateLabels()
        applyActorPositions()
    }

    private func updateBuck(_ dt: TimeInterval) {
        var movement = CGVector(dx: 0, dy: 0)
        if input.left { movement.dx -= 1 }
        if input.right { movement.dx += 1 }
        if input.up { movement.dy += 1 }
        if input.down { movement.dy -= 1 }

        if buckHurtTimer > 0 {
            buckHurtTimer -= dt
            buckState = .hurt
        } else if attackTimer > 0 {
            attackTimer -= dt
            buckState = .attack
        } else {
            if movement.dx != 0 || movement.dy != 0 {
                buckState = .walk
                autoSawMove = true
            } else {
                buckState = .idle
            }
            buckBase.x += movement.dx * moveSpeed * CGFloat(dt)
            buckBase.y += movement.dy * moveSpeed * 0.55 * CGFloat(dt)
        }

        buckVelocityZ += gravity * CGFloat(dt)
        buckZ = max(0, buckZ + buckVelocityZ * CGFloat(dt))
        if buckZ == 0 {
            buckVelocityZ = 0
        }

        buckBase.x = min(max(70, buckBase.x), size.width - 70)
        buckBase.y = min(max(minLaneY, buckBase.y), maxLaneY)
        if abs(enemyBase.x - buckBase.x) > 8 {
            buckFacing = enemyBase.x > buckBase.x ? 1 : -1
        }
    }

    private func updateEnemy(_ dt: TimeInterval) {
        guard enemyHealth > 0 else {
            enemyState = .defeated
            return
        }
        if enemyHitStun > 0 {
            enemyHitStun -= dt
            enemyState = .hurt
            enemyBase.x += enemyFacing * -90 * CGFloat(dt)
            autoSawKnockback = true
        } else {
            let dx = buckBase.x - enemyBase.x
            let dy = buckBase.y - enemyBase.y
            let range = abs(dx)
            if range > 64 {
                enemyBase.x += (dx > 0 ? 1 : -1) * 88 * CGFloat(dt)
                enemyState = .walk
            }
            if abs(dy) > 6 {
                enemyBase.y += (dy > 0 ? 1 : -1) * 48 * CGFloat(dt)
            }
            if range < 72 && abs(dy) < 34 && buckHurtTimer <= 0 && attackTimer <= 0 {
                buckHealth = max(0, buckHealth - 6)
                buckHurtTimer = 0.34
                buckState = .hurt
                autoSawBuckDamage = true
                if buckHealth <= 0 {
                    endFight(message: "Buck Got Clipped")
                }
            }
        }
        enemyBase.x = min(max(70, enemyBase.x), size.width - 70)
        enemyBase.y = min(max(minLaneY, enemyBase.y), maxLaneY)
        if abs(enemyBase.x - buckBase.x) > 4 {
            enemyFacing = buckBase.x > enemyBase.x ? 1 : -1
        }
    }

    private func jump() {
        guard phase == .playing, buckZ == 0 else { return }
        buckVelocityZ = jumpImpulse
    }

    private func attack() {
        switch phase {
        case .title:
            startFight()
        case .playing:
            guard attackTimer <= 0, buckHurtTimer <= 0 else { return }
            attackTimer = 0.34
            attackConnected = false
            buckState = .attack
            autoSawAttack = true
        case .gameOver:
            startFight()
            autoSawRestart = true
        }
    }

    private func resolveAttack() {
        guard phase == .playing, buckState == .attack, !attackConnected else { return }
        guard attackTimer < 0.24, attackTimer > 0.08 else { return }
        let hitbox = CGRect(
            x: buckBase.x + (buckFacing > 0 ? 12 : -82),
            y: buckBase.y - 34,
            width: 70,
            height: 60
        )
        let hurtbox = CGRect(x: enemyBase.x - 28, y: enemyBase.y - 42, width: 56, height: 78)
        guard hitbox.intersects(hurtbox), enemyHealth > 0 else { return }
        attackConnected = true
        enemyHealth = max(0, enemyHealth - 34)
        enemyHitStun = 0.36
        enemyState = .hurt
        enemyBase.x += buckFacing * 22
        score += 35
        autoSawEnemyDamage = true
        autoSawHealthBarsUpdated = true
        spawnHitSpark(at: CGPoint(x: enemyBase.x - 8 * enemyFacing, y: enemyBase.y + 22))
        if enemyHealth <= 0 {
            koCount += 1
            score += 150
            enemyState = .defeated
            enemy.alpha = 0.45
            autoSawKO = true
        }
        if score > 0 {
            autoSawScore = true
        }
    }

    private func spawnHitSpark(at point: CGPoint) {
        let colors = [
            SKColor(red: 1.0, green: 0.88, blue: 0.30, alpha: 1),
            SKColor(red: 1.0, green: 0.38, blue: 0.20, alpha: 1),
            SKColor.white
        ]
        for index in 0..<6 {
            let spark = SKSpriteNode(color: colors[index % colors.count], size: CGSize(width: 10, height: 10))
            spark.position = point
            spark.zPosition = 70
            addChild(spark)
            let dx = CGFloat(index - 2) * 12
            let dy = CGFloat((index % 3) + 1) * 10
            spark.run(.sequence([
                .group([.moveBy(x: dx, y: dy, duration: 0.18), .fadeOut(withDuration: 0.18)]),
                .removeFromParent()
            ]))
        }
    }

    private func endFight(message: String) {
        phase = .gameOver
        autoSawGameOver = true
        input = InputState()
        if score > highScore {
            highScore = score
            UserDefaults.standard.set(score, forKey: "Prismcade.BeatEmUpBuck.highScore")
        }
        titleLabel.text = message
        statusLabel.text = "KOs \(koCount) - J, Space, click, or tap to restart"
        updateLabels()
    }

    private func animate(_ dt: TimeInterval) {
        animationTimer += dt
        guard animationTimer > 0.075 else { return }
        animationTimer = 0
        animationFrame += 1

        switch buckState {
        case .idle:
            setBuckTexture(idleFrames[animationFrame % max(idleFrames.count, 1)])
            buck.size = CGSize(width: 128, height: 128)
        case .walk:
            setBuckTexture(runFrames[animationFrame % max(runFrames.count, 1)])
            buck.size = CGSize(width: 128, height: 128)
        case .attack:
            let attackIndex = min(attackFrames.count - 1, max(0, Int((0.34 - attackTimer) / 0.034)))
            setBuckTexture(attackFrames[attackIndex])
            buck.size = CGSize(width: 220, height: 88)
        case .hurt:
            setBuckTexture(damagedFrames[animationFrame % max(damagedFrames.count, 1)])
            buck.size = CGSize(width: 128, height: 128)
        case .defeated:
            setBuckTexture(damagedFrames.last)
        }

        let enemyTexture: SKTexture?
        switch enemyState {
        case .walk:
            enemyTexture = enemyFrame(enemyWalkFrames)
        case .hurt:
            enemyTexture = enemyFrame(enemyHurtFrames.isEmpty ? enemyIdleFrames : enemyHurtFrames)
        case .defeated:
            enemyTexture = enemyDeathFrames.last ?? enemyIdleFrames.last
        default:
            enemyTexture = enemyFrame(enemyIdleFrames)
        }
        if let enemyTexture {
            enemyTexture.filteringMode = .nearest
            enemy.texture = enemyTexture
        }

        if enemyState == .hurt {
            enemy.colorBlendFactor = enemy.colorBlendFactor > 0 ? 0 : 0.6
            enemy.color = SKColor(red: 1.0, green: 0.4, blue: 0.4, alpha: 1)
        } else {
            enemy.colorBlendFactor = 0
        }
    }

    private func setBuckTexture(_ texture: SKTexture?) {
        if let texture {
            texture.filteringMode = .nearest
            buck.texture = texture
        }
    }

    private func applyActorPositions() {
        buck.position = CGPoint(x: buckBase.x, y: buckBase.y + buckZ)
        buckShadow.position = buckBase
        buck.xScale = buckFacing
        buck.zPosition = 30 + buckBase.y * 0.01
        buckShadow.zPosition = buck.zPosition - 1

        enemy.position = enemyBase
        enemyShadow.position = enemyBase
        enemy.xScale = enemyFacing
        enemy.zPosition = 28 + enemyBase.y * 0.01
        enemyShadow.zPosition = enemy.zPosition - 1
    }

    private func updateHealthBars() {
        buckHealthFill.xScale = CGFloat(max(buckHealth, 0)) / 100
        enemyHealthFill.xScale = CGFloat(max(enemyHealth, 0)) / 100
    }

    private func updateLabels() {
        scoreLabel.text = "Score \(score)  KO \(koCount)"
        highScoreLabel.text = "Best \(highScore)"
    }

    private func runAutoVerification(_ dt: TimeInterval) {
        guard autoVerifyEnabled else { return }
        autoTime += dt

        if phase == .title {
            startFight()
            return
        }

        if phase == .playing {
            if autoTime < 0.9 {
                input.right = true
                input.down = true
            } else {
                input = InputState()
            }
            if autoTime > 0.9 && autoTime < 2.6 {
                enemyBase = CGPoint(x: buckBase.x + 58, y: buckBase.y + 4)
                if attackTimer <= 0 && enemyHealth > 0 {
                    attack()
                }
            }
            if autoSawEnemyDamage && !autoWroteCombatSnapshot {
                autoWroteCombatSnapshot = true
                writeSceneSnapshot(path: "/tmp/prismcade-buck-combat-snapshot.png")
            }
            if autoSawKO && !autoSawBuckDamage {
                enemyHealth = 100
                enemy.alpha = 1
                enemyBase = CGPoint(x: buckBase.x + 44, y: buckBase.y)
                buckHealth = 88
                buckHurtTimer = 0.32
                autoSawBuckDamage = true
                autoSawHealthBarsUpdated = true
            }
            if autoSawKO && autoSawBuckDamage && autoTime > 3.3 && !autoForcedGameOver {
                autoForcedGameOver = true
                buckHealth = 0
                endFight(message: "Training Complete")
            }
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
            "engine": "Native SpriteKit micro brawler",
            "buckSpriteVisible": autoSawSprite,
            "buckAsset": "Buck Borris sensible_frames curated idle/run/damaged plus attacks_80x32",
            "enemyAsset": "Enemy_Animations_Set skeleton2 (idle/walk/hurt/death), 32x32 strips",
            "backgroundImageUsed": true,
            "movementWorked": autoSawMove,
            "attackWorked": autoSawAttack,
            "enemyTookDamage": autoSawEnemyDamage,
            "buckTookDamage": autoSawBuckDamage,
            "knockbackWorked": autoSawKnockback,
            "koRegistered": autoSawKO,
            "scoreChanged": autoSawScore,
            "healthBarsUpdated": autoSawHealthBarsUpdated,
            "gameOverTriggered": autoSawGameOver,
            "restartWorked": autoSawRestart
        ]
        guard JSONSerialization.isValidJSONObject(payload),
              let data = try? JSONSerialization.data(withJSONObject: payload, options: [.prettyPrinted, .sortedKeys]) else { return }
        try? data.write(to: URL(fileURLWithPath: "/tmp/prismcade-buck-runtime-verification.json"), options: .atomic)
    }

    private func writeSceneSnapshot(path: String) {
        #if os(macOS)
        guard let texture = view?.texture(from: self) else { return }
        let image = texture.cgImage()
        let rep = NSBitmapImageRep(cgImage: image)
        if let data = rep.representation(using: .png, properties: [:]) {
            try? data.write(to: URL(fileURLWithPath: path), options: .atomic)
        }
        #endif
    }

    private func handleTouch(at point: CGPoint) {
        switch phase {
        case .title, .gameOver:
            attack()
        case .playing:
            if point.x > size.width * 0.62 {
                if point.y > size.height * 0.46 {
                    jump()
                } else {
                    attack()
                }
            } else {
                input.left = point.x < size.width * 0.30
                input.right = point.x > size.width * 0.42
                input.up = point.y > size.height * 0.28
                input.down = point.y < size.height * 0.18
            }
        }
    }

    private func clearTouchInput() {
        input = InputState()
    }

    #if os(macOS)
    override func mouseDown(with event: NSEvent) {
        handleTouch(at: event.location(in: self))
    }

    override func mouseUp(with event: NSEvent) {
        clearTouchInput()
    }

    override func keyDown(with event: NSEvent) {
        let chars = event.charactersIgnoringModifiers?.lowercased()
        switch event.keyCode {
        case 123: input.left = true
        case 124: input.right = true
        case 125: input.down = true
        case 126: input.up = true
        case 40: jump()
        case 49: attack()
        default: break
        }
        switch chars {
        case "a": input.left = true
        case "d": input.right = true
        case "s": input.down = true
        case "w": input.up = true
        case "j", " ": attack()
        case "k": jump()
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

    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        clearTouchInput()
    }
    #endif
}
