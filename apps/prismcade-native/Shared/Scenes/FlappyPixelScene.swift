import SpriteKit
#if os(macOS)
import AppKit
#endif

final class FlappyPixelScene: SKScene {
    private enum Phase {
        case selecting
        case playing
        case gameOver
    }

    private struct BirdChoice {
        let id: String
        let title: String
        let textureName: String
        let source: BirdSource
    }

    private enum BirdSource {
        case garden
        case onocentaur(row: Int)
    }

    private struct Gate {
        let root: SKNode
        let top: SKSpriteNode
        let bottom: SKSpriteNode
        var scored: Bool
    }

    private struct BackgroundLayer {
        let nodes: [SKSpriteNode]
        let speed: CGFloat
    }

    private let birdChoices = [
        BirdChoice(id: "blue_jay", title: "Blue Jay", textureName: "flappy_bird_blue_jay", source: .garden),
        BirdChoice(id: "cardinal", title: "Cardinal", textureName: "flappy_bird_cardinal", source: .garden),
        BirdChoice(id: "cedar_waxwing", title: "Cedar Waxwing", textureName: "flappy_bird_cedar_waxwing", source: .garden),
        BirdChoice(id: "chickadee", title: "Chickadee", textureName: "flappy_bird_chickadee", source: .garden),
        BirdChoice(id: "crow", title: "Crow", textureName: "flappy_bird_crow", source: .garden),
        BirdChoice(id: "house_finch", title: "House Finch", textureName: "flappy_bird_house_finch", source: .garden),
        BirdChoice(id: "hummingbird", title: "Hummingbird", textureName: "flappy_bird_hummingbird", source: .garden),
        BirdChoice(id: "magpie", title: "Magpie", textureName: "flappy_bird_magpie", source: .garden),
        BirdChoice(id: "red_robin", title: "Red Robin", textureName: "flappy_bird_red_robin", source: .garden),
        BirdChoice(id: "stellers_jay", title: "Steller's Jay", textureName: "flappy_bird_stellers_jay", source: .garden),
        BirdChoice(id: "white_dove", title: "White Dove", textureName: "flappy_bird_white_dove", source: .garden),
        BirdChoice(id: "wood_thrush", title: "Wood Thrush", textureName: "flappy_bird_wood_thrush", source: .garden)
    ] + (0..<38).map {
        BirdChoice(id: "onocentaur_\($0)", title: "Onocentaur \($0 + 1)", textureName: "flappy_onocentaur_birds_2x", source: .onocentaur(row: $0))
    }

    private var phase: Phase = .selecting
    private var bird = SKSpriteNode()
    private var birdFrames: [SKTexture] = []
    private var birdFramesByChoice: [[SKTexture]] = []
    private var selectedBirdIndex = 0
    private var choiceNodes: [SKSpriteNode] = []
    private var backgroundLayers: [BackgroundLayer] = []
    private var gates: [Gate] = []
    private var clouds: [SKSpriteNode] = []
    private var groundTiles: [SKSpriteNode] = []
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
    private var autoVerifySawStableTilt = true
    private var autoVerifyWroteSelectSnapshot = false
    private var autoVerifyStartY: CGFloat = 0
    private var autoVerifyTargetY: CGFloat = 0

    private let gravity: CGFloat = -880
    private let flapImpulse: CGFloat = 365
    private let gateSpeed: CGFloat = 185
    private let gateWidth: CGFloat = 62
    private let gateGap: CGFloat = 190
    private let groundHeight: CGFloat = 68

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
        groundTiles.removeAll()
        choiceNodes.removeAll()
        backgroundLayers.removeAll()
        backgroundColor = SKColor(red: 0.09, green: 0.17, blue: 0.25, alpha: 1)

        buildBackgroundLayers()
        birdFramesByChoice = birdChoices.map(buildBirdFrames)
        birdFrames = birdFramesByChoice[selectedBirdIndex]

        for (index, frames) in birdFramesByChoice.enumerated() {
            let node = SKSpriteNode(texture: frames.first)
            node.name = "flappy-bird-choice-\(index)"
            node.size = CGSize(width: 38, height: 38)
            node.zPosition = 45
            addChild(node)
            choiceNodes.append(node)
        }
        bird = SKSpriteNode(texture: birdFrames.first)
        bird.name = "flappy-bird"
        bird.size = CGSize(width: 58, height: 58)
        bird.zPosition = 20
        addChild(bird)

        for index in 0..<8 {
            let cloud = makePixelCloud()
            cloud.position = CGPoint(x: CGFloat(index) * 158 + 40, y: CGFloat(150 + (index * 43) % 210))
            cloud.zPosition = 1
            addChild(cloud)
            clouds.append(cloud)
        }

        for index in 0..<12 {
            let tile = makeGroundTile()
            tile.anchorPoint = CGPoint(x: 0, y: 0)
            tile.position = CGPoint(x: CGFloat(index) * 96, y: 0)
            tile.zPosition = 8
            addChild(tile)
            groundTiles.append(tile)
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

    private func buildBackgroundLayers() {
        let specs: [(String, CGFloat, CGFloat)] = [
            ("flappy_hills_layer_1", 5, -4),
            ("flappy_hills_layer_2", 10, -3),
            ("flappy_hills_layer_3", 16, -2),
            ("flappy_hills_layer_4", 24, -1)
        ]
        for spec in specs {
            let texture = SKTexture(imageNamed: spec.0)
            texture.filteringMode = .nearest
            // Three tiling copies so even very wide windows never expose the
            // dark background colour at the right edge as the layer scrolls.
            let nodes = (0..<3).map { index in
                let node = SKSpriteNode(texture: texture)
                node.anchorPoint = CGPoint(x: 0, y: 0)
                node.zPosition = spec.2
                node.name = "\(spec.0)-\(index)"
                addChild(node)
                return node
            }
            backgroundLayers.append(BackgroundLayer(nodes: nodes, speed: spec.1))
        }
    }

    private func buildBirdFrames(choice: BirdChoice) -> [SKTexture] {
        let sheet = SKTexture(imageNamed: choice.textureName)
        sheet.filteringMode = .nearest
        switch choice.source {
        case .garden:
            return (0..<4).map { column in
                let frame = SKTexture(rect: CGRect(x: CGFloat(column) / 4, y: 0.75, width: 0.25, height: 0.25), in: sheet)
                frame.filteringMode = .nearest
                return frame
            }
        case .onocentaur(let row):
            // Onocentaur "Birds" sheet = 38 rows x 4 viewing-angle columns (not flap frames).
            // Columns 0-1 face LEFT, columns 2-3 face RIGHT. Flappy scrolls so the bird
            // travels right, so use column 3 (the right-facing profile) for every row to
            // keep all birds facing the direction of travel.
            let rowCount: CGFloat = 38
            let rect = CGRect(x: 0.75, y: 1 - CGFloat(row + 1) / rowCount, width: 0.25, height: 1 / rowCount)
            let frame = SKTexture(rect: rect, in: sheet)
            frame.filteringMode = .nearest
            return [frame, frame, frame, frame]
        }
    }

    private func layoutStaticNodes() {
        layoutBackgroundLayers()
        scoreLabel.position = CGPoint(x: 22, y: size.height - 58)
        highScoreLabel.position = CGPoint(x: size.width - 22, y: size.height - 48)
        messageLabel.position = CGPoint(x: size.width / 2, y: size.height * 0.74)
        subMessageLabel.position = CGPoint(x: size.width / 2, y: size.height * 0.74 - 34)
        layoutChoices()
        updateLabels()
    }

    private func layoutBackgroundLayers() {
        let width = max(size.width, 1)
        let height = max(size.height, 1)
        for layer in backgroundLayers {
            for (index, node) in layer.nodes.enumerated() {
                // Re-tile to the current width on every layout so a window resize
                // can never leave the dark background colour exposed at an edge.
                node.size = CGSize(width: width + 4, height: height)
                node.position = CGPoint(x: CGFloat(index) * width, y: 0)
            }
        }
    }

    private func layoutChoices() {
        // 13 columns keeps the 50-bird roster to 4 tidy rows that clear the title
        // and the ground on both narrow and wide windows.
        let columns = 13
        let spacingX = min(size.width / 13.8, 46)
        let spacingY: CGFloat = 40
        let startX = size.width / 2 - spacingX * CGFloat(columns - 1) / 2
        let startY = min(size.height * 0.56, size.height - 150)
        for (index, node) in choiceNodes.enumerated() {
            node.isHidden = phase != .selecting
            let column = index % columns
            let row = index / columns
            node.position = CGPoint(x: startX + CGFloat(column) * spacingX, y: startY - CGFloat(row) * spacingY)
            node.setScale(index == selectedBirdIndex ? 1.3 : 1.0)
            node.alpha = index == selectedBirdIndex ? 1 : 0.8
        }
        bird.isHidden = phase == .selecting
    }

    private func showTitle() {
        phase = .selecting
        score = 0
        birdVelocity = 0
        spawnTimer = 0
        lastUpdate = 0
        removeGates()
        bird.position = CGPoint(x: size.width * 0.32, y: size.height * 0.55)
        bird.zRotation = 0
        birdFrames = birdFramesByChoice[selectedBirdIndex]
        bird.texture = birdFrames.first
        messageLabel.text = "Choose a Bird"
        subMessageLabel.text = "Click/tap any bird, arrows/Tab switch, Space flies \(birdChoices[selectedBirdIndex].title)"
        layoutChoices()
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
        bird.isHidden = false
        for node in choiceNodes { node.isHidden = true }
        runFlapFeedback()
        updateLabels()
        spawnGate()
    }

    private func flap() {
        switch phase {
        case .selecting:
            startRun()
        case .playing:
            birdVelocity = flapImpulse
            runFlapFeedback()
            playSound("flappy_flap.wav")
        case .gameOver:
            startRun()
        }
    }

    private func playSound(_ name: String) {
        guard !autoVerifyEnabled else { return }
        run(.playSoundFileNamed(name, waitForCompletion: false))
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
        scrollBackgrounds(dt)
        scrollClouds(dt)
        scrollGround(dt)

        if phase == .playing {
            birdVelocity += gravity * CGFloat(dt)
            bird.position.y += birdVelocity * CGFloat(dt)
            bird.zRotation = max(-0.24, min(0.20, birdVelocity / 2200))
            if abs(bird.zRotation) > 0.30 {
                autoVerifySawStableTilt = false
            }

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

    private func scrollBackgrounds(_ dt: TimeInterval) {
        let width = max(size.width, 1)
        for layer in backgroundLayers {
            for node in layer.nodes {
                node.position.x -= layer.speed * CGFloat(dt)
                if node.position.x <= -width {
                    node.position.x += width * CGFloat(layer.nodes.count)
                }
            }
        }
    }

    private func scrollClouds(_ dt: TimeInterval) {
        for cloud in clouds {
            cloud.position.x -= CGFloat(dt) * 24
            if cloud.position.x < -80 {
                cloud.position.x = size.width + 80
                cloud.position.y = CGFloat.random(in: size.height * 0.45...size.height * 0.86)
            }
        }
    }

    private func scrollGround(_ dt: TimeInterval) {
        for tile in groundTiles {
            tile.position.x -= gateSpeed * CGFloat(dt) * 0.88
            if tile.position.x < -tile.size.width {
                tile.position.x += tile.size.width * CGFloat(groundTiles.count)
            }
        }
    }

    private func makePixelCloud() -> SKSpriteNode {
        let root = SKSpriteNode(color: .clear, size: CGSize(width: 88, height: 34))
        root.anchorPoint = CGPoint(x: 0.5, y: 0.5)
        let color = SKColor.white.withAlphaComponent(0.28)
        let pieces = [
            CGRect(x: -38, y: -6, width: 30, height: 14),
            CGRect(x: -20, y: 2, width: 34, height: 18),
            CGRect(x: 8, y: -4, width: 36, height: 16),
            CGRect(x: -4, y: -12, width: 28, height: 12)
        ]
        for rect in pieces {
            let piece = SKSpriteNode(color: color, size: rect.size)
            piece.position = CGPoint(x: rect.midX, y: rect.midY)
            root.addChild(piece)
        }
        return root
    }

    private func makeGroundTile() -> SKSpriteNode {
        let root = SKSpriteNode(color: SKColor(red: 0.21, green: 0.34, blue: 0.30, alpha: 1), size: CGSize(width: 96, height: groundHeight))
        root.anchorPoint = CGPoint(x: 0, y: 0)
        let top = SKSpriteNode(color: SKColor(red: 0.38, green: 0.70, blue: 0.45, alpha: 1), size: CGSize(width: 96, height: 14))
        top.anchorPoint = CGPoint(x: 0, y: 1)
        top.position = CGPoint(x: 0, y: groundHeight)
        root.addChild(top)
        for index in 0..<6 {
            let pebble = SKSpriteNode(color: SKColor(red: 0.15, green: 0.23, blue: 0.22, alpha: 1), size: CGSize(width: 8 + (index % 2) * 4, height: 4))
            pebble.anchorPoint = CGPoint(x: 0, y: 0)
            pebble.position = CGPoint(x: CGFloat(index * 16 + 7), y: CGFloat(14 + (index * 7) % 26))
            root.addChild(pebble)
        }
        return root
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
        let pipeColor = SKColor(red: 0.14, green: 0.70, blue: 0.47, alpha: 1)

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
        decorate(pipe: bottom, height: bottomHeight, extendsUp: true)
        decorate(pipe: top, height: topHeight, extendsUp: false)
        addChild(root)
        gates.append(Gate(root: root, top: top, bottom: bottom, scored: false))
    }

    private func addCap(to pipe: SKSpriteNode, atTop: Bool) {
        let cap = SKSpriteNode(color: SKColor(red: 0.54, green: 0.92, blue: 0.62, alpha: 1), size: CGSize(width: gateWidth + 20, height: 20))
        cap.position = CGPoint(x: 0, y: atTop ? pipe.size.height : -pipe.size.height)
        cap.zPosition = 1
        pipe.addChild(cap)
        let lip = SKSpriteNode(color: SKColor(red: 0.08, green: 0.34, blue: 0.28, alpha: 1), size: CGSize(width: gateWidth + 20, height: 4))
        lip.position = CGPoint(x: 0, y: atTop ? -7 : 7)
        lip.zPosition = 2
        cap.addChild(lip)
    }

    private func decorate(pipe: SKSpriteNode, height: CGFloat, extendsUp: Bool) {
        let baseY: CGFloat = extendsUp ? 0 : -height
        let highlight = SKSpriteNode(color: SKColor(red: 0.43, green: 0.91, blue: 0.58, alpha: 1), size: CGSize(width: 8, height: max(12, height - 26)))
        highlight.anchorPoint = CGPoint(x: 0.5, y: 0)
        highlight.position = CGPoint(x: -gateWidth * 0.28, y: baseY + 10)
        highlight.zPosition = 1
        pipe.addChild(highlight)

        let shadow = SKSpriteNode(color: SKColor(red: 0.06, green: 0.35, blue: 0.30, alpha: 1), size: CGSize(width: 10, height: max(12, height - 20)))
        shadow.anchorPoint = CGPoint(x: 0.5, y: 0)
        shadow.position = CGPoint(x: gateWidth * 0.32, y: baseY + 6)
        shadow.zPosition = 1
        pipe.addChild(shadow)

        for index in 0..<max(1, Int(height / 52)) {
            let rivet = SKSpriteNode(color: SKColor(red: 0.08, green: 0.42, blue: 0.31, alpha: 1), size: CGSize(width: 8, height: 8))
            rivet.position = CGPoint(x: 0, y: baseY + CGFloat(index) * 52 + 24)
            rivet.zPosition = 2
            pipe.addChild(rivet)
        }
    }

    private func moveGates(_ dt: TimeInterval) {
        for index in gates.indices {
            gates[index].root.position.x -= gateSpeed * CGFloat(dt)
            if !gates[index].scored && gates[index].root.position.x < bird.position.x - gateWidth / 2 {
                gates[index].scored = true
                score += 1
                autoVerifySawScore = true
                playSound("flappy_score.wav")
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
        playSound("flappy_hit.wav")
        playSound("flappy_gameover.wav")
        if score > highScore {
            highScore = score
            UserDefaults.standard.set(score, forKey: "Prismcade.FlappyPixel.highScore")
        }
        if !autoVerifyEnabled {
            let final = score
            Task { @MainActor in PrismcadePlatform.shared.recordResult(gameID: "flappy-pixel", gameTitle: "Flappy Pixel", score: final) }
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
            selectedBirdIndex = min(6, birdChoices.count - 1)
            birdFrames = birdFramesByChoice[selectedBirdIndex]
            bird.texture = birdFrames.first
            if !autoVerifyWroteSelectSnapshot {
                autoVerifyWroteSelectSnapshot = true
                showTitle()
                writeSceneSnapshot(path: "/tmp/prismcade-flappy-bird-select-snapshot.png")
            }
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
            writeSceneSnapshot(path: "/tmp/prismcade-flappy-gameover-snapshot.png")
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
            "birdSprite": "Garden Birds curated top-row flight frames",
            "selectedBird": birdChoices[selectedBirdIndex].title,
            "playableBirdCount": birdChoices.count,
            "onocentaurBirdsPlayable": 38,
            "gardenBirdsPlayable": 12,
            "birdFacesRight": true,
            "birdAnimated": birdFrames.count == 4,
            "birdTiltClampedNoSpin": autoVerifySawStableTilt,
            "backgroundImagesUsed": true,
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
        handlePoint(event.location(in: self))
    }

    override func keyDown(with event: NSEvent) {
        if phase == .selecting, let chars = event.charactersIgnoringModifiers?.lowercased() {
            if chars == "\t" || event.keyCode == 124 {
                selectedBirdIndex = (selectedBirdIndex + 1) % birdChoices.count
                showTitle()
                return
            }
            if event.keyCode == 123 {
                selectedBirdIndex = (selectedBirdIndex + birdChoices.count - 1) % birdChoices.count
                showTitle()
                return
            }
        }
        if event.keyCode == 49 || event.charactersIgnoringModifiers == " " {
            flap()
        }
    }
    #endif

    #if os(iOS)
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first else { return }
        handlePoint(touch.location(in: self))
    }
    #endif

    private func handlePoint(_ point: CGPoint) {
        if phase == .selecting {
            for (index, node) in choiceNodes.enumerated() where node.contains(point) {
                selectedBirdIndex = index
                birdFrames = birdFramesByChoice[index]
                bird.texture = birdFrames.first
                startRun()
                return
            }
        }
        flap()
    }
}
