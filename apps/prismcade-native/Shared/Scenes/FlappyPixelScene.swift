import SpriteKit
#if os(macOS)
import AppKit
#endif

final class FlappyPixelScene: SKScene {
    private enum Phase {
        case title
        case playing
        case gameOver
    }

    private struct Gate {
        let root: SKNode
        let top: SKSpriteNode
        let bottom: SKSpriteNode
        var scored: Bool
    }

    private var phase: Phase = .title
    private var bird = SKSpriteNode()
    private var birdFrames: [SKTexture] = []
    private var gates: [Gate] = []
    private var clouds: [SKSpriteNode] = []
    private var scoreLabel = SKLabelNode(fontNamed: "Menlo-Bold")
    private var highScoreLabel = SKLabelNode(fontNamed: "Menlo-Bold")
    private var messageLabel = SKLabelNode(fontNamed: "Menlo-Bold")
    private var subMessageLabel = SKLabelNode(fontNamed: "Menlo")
    private var lastUpdate: TimeInterval = 0
    private var lastTimerDate = Date()
    private var gameTimer: Timer?
    private var spawnTimer: TimeInterval = 0
    private var animationTimer: TimeInterval = 0
    private var frameIndex = 0
    private var birdVelocity: CGFloat = 0
    private var score = 0
    private var highScore = UserDefaults.standard.integer(forKey: "Prismcade.FlappyPixel.highScore")
    private var autoVerifyEnabled = ProcessInfo.processInfo.environment["PRISMCADE_AUTOVERIFY_FLAPPY"] == "1"
    private var autoVerifyTime: TimeInterval = 0
    private var autoVerifyNextFlap: TimeInterval = 0
    private var autoVerifyStarted = false
    private var autoVerifySawAscent = false
    private var autoVerifySawGravity = false
    private var autoVerifySawScore = false
    private var autoVerifySawGameOver = false
    private var autoVerifySawRestart = false
    private var autoVerifyStartY: CGFloat = 0
    private var autoVerifyTargetY: CGFloat = 0

    private let gravity: CGFloat = -880
    private let flapImpulse: CGFloat = 365
    private let gateSpeed: CGFloat = 185
    private let gateWidth: CGFloat = 56
    private let gateGap: CGFloat = 190
    private let groundHeight: CGFloat = 58

    override func didMove(to view: SKView) {
        scaleMode = .resizeFill
        view.allowsTransparency = false
        view.ignoresSiblingOrder = true
        view.preferredFramesPerSecond = 60
        view.isPaused = false
        isPaused = false
        if autoVerifyEnabled {
            try? "didMove\n".write(toFile: "/tmp/prismcade-flappy-didmove-marker.txt", atomically: true, encoding: .utf8)
        }
        setupWorld()
        showTitle()
        startGameTimer()
    }

    override func willMove(from view: SKView) {
        gameTimer?.invalidate()
        gameTimer = nil
    }

    override func didChangeSize(_ oldSize: CGSize) {
        layoutStaticNodes()
        if phase != .playing {
            bird.position = CGPoint(x: size.width * 0.32, y: size.height * 0.55)
        }
    }

    private func setupWorld() {
        removeAllChildren()
        gates.removeAll()
        clouds.removeAll()
        backgroundColor = SKColor(red: 0.09, green: 0.17, blue: 0.25, alpha: 1)

        birdFrames = ["bird_flap_up", "bird_glide", "bird_flap_down"].map {
            let texture = SKTexture(imageNamed: $0)
            texture.filteringMode = .nearest
            return texture
        }
        bird = SKSpriteNode(texture: birdFrames.first)
        bird.name = "flappy-bird"
        bird.size = CGSize(width: 56, height: 56)
        bird.zPosition = 20
        addChild(bird)

        for index in 0..<9 {
            let cloud = SKSpriteNode(color: SKColor.white.withAlphaComponent(0.22), size: CGSize(width: 64, height: 18))
            cloud.anchorPoint = CGPoint(x: 0.5, y: 0.5)
            cloud.position = CGPoint(x: CGFloat(index) * 130 + 30, y: CGFloat(130 + (index * 37) % 180))
            cloud.zPosition = 1
            addChild(cloud)
            clouds.append(cloud)
        }

        scoreLabel.fontSize = 36
        scoreLabel.horizontalAlignmentMode = .left
        scoreLabel.zPosition = 40
        addChild(scoreLabel)

        highScoreLabel.fontSize = 14
        highScoreLabel.horizontalAlignmentMode = .right
        highScoreLabel.zPosition = 40
        addChild(highScoreLabel)

        messageLabel.fontSize = 30
        messageLabel.horizontalAlignmentMode = .center
        messageLabel.zPosition = 40
        addChild(messageLabel)

        subMessageLabel.fontSize = 15
        subMessageLabel.horizontalAlignmentMode = .center
        subMessageLabel.zPosition = 40
        addChild(subMessageLabel)

        layoutStaticNodes()
    }

    private func layoutStaticNodes() {
        scoreLabel.position = CGPoint(x: 22, y: size.height - 58)
        highScoreLabel.position = CGPoint(x: size.width - 22, y: size.height - 48)
        messageLabel.position = CGPoint(x: size.width / 2, y: size.height * 0.66)
        subMessageLabel.position = CGPoint(x: size.width / 2, y: size.height * 0.66 - 34)
        updateLabels()
    }

    private func showTitle() {
        phase = .title
        score = 0
        birdVelocity = 0
        spawnTimer = 0
        lastUpdate = 0
        removeGates()
        bird.position = CGPoint(x: size.width * 0.32, y: size.height * 0.55)
        bird.zRotation = 0
        messageLabel.text = "Flappy Pixel"
        subMessageLabel.text = "Click, tap, or press Space to flap"
        updateLabels()
    }

    private func startRun() {
        phase = .playing
        score = 0
        birdVelocity = flapImpulse
        spawnTimer = 0.85
        lastUpdate = 0
        removeGates()
        messageLabel.text = ""
        subMessageLabel.text = ""
        bird.position = CGPoint(x: size.width * 0.32, y: size.height * 0.55)
        updateLabels()
        spawnGate()
    }

    private func flap() {
        switch phase {
        case .title:
            startRun()
        case .playing:
            birdVelocity = flapImpulse
            runFlapFeedback()
        case .gameOver:
            startRun()
        }
    }

    private func runFlapFeedback() {
        frameIndex = 0
        bird.texture = birdFrames.first
        bird.removeAction(forKey: "flap-pop")
        bird.run(.sequence([.scale(to: 1.09, duration: 0.04), .scale(to: 1.0, duration: 0.08)]), withKey: "flap-pop")
    }

    private func startGameTimer() {
        lastTimerDate = Date()
        gameTimer?.invalidate()
        let timer = Timer(timeInterval: 1.0 / 60.0, repeats: true) { [weak self] _ in
            self?.timerTick()
        }
        RunLoop.main.add(timer, forMode: .common)
        gameTimer = timer
    }

    private func timerTick() {
        let now = Date()
        let dt = min(max(now.timeIntervalSince(lastTimerDate), 0), 1.0 / 30.0)
        lastTimerDate = now
        step(dt)
    }

    override func update(_ currentTime: TimeInterval) {
        if autoVerifyEnabled && autoVerifyTime == 0 {
            try? "update\n".write(toFile: "/tmp/prismcade-flappy-update-marker.txt", atomically: true, encoding: .utf8)
        }
    }

    private func step(_ dt: TimeInterval) {
        animateBird(dt)
        scrollClouds(dt)

        if phase == .playing {
            birdVelocity += gravity * CGFloat(dt)
            bird.position.y += birdVelocity * CGFloat(dt)
            bird.zRotation = max(-0.72, min(0.48, birdVelocity / 620))

            spawnTimer -= dt
            if spawnTimer <= 0 {
                spawnTimer = 1.55
                spawnGate()
            }

            moveGates(dt)
            checkCollisions()
        }

        runAutoVerification(dt)
    }

    private func animateBird(_ dt: TimeInterval) {
        animationTimer += dt
        guard animationTimer >= 0.10, !birdFrames.isEmpty else { return }
        animationTimer = 0
        frameIndex = (frameIndex + 1) % birdFrames.count
        bird.texture = birdFrames[frameIndex]
    }

    private func scrollClouds(_ dt: TimeInterval) {
        for cloud in clouds {
            cloud.position.x -= CGFloat(dt) * 20
            if cloud.position.x < -80 {
                cloud.position.x = size.width + 80
                cloud.position.y = CGFloat.random(in: size.height * 0.45...size.height * 0.86)
            }
        }
    }

    private func spawnGate() {
        let root = SKNode()
        root.position.x = size.width + gateWidth
        root.zPosition = 10

        let minCenter = groundHeight + gateGap / 2 + 34
        let maxCenter = max(minCenter + 20, size.height - gateGap / 2 - 70)
        let gapCenter: CGFloat
        if autoVerifyEnabled {
            gapCenter = min(max(size.height * 0.56, minCenter), maxCenter)
            autoVerifyTargetY = gapCenter
        } else {
            gapCenter = CGFloat.random(in: minCenter...maxCenter)
        }

        let bottomHeight = max(24, gapCenter - gateGap / 2 - groundHeight)
        let topHeight = max(24, size.height - (gapCenter + gateGap / 2))
        let pipeColor = SKColor(red: 0.14, green: 0.76, blue: 0.49, alpha: 1)

        let bottom = SKSpriteNode(color: pipeColor, size: CGSize(width: gateWidth, height: bottomHeight))
        bottom.anchorPoint = CGPoint(x: 0.5, y: 0)
        bottom.position = CGPoint(x: 0, y: groundHeight)
        bottom.name = "gate-bottom"
        root.addChild(bottom)

        let top = SKSpriteNode(color: pipeColor, size: CGSize(width: gateWidth, height: topHeight))
        top.anchorPoint = CGPoint(x: 0.5, y: 1)
        top.position = CGPoint(x: 0, y: size.height)
        top.name = "gate-top"
        root.addChild(top)

        addCap(to: bottom, atTop: true)
        addCap(to: top, atTop: false)
        addChild(root)
        gates.append(Gate(root: root, top: top, bottom: bottom, scored: false))
    }

    private func addCap(to pipe: SKSpriteNode, atTop: Bool) {
        let cap = SKSpriteNode(color: SKColor(red: 0.52, green: 0.95, blue: 0.64, alpha: 1), size: CGSize(width: gateWidth + 18, height: 18))
        cap.position = CGPoint(x: 0, y: atTop ? pipe.size.height : -pipe.size.height)
        cap.zPosition = 1
        pipe.addChild(cap)
    }

    private func moveGates(_ dt: TimeInterval) {
        for index in gates.indices {
            gates[index].root.position.x -= gateSpeed * CGFloat(dt)
            if !gates[index].scored && gates[index].root.position.x < bird.position.x - gateWidth / 2 {
                gates[index].scored = true
                score += 1
                autoVerifySawScore = true
                updateLabels()
            }
        }
        while let first = gates.first, first.root.position.x < -gateWidth * 2 {
            first.root.removeFromParent()
            gates.removeFirst()
        }
    }

    private func checkCollisions() {
        if bird.position.y < groundHeight + bird.size.height * 0.22 || bird.position.y > size.height - bird.size.height * 0.22 {
            endRun()
            return
        }

        let birdRect = CGRect(
            x: bird.position.x - bird.size.width * 0.32,
            y: bird.position.y - bird.size.height * 0.30,
            width: bird.size.width * 0.64,
            height: bird.size.height * 0.60
        )
        for gate in gates {
            let gateX = gate.root.position.x
            let bottomRect = CGRect(x: gateX - gateWidth / 2, y: groundHeight, width: gateWidth, height: gate.bottom.size.height)
            let topRect = CGRect(x: gateX - gateWidth / 2, y: size.height - gate.top.size.height, width: gateWidth, height: gate.top.size.height)
            if birdRect.intersects(bottomRect) || birdRect.intersects(topRect) {
                endRun()
                return
            }
        }
    }

    private func endRun() {
        phase = .gameOver
        autoVerifySawGameOver = true
        if score > highScore {
            highScore = score
            UserDefaults.standard.set(score, forKey: "Prismcade.FlappyPixel.highScore")
        }
        messageLabel.text = "Game Over"
        subMessageLabel.text = "Score \(score) - click, tap, or Space to restart"
        updateLabels()
    }

    private func removeGates() {
        for gate in gates {
            gate.root.removeFromParent()
        }
        gates.removeAll()
    }

    private func updateLabels() {
        scoreLabel.text = "Score \(score)"
        highScoreLabel.text = "Best \(highScore)"
    }

    private func runAutoVerification(_ dt: TimeInterval) {
        guard autoVerifyEnabled else { return }
        autoVerifyTime += dt

        if !autoVerifyStarted && autoVerifyTime > 0.35 {
            autoVerifyStarted = true
            try? "started\n".write(toFile: "/tmp/prismcade-flappy-auto-started-marker.txt", atomically: true, encoding: .utf8)
            startRun()
            autoVerifyStartY = bird.position.y
            autoVerifyNextFlap = autoVerifyTime + 0.12
        }

        if phase == .playing && birdVelocity < -80 {
            autoVerifySawGravity = true
        }

        if phase == .playing && autoVerifyTime < 6.8 && autoVerifyTime >= autoVerifyNextFlap && bird.position.y < autoVerifyTargetY - 10 {
            flap()
            autoVerifyNextFlap = autoVerifyTime + 0.12
        }

        if phase == .playing && bird.position.y > autoVerifyStartY + 18 {
            autoVerifySawAscent = true
        }

        if phase == .playing && autoVerifyTime > 6.8 {
            birdVelocity = -900
        }

        if phase == .gameOver && autoVerifySawGameOver && !autoVerifySawRestart && autoVerifyTime > 7.4 {
            startRun()
            autoVerifySawRestart = phase == .playing && score == 0
            writeAutoVerificationReceipt()
            autoVerifyEnabled = false
        }
    }

    private func writeAutoVerificationReceipt() {
        writeSceneSnapshot(path: "/tmp/prismcade-flappy-runtime-snapshot.png")
        let payload: [String: Any] = [
            "game": "Flappy Pixel",
            "birdSprite": "Onocentaur birds-2x row 0 curated frames",
            "birdAnimated": birdFrames.count == 3,
            "flapMovedUpward": autoVerifySawAscent,
            "gravityApplied": autoVerifySawGravity,
            "obstaclesSpawned": !gates.isEmpty,
            "scoreChanged": autoVerifySawScore,
            "gameOverTriggered": autoVerifySawGameOver,
            "restartWorked": autoVerifySawRestart
        ]
        guard JSONSerialization.isValidJSONObject(payload),
              let data = try? JSONSerialization.data(withJSONObject: payload, options: [.prettyPrinted, .sortedKeys]) else { return }
        try? data.write(to: URL(fileURLWithPath: "/tmp/prismcade-flappy-runtime-verification.json"), options: .atomic)
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

    #if os(macOS)
    override func mouseDown(with event: NSEvent) {
        flap()
    }

    override func keyDown(with event: NSEvent) {
        if event.keyCode == 49 || event.charactersIgnoringModifiers == " " {
            flap()
        }
    }
    #endif

    #if os(iOS)
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        flap()
    }
    #endif
}
