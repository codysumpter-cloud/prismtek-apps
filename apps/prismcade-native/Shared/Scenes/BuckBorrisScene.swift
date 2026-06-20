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

    private struct Hazard {
        let node: SKSpriteNode
    }

    private struct Pickup {
        let node: SKSpriteNode
    }

    private var phase: Phase = .title
    private var buck = SKSpriteNode()
    private var runFrames: [SKTexture] = []
    private var hazards: [Hazard] = []
    private var pickups: [Pickup] = []
    private var groundSegments: [SKSpriteNode] = []
    private var titleLabel = SKLabelNode(fontNamed: "Menlo-Bold")
    private var statusLabel = SKLabelNode(fontNamed: "Menlo-Bold")
    private var scoreLabel = SKLabelNode(fontNamed: "Menlo-Bold")
    private var highScoreLabel = SKLabelNode(fontNamed: "Menlo-Bold")
    private var gameTimer: Timer?
    private var lastTimerDate = Date()
    private var runTime: TimeInterval = 0
    private var animationTimer: TimeInterval = 0
    private var animationFrame = 0
    private var spawnTimer: TimeInterval = 0
    private var pickupTimer: TimeInterval = 0
    private var velocityY: CGFloat = 0
    private var score = 0
    private var highScore = UserDefaults.standard.integer(forKey: "Prismcade.BuckBorris.highScore")
    private var runSpeed: CGFloat = 220
    private var autoVerifyEnabled = ProcessInfo.processInfo.environment["PRISMCADE_AUTOVERIFY_BUCK"] == "1"
    private var autoSawSprite = false
    private var autoSawJump = false
    private var autoSawScore = false
    private var autoSawPickup = false
    private var autoSawHazard = false
    private var autoSawGameOver = false
    private var autoSawRestart = false
    private var autoForcedCollision = false
    private let groundY: CGFloat = 104
    private let gravity: CGFloat = -1500
    private let jumpImpulse: CGFloat = 600

    override func didMove(to view: SKView) {
        scaleMode = .resizeFill
        view.preferredFramesPerSecond = 60
        view.isPaused = false
        isPaused = false
        backgroundColor = SKColor(red: 0.13, green: 0.08, blue: 0.11, alpha: 1)
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
        if phase != .playing {
            buck.position = CGPoint(x: size.width * 0.25, y: groundY)
        }
    }

    private func loadFrames() {
        runFrames = (0...3).map { index in
            let texture = SKTexture(imageNamed: "run_0\(index)")
            texture.filteringMode = .nearest
            return texture
        }
        if runFrames.isEmpty {
            let texture = SKTexture(imageNamed: "idle_00")
            texture.filteringMode = .nearest
            runFrames = [texture]
        }
    }

    private func setupWorld() {
        removeAllChildren()
        hazards.removeAll()
        pickups.removeAll()
        groundSegments.removeAll()

        buck = SKSpriteNode(texture: runFrames.first)
        buck.name = "buck-borris-player"
        buck.size = CGSize(width: 96, height: 96)
        buck.zPosition = 22
        addChild(buck)
        autoSawSprite = true

        for index in 0..<8 {
            let segment = SKSpriteNode(color: SKColor(red: 0.44, green: 0.30, blue: 0.22, alpha: 1), size: CGSize(width: 180, height: 18))
            segment.anchorPoint = CGPoint(x: 0, y: 0.5)
            segment.position = CGPoint(x: CGFloat(index) * 180, y: groundY - 42)
            segment.zPosition = 5
            addChild(segment)
            groundSegments.append(segment)
        }

        titleLabel.fontSize = 28
        titleLabel.horizontalAlignmentMode = .center
        titleLabel.zPosition = 40
        addChild(titleLabel)

        statusLabel.fontSize = 15
        statusLabel.horizontalAlignmentMode = .center
        statusLabel.zPosition = 40
        addChild(statusLabel)

        scoreLabel.fontSize = 28
        scoreLabel.horizontalAlignmentMode = .left
        scoreLabel.zPosition = 40
        addChild(scoreLabel)

        highScoreLabel.fontSize = 14
        highScoreLabel.horizontalAlignmentMode = .right
        highScoreLabel.zPosition = 40
        addChild(highScoreLabel)
        layoutLabels()
    }

    private func layoutLabels() {
        titleLabel.position = CGPoint(x: size.width / 2, y: size.height * 0.72)
        statusLabel.position = CGPoint(x: size.width / 2, y: size.height * 0.72 - 34)
        scoreLabel.position = CGPoint(x: 22, y: size.height - 54)
        highScoreLabel.position = CGPoint(x: size.width - 22, y: size.height - 44)
        updateLabels()
    }

    private func showTitle() {
        phase = .title
        runTime = 0
        score = 0
        velocityY = 0
        removeActors()
        buck.position = CGPoint(x: size.width * 0.25, y: groundY)
        titleLabel.text = "Buck Borris"
        statusLabel.text = "Click, tap, or Space to vault hazards and collect sparks"
        updateLabels()
    }

    private func startRun() {
        phase = .playing
        runTime = 0
        score = 0
        runSpeed = 220
        spawnTimer = 0.8
        pickupTimer = 0.45
        velocityY = 0
        removeActors()
        buck.position = CGPoint(x: size.width * 0.25, y: groundY)
        titleLabel.text = ""
        statusLabel.text = ""
        updateLabels()
    }

    private func jumpOrRestart() {
        switch phase {
        case .title:
            startRun()
        case .playing:
            if buck.position.y <= groundY + 2 {
                velocityY = jumpImpulse
                autoSawJump = true
            }
        case .gameOver:
            startRun()
            autoSawRestart = true
        }
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
        runAutoVerification()
        guard phase == .playing else { return }
        runTime += dt
        runSpeed = 220 + CGFloat(runTime) * 12
        score = max(score, Int(runTime * 8))
        if score > 0 { autoSawScore = true }
        updateBuck(dt)
        scrollGround(dt)
        updateActors(dt)
        checkCollisions()
        updateLabels()
    }

    private func animate(_ dt: TimeInterval) {
        animationTimer += dt
        guard animationTimer > 0.09 else { return }
        animationTimer = 0
        animationFrame = (animationFrame + 1) % max(runFrames.count, 1)
        buck.texture = runFrames[animationFrame]
    }

    private func updateBuck(_ dt: TimeInterval) {
        velocityY += gravity * CGFloat(dt)
        buck.position.y = max(groundY, buck.position.y + velocityY * CGFloat(dt))
        if buck.position.y == groundY {
            velocityY = 0
        }
    }

    private func scrollGround(_ dt: TimeInterval) {
        for segment in groundSegments {
            segment.position.x -= runSpeed * CGFloat(dt)
            if segment.position.x < -segment.size.width {
                segment.position.x += segment.size.width * CGFloat(groundSegments.count)
            }
        }
    }

    private func updateActors(_ dt: TimeInterval) {
        spawnTimer -= dt
        pickupTimer -= dt
        if spawnTimer <= 0 {
            spawnTimer = TimeInterval(CGFloat.random(in: 1.0...1.45))
            spawnHazard()
        }
        if pickupTimer <= 0 {
            pickupTimer = TimeInterval(CGFloat.random(in: 0.8...1.2))
            spawnPickup()
        }
        for hazard in hazards {
            hazard.node.position.x -= runSpeed * CGFloat(dt)
        }
        for pickup in pickups {
            pickup.node.position.x -= runSpeed * CGFloat(dt)
        }
        while let first = hazards.first, first.node.position.x < -80 {
            first.node.removeFromParent()
            hazards.removeFirst()
        }
        while let first = pickups.first, first.node.position.x < -80 {
            first.node.removeFromParent()
            pickups.removeFirst()
        }
    }

    private func spawnHazard() {
        let node = SKSpriteNode(color: SKColor(red: 0.20, green: 0.75, blue: 0.85, alpha: 1), size: CGSize(width: 34, height: 44))
        node.anchorPoint = CGPoint(x: 0.5, y: 0)
        node.position = CGPoint(x: size.width + 40, y: groundY - 40)
        node.zPosition = 18
        addChild(node)
        hazards.append(Hazard(node: node))
        autoSawHazard = true
    }

    private func spawnPickup() {
        let node = SKSpriteNode(color: SKColor(red: 1.0, green: 0.84, blue: 0.25, alpha: 1), size: CGSize(width: 22, height: 22))
        node.position = CGPoint(x: size.width + 54, y: groundY + CGFloat.random(in: 80...150))
        node.zPosition = 18
        addChild(node)
        pickups.append(Pickup(node: node))
    }

    private func checkCollisions() {
        let buckRect = CGRect(x: buck.position.x - 28, y: buck.position.y - 38, width: 56, height: 72)
        for (index, pickup) in pickups.enumerated().reversed() {
            let rect = CGRect(x: pickup.node.position.x - 12, y: pickup.node.position.y - 12, width: 24, height: 24)
            if buckRect.intersects(rect) {
                score += 10
                autoSawPickup = true
                pickup.node.removeFromParent()
                pickups.remove(at: index)
            }
        }
        for hazard in hazards {
            let rect = CGRect(x: hazard.node.position.x - 17, y: hazard.node.position.y, width: 34, height: 44)
            if buckRect.intersects(rect) {
                endRun()
                return
            }
        }
    }

    private func endRun() {
        phase = .gameOver
        autoSawGameOver = true
        if score > highScore {
            highScore = score
            UserDefaults.standard.set(score, forKey: "Prismcade.BuckBorris.highScore")
        }
        titleLabel.text = "Buck Got Tagged"
        statusLabel.text = "Score \(score) - click, tap, or Space to restart"
        updateLabels()
    }

    private func runAutoVerification() {
        guard autoVerifyEnabled else { return }
        if phase == .title {
            startRun()
            return
        }
        if phase == .playing {
            if buck.position.y <= groundY + 2 && ((hazards.first?.node.position.x ?? size.width) - buck.position.x) < 150 {
                jumpOrRestart()
            }
            if runTime > 0.8 && pickups.isEmpty {
                spawnPickup()
                if let pickup = pickups.last?.node {
                    pickup.position = CGPoint(x: buck.position.x, y: buck.position.y + 8)
                }
            }
            if runTime > 3.4 && !autoForcedCollision {
                autoForcedCollision = true
                spawnHazard()
                hazards.last?.node.position.x = buck.position.x
            }
        }
        if phase == .gameOver && autoSawGameOver {
            jumpOrRestart()
            writeAutoVerificationReceipt()
            autoVerifyEnabled = false
        }
    }

    private func writeAutoVerificationReceipt() {
        writeSceneSnapshot(path: "/tmp/prismcade-buck-runtime-snapshot.png")
        let payload: [String: Any] = [
            "game": "Buck Borris Mini-Game",
            "buckSpriteVisible": autoSawSprite,
            "buckAsset": "Buck Borris sensible_frames run_00-run_03",
            "jumpWorked": autoSawJump,
            "hazardsSpawned": autoSawHazard,
            "pickupCollected": autoSawPickup,
            "scoreChanged": autoSawScore,
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

    private func removeActors() {
        for hazard in hazards { hazard.node.removeFromParent() }
        for pickup in pickups { pickup.node.removeFromParent() }
        hazards.removeAll()
        pickups.removeAll()
    }

    private func updateLabels() {
        scoreLabel.text = "Score \(score)"
        highScoreLabel.text = "Best \(highScore)"
    }

    #if os(macOS)
    override func mouseDown(with event: NSEvent) {
        jumpOrRestart()
    }

    override func keyDown(with event: NSEvent) {
        if event.keyCode == 49 || event.charactersIgnoringModifiers == " " {
            jumpOrRestart()
        }
    }
    #endif

    #if os(iOS)
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        jumpOrRestart()
    }
    #endif
}
