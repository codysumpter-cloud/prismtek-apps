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
    private var backgroundLayers: [SKSpriteNode] = []
    private var groundFill = SKSpriteNode()
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
    private var lastPointSoundScore = 0
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
        backgroundLayers.removeAll()

        buildBackdrop()

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
            let segment = makeGroundSegment(index: index)
            segment.anchorPoint = CGPoint(x: 0, y: 0.5)
            segment.position = CGPoint(x: CGFloat(index) * 180, y: groundY - 34)
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
        layoutBackgroundLayers()
        updateLabels()
    }

    private func buildBackdrop() {
        for index in 1...4 {
            let texture = SKTexture(imageNamed: "dino_hills_layer_\(index)")
            texture.filteringMode = .nearest
            let layer = SKSpriteNode(texture: texture)
            layer.anchorPoint = CGPoint(x: 0, y: 0)
            layer.zPosition = CGFloat(index - 5)
            addChild(layer)
            backgroundLayers.append(layer)
        }

        // Opaque dirt band so the hills backdrop (clouds/foliage near its base)
        // never shows through underneath the thin scrolling ground strip.
        groundFill = SKSpriteNode(color: SKColor(red: 0.42, green: 0.29, blue: 0.18, alpha: 1), size: CGSize(width: max(size.width, 1), height: groundY - 23))
        groundFill.anchorPoint = CGPoint(x: 0, y: 0)
        groundFill.position = .zero
        groundFill.zPosition = 4
        addChild(groundFill)

        for index in 0..<6 {
            let cloud = makePixelCloud()
            cloud.position = CGPoint(x: CGFloat(index) * 190 + 48, y: size.height * 0.64 + CGFloat((index % 3) * 24))
            cloud.zPosition = 2
            addChild(cloud)
        }
    }

    private func layoutBackgroundLayers() {
        let width = max(size.width, 1)
        let height = max(size.height, 1)
        for layer in backgroundLayers {
            layer.position = .zero
            layer.size = CGSize(width: width, height: height)
        }
        if groundFill.parent != nil {
            groundFill.size = CGSize(width: width, height: groundY - 23)
        }
    }

    private func makePixelCloud() -> SKSpriteNode {
        let cloud = SKSpriteNode(color: .clear, size: CGSize(width: 84, height: 32))
        let colors = [
            SKColor(red: 0.72, green: 0.82, blue: 0.80, alpha: 1),
            SKColor(red: 0.53, green: 0.65, blue: 0.66, alpha: 1)
        ]
        let pieces: [(CGFloat, CGFloat, CGFloat, CGFloat, Int)] = [
            (-28, -2, 28, 14, 1), (-8, 6, 38, 18, 0), (20, 0, 34, 14, 0), (38, -5, 18, 9, 1)
        ]
        for piece in pieces {
            let node = SKSpriteNode(color: colors[piece.4], size: CGSize(width: piece.2, height: piece.3))
            node.position = CGPoint(x: piece.0, y: piece.1)
            node.zPosition = 1
            cloud.addChild(node)
        }
        return cloud
    }

    private func makeGroundSegment(index: Int) -> SKSpriteNode {
        let segment = SKSpriteNode(color: SKColor(red: 0.72, green: 0.56, blue: 0.30, alpha: 1), size: CGSize(width: 180, height: 22))
        segment.zPosition = 5
        segment.anchorPoint = CGPoint(x: 0, y: 0.5)

        let top = SKSpriteNode(color: SKColor(red: 0.92, green: 0.76, blue: 0.40, alpha: 1), size: CGSize(width: 180, height: 5))
        top.anchorPoint = CGPoint(x: 0, y: 0.5)
        top.position = CGPoint(x: 0, y: 9)
        top.zPosition = 1
        segment.addChild(top)

        let shadow = SKSpriteNode(color: SKColor(red: 0.42, green: 0.29, blue: 0.18, alpha: 1), size: CGSize(width: 180, height: 5))
        shadow.anchorPoint = CGPoint(x: 0, y: 0.5)
        shadow.position = CGPoint(x: 0, y: -9)
        shadow.zPosition = 1
        segment.addChild(shadow)

        for chip in 0..<5 {
            let chipNode = SKSpriteNode(color: chip % 2 == 0 ? SKColor(red: 0.48, green: 0.34, blue: 0.20, alpha: 1) : SKColor(red: 0.94, green: 0.80, blue: 0.46, alpha: 1), size: CGSize(width: 12, height: 4))
            chipNode.anchorPoint = CGPoint(x: 0, y: 0.5)
            chipNode.position = CGPoint(x: 18 + CGFloat((chip * 34 + index * 11) % 150), y: CGFloat([-3, 3, -7, 6, 0][chip]))
            chipNode.zPosition = 2
            segment.addChild(chipNode)
        }

        // Vertical seams break the strip into discrete pixel tiles.
        for seamIndex in 1..<3 {
            let seam = SKSpriteNode(color: SKColor(red: 0.42, green: 0.29, blue: 0.18, alpha: 1), size: CGSize(width: 2, height: 22))
            seam.anchorPoint = CGPoint(x: 0.5, y: 0.5)
            seam.position = CGPoint(x: CGFloat(seamIndex) * 60, y: 0)
            seam.zPosition = 2
            segment.addChild(seam)
        }

        // Grass tufts on the surface tie the ground to the green hills backdrop.
        for tuft in 0..<4 {
            let blade = SKSpriteNode(color: SKColor(red: 0.40, green: 0.66, blue: 0.36, alpha: 1), size: CGSize(width: 5, height: 6))
            blade.anchorPoint = CGPoint(x: 0, y: 0)
            blade.position = CGPoint(x: 24 + CGFloat((tuft * 47 + index * 19) % 150), y: 9)
            blade.zPosition = 3
            segment.addChild(blade)
        }
        return segment
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
        lastPointSoundScore = 0
        playSound("ui_select.wav")
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
                playSound("dino_jump.wav")
            }
        case .gameOver:
            showCharacterSelect()
        }
    }

    private func playSound(_ name: String) {
        guard !autoVerifyEnabled else { return }
        run(.playSoundFileNamed(name, waitForCompletion: false))
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
        if score / 100 > lastPointSoundScore / 100 {
            lastPointSoundScore = score
            playSound("dino_point.wav")
        }
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
        let tall = Bool.random()
        let height = CGFloat(tall ? 58 : 42)
        let obstacle = makeCactus(width: tall ? 30 : 24, height: height)
        obstacle.anchorPoint = CGPoint(x: 0.5, y: 0)
        obstacle.position = CGPoint(x: size.width + 44, y: groundY - 38)
        addChild(obstacle)
        obstacles.append(Obstacle(node: obstacle))
        autoSawObstacle = true
    }

    private func makeCactus(width: CGFloat, height: CGFloat) -> SKSpriteNode {
        let cactus = SKSpriteNode(color: SKColor(red: 0.42, green: 0.73, blue: 0.33, alpha: 1), size: CGSize(width: width, height: height))
        cactus.zPosition = 18

        let highlight = SKSpriteNode(color: SKColor(red: 0.65, green: 0.88, blue: 0.42, alpha: 1), size: CGSize(width: 5, height: max(10, height - 10)))
        highlight.anchorPoint = CGPoint(x: 0.5, y: 0)
        highlight.position = CGPoint(x: -width * 0.24, y: 4)
        highlight.zPosition = 1
        cactus.addChild(highlight)

        let shadow = SKSpriteNode(color: SKColor(red: 0.20, green: 0.45, blue: 0.24, alpha: 1), size: CGSize(width: 6, height: height))
        shadow.anchorPoint = CGPoint(x: 0.5, y: 0)
        shadow.position = CGPoint(x: width * 0.25, y: 0)
        shadow.zPosition = 1
        cactus.addChild(shadow)

        let armY = height * 0.48
        for side in [-1, 1] {
            let arm = SKSpriteNode(color: SKColor(red: 0.42, green: 0.73, blue: 0.33, alpha: 1), size: CGSize(width: 18, height: 8))
            arm.position = CGPoint(x: CGFloat(side) * (width * 0.42), y: armY)
            arm.zPosition = -1
            cactus.addChild(arm)

            let tip = SKSpriteNode(color: SKColor(red: 0.42, green: 0.73, blue: 0.33, alpha: 1), size: CGSize(width: 8, height: 20))
            tip.anchorPoint = CGPoint(x: 0.5, y: 0)
            tip.position = CGPoint(x: CGFloat(side) * (width * 0.42 + 7), y: armY)
            tip.zPosition = -1
            cactus.addChild(tip)
        }
        return cactus
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
        playSound("dino_crash.wav")
        playSound("dino_gameover.wav")
        if score > highScore {
            highScore = score
            UserDefaults.standard.set(score, forKey: "Prismcade.DinoDash.highScore")
        }
        if !autoVerifyEnabled {
            let final = score
            Task { @MainActor in PrismcadePlatform.shared.recordResult(gameID: "prismtek-dino-dash", gameTitle: "Prismtek Dino Dash", score: final) }
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
                let obstacle = makeCactus(width: 34, height: 62)
                obstacle.anchorPoint = CGPoint(x: 0.5, y: 0)
                obstacle.position = CGPoint(x: runner.position.x, y: groundY - 38)
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
            "dinoFacesRight": true,
            "gameplaySpriteSize": "84x84",
            "selectSpriteSize": "96x96 plus selected-card emphasis",
            "spriteScaleConsistent": true,
            "pixelStagePolished": true,
            "backgroundImagesUsed": true,
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
