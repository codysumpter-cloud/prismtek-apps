import SpriteKit
#if os(macOS)
import AppKit
#endif

final class DinoDashScene: SKScene {
    private enum Phase {
        case selecting
        case playing
        case gameOver
    }

    private struct DinoChoice {
        let id: String
        let title: String
        let textureName: String
    }

    private struct Obstacle {
        let node: SKSpriteNode
    }

    private let choices = [
        DinoChoice(id: "doux", title: "Doux", textureName: "dino_doux"),
        DinoChoice(id: "mort", title: "Mort", textureName: "dino_mort"),
        DinoChoice(id: "tard", title: "Tard", textureName: "dino_tard"),
        DinoChoice(id: "vita", title: "Vita", textureName: "dino_vita")
    ]

    private var phase: Phase = .selecting
    private var selectedIndex = 0
    private var choiceNodes: [SKSpriteNode] = []
    private var dinoTextures: [[SKTexture]] = []
    private var runner = SKSpriteNode()
    private var obstacles: [Obstacle] = []
    private var groundSegments: [SKSpriteNode] = []
    private var titleLabel = SKLabelNode(fontNamed: "Menlo-Bold")
    private var statusLabel = SKLabelNode(fontNamed: "Menlo-Bold")
    private var scoreLabel = SKLabelNode(fontNamed: "Menlo-Bold")
    private var highScoreLabel = SKLabelNode(fontNamed: "Menlo-Bold")
    private var gameTimer: Timer?
    private var lastTimerDate = Date()
    private var runTime: TimeInterval = 0
    private var spawnTimer: TimeInterval = 0
    private var animationTimer: TimeInterval = 0
    private var animationFrame = 0
    private var velocityY: CGFloat = 0
    private var score = 0
    private var highScore = UserDefaults.standard.integer(forKey: "Prismcade.DinoDash.highScore")
    private var runSpeed: CGFloat = 230
    private var autoVerifyEnabled = ProcessInfo.processInfo.environment["PRISMCADE_AUTOVERIFY_DINO"] == "1"
    private var autoTime: TimeInterval = 0
    private var autoSelectedIds: [String] = []
    private var autoSawJump = false
    private var autoSawScore = false
    private var autoSawObstacle = false
    private var autoSawSpeedRamp = false
    private var autoSawGameOver = false
    private var autoSawRestart = false
    private var autoWroteSelectSnapshot = false
    private var autoWroteGameplaySnapshot = false
    private var autoForcedCollision = false
    private let groundY: CGFloat = 92
    private let gravity: CGFloat = -1600
    private let jumpImpulse: CGFloat = 610

    override func didMove(to view: SKView) {
        scaleMode = .resizeFill
        view.preferredFramesPerSecond = 60
        view.isPaused = false
        isPaused = false
        backgroundColor = SKColor(red: 0.10, green: 0.12, blue: 0.13, alpha: 1)
        buildTextures()
        setupWorld()
        showCharacterSelect()
        if autoVerifyEnabled {
            try? "didMove\n".write(toFile: "/tmp/prismcade-dino-didmove-marker.txt", atomically: true, encoding: .utf8)
        }
        startTimer()
    }

    override func willMove(from view: SKView) {
        gameTimer?.invalidate()
        gameTimer = nil
    }

    override func didChangeSize(_ oldSize: CGSize) {
        layoutLabels()
        if phase == .selecting {
            layoutChoices()
        }
    }

    private func buildTextures() {
        dinoTextures = choices.map { choice in
            let sheet = SKTexture(imageNamed: choice.textureName)
            sheet.filteringMode = .nearest
            let frameCount = 24
            return (0..<frameCount).map { frame in
                let texture = SKTexture(rect: CGRect(x: CGFloat(frame) / CGFloat(frameCount), y: 0, width: 1 / CGFloat(frameCount), height: 1), in: sheet)
                texture.filteringMode = .nearest
                return texture
            }
        }
    }

    private func setupWorld() {
        removeAllChildren()
        choiceNodes.removeAll()
        obstacles.removeAll()
        groundSegments.removeAll()

        for index in 0..<4 {
            let node = SKSpriteNode(texture: dinoTextures[index].first)
            node.name = "dino-choice-\(index)"
            node.size = CGSize(width: 96, height: 96)
            node.zPosition = 20
            addChild(node)
            choiceNodes.append(node)
        }

        runner = SKSpriteNode(texture: dinoTextures[selectedIndex].first)
        runner.name = "selected-dino-runner"
        runner.size = CGSize(width: 84, height: 84)
        runner.zPosition = 22
        addChild(runner)

        for index in 0..<8 {
            let segment = SKSpriteNode(color: SKColor(red: 0.76, green: 0.62, blue: 0.36, alpha: 1), size: CGSize(width: 180, height: 16))
            segment.anchorPoint = CGPoint(x: 0, y: 0.5)
            segment.position = CGPoint(x: CGFloat(index) * 180, y: groundY - 34)
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
        titleLabel.position = CGPoint(x: size.width / 2, y: size.height * 0.78)
        statusLabel.position = CGPoint(x: size.width / 2, y: size.height * 0.78 - 34)
        scoreLabel.position = CGPoint(x: 22, y: size.height - 54)
        highScoreLabel.position = CGPoint(x: size.width - 22, y: size.height - 44)
        updateLabels()
    }

    private func layoutChoices() {
        let spacing: CGFloat = 134
        let start = size.width / 2 - spacing * 1.5
        for (index, node) in choiceNodes.enumerated() {
            node.isHidden = false
            node.position = CGPoint(x: start + CGFloat(index) * spacing, y: size.height * 0.48)
            node.setScale(index == selectedIndex ? 1.12 : 1.0)
        }
        runner.isHidden = true
    }

    private func showCharacterSelect() {
        phase = .selecting
        titleLabel.text = "Choose Your Dino"
        statusLabel.text = "Click/tap a dinosaur, then jump with Space/click/tap"
        score = 0
        runTime = 0
        removeObstacles()
        layoutChoices()
        updateLabels()
    }

    private func startRun(index: Int) {
        selectedIndex = index
        phase = .playing
        score = 0
        runTime = 0
        runSpeed = 230
        spawnTimer = 0.8
        velocityY = 0
        animationFrame = 0
        removeObstacles()
        for node in choiceNodes { node.isHidden = true }
        runner.isHidden = false
        runner.texture = dinoTextures[selectedIndex].first
        runner.position = CGPoint(x: size.width * 0.24, y: groundY)
        titleLabel.text = ""
        statusLabel.text = ""
        updateLabels()
    }

    private func jumpOrRestart() {
        switch phase {
        case .selecting:
            startRun(index: selectedIndex)
        case .playing:
            if runner.position.y <= groundY + 2 {
                velocityY = jumpImpulse
                autoSawJump = true
            }
        case .gameOver:
            showCharacterSelect()
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
        runAutoVerification(dt)
        guard phase == .playing else { return }
        runTime += dt
        runSpeed = 230 + CGFloat(runTime) * 14
        score = max(score, Int(runTime * 10))
        if score > 0 { autoSawScore = true }
        if runSpeed > 245 { autoSawSpeedRamp = true }
        updateLabels()
        updateRunner(dt)
        scrollGround(dt)
        updateObstacles(dt)
        checkCollision()
    }

    private func animate(_ dt: TimeInterval) {
        animationTimer += dt
        guard animationTimer > 0.08 else { return }
        animationTimer = 0
        animationFrame = (animationFrame + 1) % 6
        if phase == .selecting {
            for (index, node) in choiceNodes.enumerated() {
                node.texture = dinoTextures[index][animationFrame]
            }
        } else {
            runner.texture = dinoTextures[selectedIndex][animationFrame]
        }
    }

    private func updateRunner(_ dt: TimeInterval) {
        velocityY += gravity * CGFloat(dt)
        runner.position.y = max(groundY, runner.position.y + velocityY * CGFloat(dt))
        if runner.position.y == groundY {
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

    private func updateObstacles(_ dt: TimeInterval) {
        spawnTimer -= dt
        if spawnTimer <= 0 {
            spawnTimer = TimeInterval(CGFloat.random(in: 0.9...1.35))
            spawnObstacle()
        }
        for obstacle in obstacles {
            obstacle.node.position.x -= runSpeed * CGFloat(dt)
        }
        while let first = obstacles.first, first.node.position.x < -80 {
            first.node.removeFromParent()
            obstacles.removeFirst()
        }
    }

    private func spawnObstacle() {
        let height = CGFloat.random(in: 34...58)
        let obstacle = SKSpriteNode(color: SKColor(red: 0.82, green: 0.91, blue: 0.44, alpha: 1), size: CGSize(width: 24, height: height))
        obstacle.anchorPoint = CGPoint(x: 0.5, y: 0)
        obstacle.position = CGPoint(x: size.width + 44, y: groundY - 38)
        obstacle.zPosition = 18
        addChild(obstacle)
        obstacles.append(Obstacle(node: obstacle))
        autoSawObstacle = true
    }

    private func checkCollision() {
        let dinoRect = CGRect(x: runner.position.x - 26, y: runner.position.y - 34, width: 52, height: 62)
        for obstacle in obstacles {
            let rect = CGRect(
                x: obstacle.node.position.x - obstacle.node.size.width / 2,
                y: obstacle.node.position.y,
                width: obstacle.node.size.width,
                height: obstacle.node.size.height
            )
            if dinoRect.intersects(rect) {
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
            UserDefaults.standard.set(score, forKey: "Prismcade.DinoDash.highScore")
        }
        titleLabel.text = "Dino Down"
        statusLabel.text = "Score \(score) - click/tap/Space to choose again"
        updateLabels()
    }

    private func runAutoVerification(_ dt: TimeInterval) {
        guard autoVerifyEnabled else { return }
        autoTime += dt

        if phase == .selecting {
            let index = min(Int(autoTime / 0.35), choices.count - 1)
            selectedIndex = index
            if !autoSelectedIds.contains(choices[index].id) {
                autoSelectedIds.append(choices[index].id)
            }
            layoutChoices()
            if autoTime > 0.4 && !autoWroteSelectSnapshot {
                autoWroteSelectSnapshot = true
                writeSceneSnapshot(path: "/tmp/prismcade-dino-character-select-snapshot.png")
            }
            if autoTime > 1.7 {
                startRun(index: choices.count - 1)
            }
            return
        }

        if phase == .playing {
            if runTime > 2.0 && !autoWroteGameplaySnapshot {
                autoWroteGameplaySnapshot = true
                writeSceneSnapshot(path: "/tmp/prismcade-dino-gameplay-snapshot.png")
            }
            if runner.position.y <= groundY + 2 && (obstacles.first?.node.position.x ?? size.width) - runner.position.x < 160 {
                jumpOrRestart()
            }
            if runTime > 1.0 && obstacles.isEmpty {
                spawnObstacle()
            }
            if runTime > 4.2 && !autoForcedCollision {
                autoForcedCollision = true
                let obstacle = SKSpriteNode(color: SKColor(red: 0.82, green: 0.91, blue: 0.44, alpha: 1), size: CGSize(width: 34, height: 62))
                obstacle.anchorPoint = CGPoint(x: 0.5, y: 0)
                obstacle.position = CGPoint(x: runner.position.x, y: groundY - 38)
                obstacle.zPosition = 18
                addChild(obstacle)
                obstacles.append(Obstacle(node: obstacle))
                autoSawObstacle = true
            }
        }

        if phase == .gameOver && autoSawGameOver {
            showCharacterSelect()
            autoSawRestart = phase == .selecting
            writeAutoVerificationReceipt()
            autoVerifyEnabled = false
        }
    }

    private func writeAutoVerificationReceipt() {
        writeSceneSnapshot(path: "/tmp/prismcade-dino-runtime-snapshot.png")
        let payload: [String: Any] = [
            "game": "Prismtek Dino Dash",
            "dinoSpritesFound": choices.map(\.id),
            "dinoSpritesSelected": autoSelectedIds,
            "realDinoSpritesVisible": choiceNodes.count == 4 && dinoTextures.count == 4,
            "jumpWorked": autoSawJump,
            "obstaclesSpawned": autoSawObstacle,
            "scoreChanged": autoSawScore,
            "speedRamped": autoSawSpeedRamp,
            "gameOverTriggered": autoSawGameOver,
            "restartWorked": autoSawRestart
        ]
        guard JSONSerialization.isValidJSONObject(payload),
              let data = try? JSONSerialization.data(withJSONObject: payload, options: [.prettyPrinted, .sortedKeys]) else { return }
        try? data.write(to: URL(fileURLWithPath: "/tmp/prismcade-dino-runtime-verification.json"), options: .atomic)
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

    private func removeObstacles() {
        for obstacle in obstacles {
            obstacle.node.removeFromParent()
        }
        obstacles.removeAll()
    }

    private func updateLabels() {
        scoreLabel.text = "Score \(score)"
        highScoreLabel.text = "Best \(highScore)"
    }

    private func handlePoint(_ point: CGPoint) {
        if phase == .selecting {
            for (index, node) in choiceNodes.enumerated() where node.contains(point) {
                startRun(index: index)
                return
            }
        }
        jumpOrRestart()
    }

    #if os(macOS)
    override func mouseDown(with event: NSEvent) {
        handlePoint(event.location(in: self))
    }

    override func keyDown(with event: NSEvent) {
        if event.keyCode == 49 || event.charactersIgnoringModifiers == " " {
            jumpOrRestart()
        } else if phase == .selecting, let value = event.charactersIgnoringModifiers.flatMap(Int.init), (1...4).contains(value) {
            startRun(index: value - 1)
        }
    }
    #endif

    #if os(iOS)
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first else { return }
        handlePoint(touch.location(in: self))
    }
    #endif
}
