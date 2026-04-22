import SwiftUI

enum BuddyAnimationMood {
    case idle
    case happy
    case thinking
    case working
    case sleepy
    case levelUp
    case needsAttention
}

struct BuddyAsciiView: View {
    var buddy: BuddyInstance?
    var template: CouncilStarterBuddyTemplate?
    var previewSpec: BuddyAppearancePreviewSpec?
    let mood: BuddyAnimationMood
    var compact = false
    @State private var tick = 0

    var body: some View {
        Text(frame)
            .font(.system(size: compact ? 12 : 19, weight: .bold, design: .monospaced))
            .foregroundColor(paletteAccent)
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(compact ? 12 : 18)
            .background(BMOTheme.backgroundSecondary)
            .clipShape(RoundedRectangle(cornerRadius: BMOTheme.radiusSmall, style: .continuous))
            .task {
                while !Task.isCancelled {
                    try? await Task.sleep(nanoseconds: 520_000_000)
                    tick += 1
                }
            }
            .accessibilityLabel("\(displayName) \(archetypeID) \(label)")
    }

    private var displayName: String {
        previewSpec?.buddyName ?? buddy?.displayName ?? template?.name ?? "Buddy"
    }

    private var label: String {
        switch mood {
        case .idle: return "idle"
        case .happy: return "happy"
        case .thinking: return "thinking"
        case .working: return "working"
        case .sleepy: return "sleepy"
        case .levelUp: return "level up"
        case .needsAttention: return "needs attention"
        }
    }

    private var frame: String {
        let frames = BuddyASCIIArtLibrary.frames(
            archetypeID: archetypeID,
            mood: mood,
            expressionTone: expressionTone,
            asciiVariantID: asciiVariantID
        )
        return frames[tick % frames.count]
    }

    private var paletteAccent: Color {
        BuddyPaletteDisplay.color(for: paletteID)
    }

    private var paletteID: String {
        previewSpec?.paletteID ?? buddy?.identity.palette ?? templatePaletteID
    }

    private var templatePaletteID: String {
        template.map { CouncilBuddyIdentityCatalog.identity(for: $0).palette } ?? "mint_cream"
    }

    private var asciiVariantID: String {
        previewSpec?.asciiVariantID ?? buddy?.visual?.asciiVariantId ?? "starter_a"
    }

    private var archetypeID: String {
        previewSpec?.archetypeID ?? buddy?.identity.archetype ?? template.map { CouncilBuddyIdentityCatalog.identity(for: $0).archetype } ?? "console_pet"
    }

    private var expressionTone: String {
        previewSpec?.expressionTone ?? buddyExpressionTone ?? "friendly"
    }

    private var buddyExpressionTone: String? {
        let state = previewSpec?.animationState ?? buddy?.visual?.currentAnimationState ?? buddy?.state.mood
        switch state?.lowercased() {
        case "thinking":
            return "curious"
        case "working":
            return "focused"
        default:
            return "friendly"
        }
    }
}

private enum BuddyASCIIArtLibrary {
    static func frames(
        archetypeID: String,
        mood: BuddyAnimationMood,
        expressionTone: String,
        asciiVariantID: String
    ) -> [String] {
        let template = templates[archetypeID] ?? templates["console_pet"]!
        let selected = mood == .idle ? template.idle : (template.moods[mood] ?? template.idle)
        let eyes = eyePair(for: mood, expressionTone: expressionTone)
        let mouth = mouth(for: mood, expressionTone: expressionTone)
        return selected.map { applyVariant(rendered: render($0, eyes: eyes, mouth: mouth), asciiVariantID: asciiVariantID) }
    }

    private static func render(_ frame: String, eyes: (String, String), mouth: String) -> String {
        frame
            .replacingOccurrences(of: "{L}", with: eyes.0)
            .replacingOccurrences(of: "{R}", with: eyes.1)
            .replacingOccurrences(of: "{M}", with: mouth)
    }

    private static func art(_ lines: [String]) -> String {
        lines.joined(separator: "\n")
    }

    private static func applyVariant(rendered: String, asciiVariantID: String) -> String {
        switch asciiVariantID {
        case "starter_b":
            return rendered
                .replacingOccurrences(of: "{", with: "(")
                .replacingOccurrences(of: "}", with: ")")
        case "starter_c":
            return rendered
                .replacingOccurrences(of: "/", with: "!")
                .replacingOccurrences(of: "\\", with: "!")
        default:
            return rendered
        }
    }

    private static func eyePair(for mood: BuddyAnimationMood, expressionTone: String) -> (String, String) {
        switch mood {
        case .sleepy:
            return ("-", "-")
        case .thinking:
            return ("o", "O")
        case .working:
            return ("^", "^")
        case .needsAttention:
            return ("O", "o")
        case .levelUp:
            return ("*", "*")
        case .happy:
            return expressionTone == "focused" ? ("^", "^") : ("^", "o")
        case .idle:
            switch expressionTone {
            case "curious": return ("o", "O")
            case "focused": return ("^", "^")
            default: return ("o", "o")
            }
        }
    }

    private static func mouth(for mood: BuddyAnimationMood, expressionTone: String) -> String {
        switch mood {
        case .thinking: return "?"
        case .working: return "="
        case .sleepy: return "_"
        case .levelUp: return "*"
        case .needsAttention: return "!"
        case .happy: return "u"
        case .idle:
            switch expressionTone {
            case "focused": return "="
            case "curious": return "?"
            default: return "u"
            }
        }
    }

    private struct Template {
        var idle: [String]
        var moods: [BuddyAnimationMood: [String]]
    }

    private static let templates: [String: Template] = [
        "console_pet": .init(
            idle: [
                """
                  __
                 /{L}{R}\\
                |  {M} |
                |_____| 
                 /   \\
                """,
                """
                  __
                 /{L}{R}\\
                |  {M} |
                |_____| 
                 \\   /
                """
            ],
            moods: [:]
        ),
        "dino": .init(
            idle: [
                """
                   __
                 _/{L}{R}\\_
                /|_{M}_/ >
                 /_   \\
                /_/\\_/ 
                """,
                """
                   __
                 _/{L}{R}\\_
                /|_{M}_/ >>
                 /_  /  
                /_/\\_\\ 
                """,
                """
                   __
                 _/{L}{R}\\_
                /|_{M}_/ >
                 /_  _\\
                /_/\\/  
                """
            ],
            moods: [
                .sleepy: [
                    art([
                        "   __ z",
                        " _/{L}{R}\\\\_",
                        "/|_{M}_/ >",
                        " /_   \\\\",
                        "/_/\\\\_/"
                    ])
                ]
            ]
        ),
        "pixel_pet": .init(
            idle: [
                """
                 .----.
                |{L}..{R}|
                |  {M} |
                |'----'|
                 /_==_\\
                """,
                """
                 .----.
                |{L}..{R}|
                |  {M} |
                |'----'|
                 \\_==_/
                """
            ],
            moods: [:]
        ),
        "cat_like": .init(
            idle: [
                """
                 /\\_/\\\\
                ({L} {R} )
                /  {M}  \\
                \\_v_v_/
                  / \\
                """,
                """
                 /\\_/\\\\
                ({L} {R} )
                /  {M}  \\
                \\_v_v_/
                  \\ /
                """
            ],
            moods: [:]
        ),
        "fox_like": .init(
            idle: [
                """
                 /\\_/\\\\
                / {L} {R}  \\
                (   {M}   )
                \\_vv__/>
                  /  ~\\
                """,
                """
                 /\\_/\\\\
                / {L} {R}  \\
                (   {M}   )
                \\_vv__>>
                  / ~~\\
                """
            ],
            moods: [:]
        ),
        "robot": .init(
            idle: [
                """
                  [#]
                 /{L}{R}\\
                |[{M}]|
                |[_ _]|
                 /| |\\
                """,
                """
                  [#]
                 /{L}{R}\\
                |[{M}]|
                |[_ _]|
                 \\| |/
                """
            ],
            moods: [:]
        ),
        "slime": .init(
            idle: [
                """
                 
                 .----.
                / {L}{R} {M} \\
                /______\\
                \\____/
                """,
                """
                 
                  .--.
                _/ {L}{R} {M}\\_
                /_______\\
                \\_____/
                """
            ],
            moods: [:]
        ),
        "plant_creature": .init(
            idle: [
                """
                  \\/
                 /{L}{R}\\
                (  {M} )
                 \\__/ 
                 _||_ 
                """,
                """
                  /\\
                 /{L}{R}\\
                (  {M} )
                 \\__/ 
                 _||_ 
                """
            ],
            moods: [:]
        ),
        "mini_wizard": .init(
            idle: [
                """
                  /\\*
                 /{L}{R}\\\\
                |  {M} |
                | /__\\|
                 / || 
                """,
                """
                  /\\*
                 /{L}{R}\\\\
                |  {M} |
                | /__\\|
                 /_|| 
                """
            ],
            moods: [:]
        ),
        "spirit": .init(
            idle: [
                """
                  .--.
                 ({L}{R}{M})
                  /~~\\
                 /_~~_\\
                  ~  ~
                """,
                """
                   .--.
                 ({L}{R}{M})
                  \\~~/
                 /_~~_\\
                  ~~ ~
                """
            ],
            moods: [:]
        ),
        "companion_orb": .init(
            idle: [
                """
                  .--.
                -( {L}{R} )-
                  '--'
                  /{M}\\
                   /\\
                """,
                """
                  .--.
                ~ ( {L}{R} ) ~
                  '--'
                  /{M}\\
                   \\/
                """
            ],
            moods: [:]
        ),
        "tiny_monster": .init(
            idle: [
                """
                  /^^\\
                 ({L}{R}{M})
                 /|__|\\
                  /  \\
                 ^    ^
                """,
                """
                  /^^\\
                 ({L}{R}{M})
                 /|__|\\
                  \\  /
                 ^    ^
                """
            ],
            moods: [:]
        )
    ]
}

enum BuddyAsciiRenderer {
    static func frames(archetypeID: String, mood: BuddyAnimationMood, expressionTone: String, asciiVariantID: String) -> [String] {
        BuddyASCIIArtLibrary.frames(
            archetypeID: archetypeID,
            mood: mood,
            expressionTone: expressionTone,
            asciiVariantID: asciiVariantID
        )
    }
}

private enum BuddyPaletteDisplay {
    static func color(for paletteID: String) -> Color {
        switch paletteID {
        case "sky_navy": return Color(red: 0.49, green: 0.78, blue: 0.99)
        case "peach_brown": return Color(red: 1.0, green: 0.78, blue: 0.65)
        case "purple_gold": return Color(red: 0.78, green: 0.64, blue: 1.0)
        case "black_neon": return Color(red: 0.22, green: 1.0, blue: 0.53)
        case "rose_white": return Color(red: 0.95, green: 0.55, blue: 0.69)
        case "forest_moss": return Color(red: 0.55, green: 0.68, blue: 0.35)
        case "aqua_teal": return Color(red: 0.45, green: 0.95, blue: 0.91)
        case "red_charcoal": return Color(red: 0.82, green: 0.29, blue: 0.36)
        case "yellow_cocoa": return Color(red: 0.96, green: 0.83, blue: 0.37)
        default: return Color(red: 0.56, green: 0.85, blue: 0.78)
        }
    }
}
