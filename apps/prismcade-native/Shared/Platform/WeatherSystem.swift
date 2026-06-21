import SpriteKit

/// Shared score-driven weather/season model for Prismcade runner games.
///
/// Weather is gameplay, not decoration: each state carries physics modifiers, a survival score
/// bonus, a seasonal screen tint, and the CraftPix weather sprite used for its particles.
/// Thresholds (documented in docs/prismcade/weather-system.md):
///   0-9 clear/spring · 10-19 wind · 20-29 rain · 30-39 storm · 40-49 autumn · 50+ winter/snow
enum WeatherState: Int, CaseIterable {
    case clear, wind, rain, storm, autumn, snow

    static func forScore(_ score: Int) -> WeatherState {
        switch score {
        case ..<10: return .clear
        case ..<20: return .wind
        case ..<30: return .rain
        case ..<40: return .storm
        case ..<50: return .autumn
        default: return .snow
        }
    }

    var title: String {
        switch self {
        case .clear: return "Clear · Spring"
        case .wind: return "Windy"
        case .rain: return "Rain"
        case .storm: return "Storm"
        case .autumn: return "Autumn"
        case .snow: return "Winter · Snow"
        }
    }

    var key: String {
        switch self {
        case .clear: return "clear"; case .wind: return "wind"; case .rain: return "rain"
        case .storm: return "storm"; case .autumn: return "autumn"; case .snow: return "snow"
        }
    }

    /// Full-screen seasonal tint overlay (opaque colour + separate alpha for cross-platform).
    var tintColor: SKColor {
        switch self {
        case .clear:  return SKColor(red: 0.30, green: 0.90, blue: 0.40, alpha: 1)
        case .wind:   return SKColor(red: 0.82, green: 0.85, blue: 0.70, alpha: 1)
        case .rain:   return SKColor(red: 0.25, green: 0.35, blue: 0.55, alpha: 1)
        case .storm:  return SKColor(red: 0.10, green: 0.12, blue: 0.26, alpha: 1)
        case .autumn: return SKColor(red: 0.85, green: 0.50, blue: 0.20, alpha: 1)
        case .snow:   return SKColor(red: 0.80, green: 0.88, blue: 1.00, alpha: 1)
        }
    }
    var tintAlpha: CGFloat {
        switch self { case .clear: return 0; case .wind: return 0.14; case .rain: return 0.32; case .storm: return 0.52; case .autumn: return 0.30; case .snow: return 0.34 }
    }

    // MARK: Flappy physics
    var gravityMultiplier: CGFloat {
        switch self { case .rain: return 1.12; case .storm: return 1.20; case .snow: return 0.90; default: return 1.0 }
    }
    var flapMultiplier: CGFloat {
        switch self { case .rain: return 0.94; case .storm: return 0.90; case .snow: return 0.88; default: return 1.0 }
    }
    /// Vertical gust amplitude (points/sec of sinusoidal push). 0 = none.
    var gustAmplitude: CGFloat {
        switch self { case .wind: return 70; case .storm: return 120; default: return 0 }
    }

    // MARK: Dino physics
    var runSpeedMultiplier: CGFloat {
        switch self { case .wind: return 1.06; case .storm: return 1.10; case .rain: return 0.96; case .snow: return 0.90; default: return 1.0 }
    }
    var jumpMultiplier: CGFloat {
        switch self { case .wind: return 1.05; case .storm: return 0.95; case .snow: return 0.92; default: return 1.0 }
    }

    /// Extra points awarded per scoring event for surviving harder weather.
    var survivalBonus: Int {
        switch self { case .clear: return 0; case .wind: return 1; case .rain: return 2; case .storm: return 3; case .autumn: return 2; case .snow: return 3 }
    }

    /// CraftPix weather sprite + frame count for particles (nil = no particles).
    var particle: (texture: String, frames: Int, falling: Bool)? {
        switch self {
        case .clear:  return nil
        case .wind:   return ("weather_wind_1", 16, false)
        case .rain:   return ("weather_rain_2", 8, true)
        case .storm:  return ("weather_rain_2", 8, true)
        case .autumn: return ("weather_wind_2", 16, false)
        case .snow:   return ("weather_snow_1", 8, true)
        }
    }
}

/// Reusable weather visuals (seasonal tint + animated CraftPix particles + a HUD label) that a
/// runner scene attaches once and drives from the player's score. Physics/scoring stay in the
/// scene; this owns only the look + the current `state`.
final class WeatherLayer {
    private weak var scene: SKScene?
    private let tint = SKSpriteNode(color: .clear, size: .zero)
    private let label = SKLabelNode(fontNamed: "Menlo-Bold")
    private var particles: [SKSpriteNode] = []
    private var time: TimeInterval = 0
    private(set) var state: WeatherState = .clear

    init(scene: SKScene, labelTopOffset: CGFloat = 84) {
        self.scene = scene
        tint.anchorPoint = CGPoint(x: 0, y: 0)
        tint.alpha = 0
        tint.zPosition = 14
        scene.addChild(tint)
        label.fontSize = 15
        label.fontColor = .white
        label.horizontalAlignmentMode = .center
        label.zPosition = 41
        label.alpha = 0
        label.text = "Weather: Clear · Spring"
        scene.addChild(label)
        self.labelTopOffset = labelTopOffset
    }

    private let labelTopOffset: CGFloat

    func layout(size: CGSize) {
        tint.size = size
        tint.position = .zero
        label.position = CGPoint(x: size.width / 2, y: size.height - labelTopOffset)
    }

    func reset(size: CGSize) {
        state = .clear
        tint.removeAllActions(); tint.alpha = 0
        clearParticles()
        label.removeAllActions()
        label.text = "Weather: Clear · Spring"
        label.alpha = 0.85
        layout(size: size)
    }

    /// Drive from score each frame. Returns true on the frame the weather changes.
    @discardableResult
    func update(score: Int, size: CGSize, dt: TimeInterval) -> Bool {
        time += dt
        animate(size: size, dt: dt)
        let next = WeatherState.forScore(score)
        guard next != state else { return false }
        state = next
        tint.color = next.tintColor
        tint.run(.fadeAlpha(to: next.tintAlpha, duration: 0.6))
        rebuild(size: size)
        // Persistent label (always shows the current weather) with a brief emphasis pulse on change.
        label.text = "Weather: \(next.title)"
        label.removeAllActions()
        label.run(.sequence([.scale(to: 1.25, duration: 0.15), .scale(to: 1.0, duration: 0.2)]))
        label.alpha = 0.9
        return true
    }

    private func clearParticles() { particles.forEach { $0.removeFromParent() }; particles.removeAll() }

    private func rebuild(size: CGSize) {
        guard let scene else { return }
        clearParticles()
        guard let spec = state.particle else { return }
        let sheet = SKTexture(imageNamed: spec.texture); sheet.filteringMode = .nearest
        let frames = (0..<spec.frames).map { i -> SKTexture in
            let f = SKTexture(rect: CGRect(x: CGFloat(i) / CGFloat(spec.frames), y: 0, width: 1 / CGFloat(spec.frames), height: 1), in: sheet)
            f.filteringMode = .nearest; return f
        }
        let count = spec.falling ? 22 : 5
        for i in 0..<count {
            let p = SKSpriteNode(texture: frames.first)
            p.zPosition = 13
            if spec.falling {
                p.size = CGSize(width: 84, height: 84)
                p.alpha = state == .snow ? 0.85 : 0.6
                p.position = CGPoint(x: CGFloat(i) / CGFloat(count) * size.width, y: CGFloat.random(in: 0...size.height))
            } else {
                p.size = CGSize(width: 240, height: 18)
                p.anchorPoint = CGPoint(x: 0, y: 0.5)
                p.alpha = 0.3
                p.position = CGPoint(x: CGFloat(i) * 230, y: size.height * (0.36 + 0.13 * CGFloat(i % 4)))
            }
            p.run(.repeatForever(.animate(with: frames, timePerFrame: 0.06)))
            scene.addChild(p)
            particles.append(p)
        }
    }

    private func animate(size: CGSize, dt: TimeInterval) {
        guard let spec = state.particle else { return }
        for (i, p) in particles.enumerated() {
            if spec.falling {
                p.position.y -= CGFloat(state == .snow ? 90 : 320) * CGFloat(dt)
                p.position.x -= CGFloat(state == .storm ? 120 : 40) * CGFloat(dt)
                if p.position.y < -40 || p.position.x < -64 {
                    p.position = CGPoint(x: CGFloat.random(in: 0...size.width), y: size.height + 32)
                }
            } else {
                p.position.x -= CGFloat(60 + i * 18) * CGFloat(dt)
                if p.position.x < -p.size.width { p.position.x = size.width + CGFloat(i * 40) }
            }
        }
    }
}
