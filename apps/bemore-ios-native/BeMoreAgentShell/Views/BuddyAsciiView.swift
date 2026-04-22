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
            .font(.system(size: compact ? 11 : 18, weight: .bold, design: .monospaced))
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
            .accessibilityLabel("\(displayName) \(archetypeID) \(subtypeID) \(label)")
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

    private var archetypeID: String {
        previewSpec?.archetypeID ?? buddy?.identity.archetype ?? template.map { CouncilBuddyIdentityCatalog.identity(for: $0).archetype } ?? "console_pet"
    }

    private var subtypeID: String {
        previewSpec?.customization.subtype ?? buddy?.visual?.appearance.subtype ?? BuddyAppearanceRenderContract.defaultCustomization(for: archetypeID).subtype
    }

    private var customization: BuddyAppearanceCustomization {
        BuddyAppearanceRenderContract.normalizedCustomization(
            previewSpec?.customization ?? buddy?.visual?.appearance ?? BuddyAppearanceRenderContract.defaultCustomization(for: archetypeID),
            archetypeID: archetypeID
        )
    }

    private var frame: String {
        let frames = BuddyASCIIArtLibrary.frames(
            archetypeID: archetypeID,
            mood: mood,
            expressionTone: expressionTone,
            asciiVariantID: asciiVariantID,
            customization: customization
        )
        return frames[tick % max(1, frames.count)]
    }

    private var paletteAccent: Color {
        BuddyPaletteDisplay.color(for: paletteID)
    }

    private var paletteID: String {
        previewSpec?.paletteID ?? buddy?.identity.palette ?? template.map { CouncilBuddyIdentityCatalog.identity(for: $0).palette } ?? "mint_cream"
    }

    private var asciiVariantID: String {
        previewSpec?.asciiVariantID ?? buddy?.visual?.asciiVariantId ?? "starter_a"
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
    private struct Template {
        var idle: [String]
        var moods: [BuddyAnimationMood: [String]]
    }

    static func frames(
        archetypeID: String,
        mood: BuddyAnimationMood,
        expressionTone: String,
        asciiVariantID: String,
        customization: BuddyAppearanceCustomization
    ) -> [String] {
        let normalized = BuddyAppearanceRenderContract.normalizedCustomization(customization, archetypeID: archetypeID)
        let key = templateKey(archetypeID: archetypeID, subtype: normalized.subtype)
        let template = templates[key] ?? templates[archetypeID] ?? templates["console_pet"]!
        let selected = mood == .idle ? template.idle : (template.moods[mood] ?? template.idle)
        let eyes = eyePair(for: mood, expressionTone: expressionTone, vibe: normalized.personalityVibe)
        let mouth = mouth(for: mood, expressionTone: expressionTone, vibe: normalized.personalityVibe)
        return selected.map {
            applyVariant(
                rendered: render($0, eyes: eyes, mouth: mouth, accent: accentGlyph(normalized.accentDetail)),
                asciiVariantID: asciiVariantID
            )
        }
    }

    private static func templateKey(archetypeID: String, subtype: String) -> String {
        let key = "\(archetypeID):\(subtype)"
        return templates[key] == nil ? archetypeID : key
    }

    private static func render(_ frame: String, eyes: (String, String), mouth: String, accent: String) -> String {
        frame
            .replacingOccurrences(of: "{L}", with: eyes.0)
            .replacingOccurrences(of: "{R}", with: eyes.1)
            .replacingOccurrences(of: "{M}", with: mouth)
            .replacingOccurrences(of: "{A}", with: accent)
    }

    private static func accentGlyph(_ accent: String) -> String {
        switch accent {
        case "heart_cheeks": return "v"
        case "plate_ridges": return "^"
        case "club_tail": return "o"
        case "soft_whiskers": return "~"
        case "tail_fluff": return "*"
        case "rune_sparks": return "+"
        default: return "~"
        }
    }

    private static func applyVariant(rendered: String, asciiVariantID: String) -> String {
        switch asciiVariantID {
        case "starter_b":
            return rendered.replacingOccurrences(of: "~", with: "*")
        case "starter_c":
            return rendered.replacingOccurrences(of: ".", with: "·")
        default:
            return rendered
        }
    }

    private static func art(_ lines: [String]) -> String {
        lines.joined(separator: "\n")
    }

    private static func eyePair(for mood: BuddyAnimationMood, expressionTone: String, vibe: String) -> (String, String) {
        switch mood {
        case .sleepy: return ("-", "-")
        case .thinking: return ("o", "O")
        case .working: return ("^", "^")
        case .needsAttention: return ("O", "o")
        case .levelUp: return ("*", "*")
        case .happy:
            return vibe == "fierce" ? (">", "<") : ("^", "^")
        case .idle:
            switch (expressionTone, vibe) {
            case ("focused", _): return ("^", "^")
            case ("curious", _): return ("o", "O")
            case (_, "sleepy"): return ("-", "o")
            case (_, "fierce"): return (">", "<")
            default: return ("o", "o")
            }
        }
    }

    private static func mouth(for mood: BuddyAnimationMood, expressionTone: String, vibe: String) -> String {
        switch mood {
        case .thinking: return "?"
        case .working: return "="
        case .sleepy: return "_"
        case .levelUp: return "w"
        case .needsAttention: return "!"
        case .happy: return vibe == "fierce" ? "n" : "u"
        case .idle:
            switch (expressionTone, vibe) {
            case ("focused", _): return "="
            case ("curious", _): return "?"
            case (_, "fierce"): return "n"
            default: return "u"
            }
        }
    }

    private static let templates: [String: Template] = [
        "console_pet": .init(
            idle: [
                art([
                    "  .----.",
                    " / {L}{R}  \\\\",
                    "|   {M}   |",
                    "| .----. |",
                    " \\\\_{A}__/"
                ]),
                art([
                    "  .----.",
                    " / {L}{R}  \\\\",
                    "|   {M}   |",
                    "| .----. |",
                    " /__{A}_\\\\"
                ])
            ],
            moods: [:]
        ),
        "dino:trex": .init(
            idle: [
                art([
                    "      __",
                    "  ___/{L}{R}\\\\__",
                    " /  _ {M}  _\\\\>",
                    "/__/\\\\_  _/ ",
                    "   /_/ \\\\_\\\\{A}"
                ]),
                art([
                    "      __",
                    "  ___/{L}{R}\\\\__",
                    " /  _ {M}  _\\\\>>",
                    "/__/\\\\_  / ",
                    "   /_/ \\\\_\\\\{A}"
                ]),
                art([
                    "      __",
                    "  ___/{L}{R}\\\\__",
                    " /  _ {M}  _\\\\>",
                    "/__/\\\\_ _/ ",
                    "   /_/  \\\\_\\\\{A}"
                ])
            ],
            moods: [:]
        ),
        "dino:raptor": .init(
            idle: [
                art([
                    "     __",
                    "  __/{L}{R}\\\\_",
                    " /  _ {M} _\\\\__",
                    "/__/\\\\  __/  \\\\",
                    "    /_/   \\\\_{A}"
                ]),
                art([
                    "     __",
                    "  __/{L}{R}\\\\_",
                    " /  _ {M} _\\\\__",
                    "/__/\\\\  _/  /",
                    "    /_/   \\\\_{A}"
                ]),
                art([
                    "     __",
                    "  __/{L}{R}\\\\_",
                    " /  _ {M} _\\\\__",
                    "/__/\\\\   _\\\u{20} /",
                    "    /_/   \\\\_{A}"
                ])
            ],
            moods: [:]
        ),
        "dino:triceratops": .init(
            idle: [
                art([
                    "    __^__",
                    " __/{L}{R}{M}\\\\_",
                    "/_  ____  _\\\\",
                    "  /_/  \\\\_\\\\>",
                    "  /_/  \\\\_\\\\{A}"
                ]),
                art([
                    "    __^__",
                    " __/{L}{R}{M}\\\\_",
                    "/_  ____  _\\\\",
                    "  /_/  \\\\_\\\\>>",
                    "  /_/  \\\\_\\\\{A}"
                ])
            ],
            moods: [:]
        ),
        "dino:stegosaurus": .init(
            idle: [
                art([
                    "   ^ ^ ^",
                    " __/{L}{R}\\\\___",
                    "/_  {M}  __\\\\>",
                    "  /_/\\\\_/  \\\\",
                    " /_/  \\\\_\\\\{A}"
                ]),
                art([
                    "   ^ ^ ^",
                    " __/{L}{R}\\\\___",
                    "/_  {M}  __\\\\>>",
                    "  /_/\\\\_/  \\\\",
                    " /_/  \\\\_\\\\{A}"
                ])
            ],
            moods: [:]
        ),
        "dino:longneck": .init(
            idle: [
                art([
                    "      __",
                    "  ___/ {L}{R}",
                    " /  _  {M}\\\\__",
                    "/__/ \\\\____  \\\\",
                    "   /_/    \\\\_\\\\{A}"
                ]),
                art([
                    "      __",
                    "  ___/ {L}{R}",
                    " /  _  {M}\\\\__",
                    "/__/ \\\\___   \\\\",
                    "   /_/   \\\\_\\\\{A}"
                ])
            ],
            moods: [:]
        ),
        "dino:ankylosaurus": .init(
            idle: [
                art([
                    "   __^^__",
                    " _/{L}{R}{M}__\\\\",
                    "/_  ____  _\\\\",
                    "  /_/  \\\\_\\\\o",
                    " /_/    \\\\_\\\\"
                ]),
                art([
                    "   __^^__",
                    " _/{L}{R}{M}__\\\\",
                    "/_  ____  _\\\\",
                    "  /_/  \\\\_\\\\O",
                    " /_/    \\\\_\\\\"
                ])
            ],
            moods: [:]
        ),
        "dino:pterodactyl": .init(
            idle: [
                art([
                    "  __/\\\\__/\\\\__",
                    " <_ {L}{R}{M}  _>",
                    "   /_/\\\\_\\\\",
                    "    /  \\\\{A}"
                ]),
                art([
                    " __/\\\\____/\\\\__",
                    "<_  {L}{R}{M}   _>",
                    "  /_/\\\\__\\\\",
                    "   /  \\\\{A}"
                ])
            ],
            moods: [:]
        ),
        "dino": .init(
            idle: [
                art([
                    "      __",
                    "  ___/{L}{R}\\\\__",
                    " /  _ {M}  _\\\\>",
                    "/__/\\\\_  _/ ",
                    "   /_/ \\\\_\\\\{A}"
                ])
            ],
            moods: [:]
        ),
        "pixel_pet": .init(
            idle: [
                art([
                    "  .-==-.",
                    " / {L}{R}  \\\\",
                    "|  {M}   |",
                    "| [__]  |",
                    " \\\\_{A}_/"
                ]),
                art([
                    "  .-==-.",
                    " / {L}{R}  \\\\",
                    "|  {M}   |",
                    "| [__]  |",
                    " /_{A}_\\\\"
                ])
            ],
            moods: [:]
        ),
        "cat_like": .init(
            idle: [
                art([
                    " /\\\\_/\\\\",
                    "({L} {R} )",
                    "/  {M}  \\\\",
                    "\\\\__^__/",
                    "  / {A}\\\\"
                ]),
                art([
                    " /\\\\_/\\\\",
                    "({L} {R} )",
                    "/  {M}  \\\\",
                    "\\\\__^__/",
                    "  \\\\ {A}/"
                ])
            ],
            moods: [:]
        ),
        "fox_like": .init(
            idle: [
                art([
                    " /\\\\_/\\\\",
                    "/ {L} {R}  \\\\",
                    "\\\\  {M}  _/",
                    " /_^^_\\\\",
                    "   \\\\{A}\\\\~~"
                ]),
                art([
                    " /\\\\_/\\\\",
                    "/ {L} {R}  \\\\",
                    "\\\\  {M}  _/",
                    " /_^^_\\\\",
                    "   \\\\~~\\\\{A}"
                ])
            ],
            moods: [:]
        ),
        "robot": .init(
            idle: [
                art([
                    "   .-+-.",
                    "  / {L}{R} \\\\",
                    " | [{M}] |",
                    " |[_{A}_]|",
                    "  /| |\\\\"
                ]),
                art([
                    "   .-+-.",
                    "  / {L}{R} \\\\",
                    " | [{M}] |",
                    " |[_{A}_]|",
                    "  \\\\| |/"
                ])
            ],
            moods: [:]
        ),
        "slime": .init(
            idle: [
                art([
                    "   ____",
                    " / {L}{R}  \\\\",
                    "|   {M}   |",
                    " \\\\__{A}__/",
                    "   /  \\\\"
                ]),
                art([
                    "   ____",
                    " / {L}{R}  \\\\",
                    "|   {M}   |",
                    " \\\\__{A}__/",
                    "   \\\\__/ "
                ])
            ],
            moods: [:]
        ),
        "plant_creature": .init(
            idle: [
                art([
                    "   _/\\\\_",
                    "  / {L}{R}\\\\",
                    " |  {M}  |",
                    " /_/{A}\\\\_\\\\",
                    "   /  \\\\"
                ]),
                art([
                    "   _/\\\\_",
                    "  / {L}{R}\\\\",
                    " |  {M}  |",
                    " /_/{A}\\\\_\\\\",
                    "   \\\\  /"
                ])
            ],
            moods: [:]
        ),
        "mini_wizard": .init(
            idle: [
                art([
                    "    /\\\\",
                    "   /{A}\\\\",
                    "  /_{L}{R}_\\\\",
                    "   | {M} |",
                    "   /_/_\\\\"
                ]),
                art([
                    "    /\\\\",
                    "   /{A}\\\\",
                    "  /_{L}{R}_\\\\",
                    "   | {M} |",
                    "   \\\\_\\\\/"
                ])
            ],
            moods: [:]
        ),
        "spirit": .init(
            idle: [
                art([
                    "   .--.",
                    "  ({L}{R}{M})",
                    "   \\\\{A}//",
                    "    \\\\//"
                ]),
                art([
                    "   .--.",
                    "  ({L}{R}{M})",
                    "   //{A}\\\\",
                    "    //\\\\"
                ])
            ],
            moods: [:]
        ),
        "companion_orb": .init(
            idle: [
                art([
                    "   .-.-.",
                    "  ({L}{R}{M})",
                    "   / {A} \\\\",
                    "   '-.-'"
                ]),
                art([
                    "   .-.-.",
                    "  ({L}{R}{M})",
                    "   \\\\ {A} /",
                    "   '-.-'"
                ])
            ],
            moods: [:]
        ),
        "tiny_monster": .init(
            idle: [
                art([
                    "   /\\\\_/\\\\",
                    "  ({L}{R}{M})",
                    " /_/^^\\\\_\\\\",
                    "   / {A}\\\\"
                ]),
                art([
                    "   /\\\\_/\\\\",
                    "  ({L}{R}{M})",
                    " /_/^^\\\\_\\\\",
                    "   \\\\ {A}/"
                ])
            ],
            moods: [:]
        )
    ]
}

enum BuddyAsciiRenderer {
    static func frames(
        archetypeID: String,
        mood: BuddyAnimationMood,
        expressionTone: String,
        asciiVariantID: String,
        customization: BuddyAppearanceCustomization? = nil
    ) -> [String] {
        BuddyASCIIArtLibrary.frames(
            archetypeID: archetypeID,
            mood: mood,
            expressionTone: expressionTone,
            asciiVariantID: asciiVariantID,
            customization: customization ?? BuddyAppearanceRenderContract.defaultCustomization(for: archetypeID)
        )
    }
}

enum BuddyPaletteDisplay {
    static func color(for paletteID: String) -> Color {
        switch paletteID {
        case "rose_white":
            return Color(hex: "#B8336A")
        case "sky_navy":
            return Color(hex: "#1D3557")
        case "aqua_teal":
            return Color(hex: "#008080")
        case "forest_moss":
            return Color(hex: "#2F6B3D")
        case "peach_brown":
            return Color(hex: "#B5654A")
        case "yellow_cocoa":
            return Color(hex: "#B08900")
        case "purple_gold":
            return Color(hex: "#8D6BFF")
        case "black_neon":
            return Color(hex: "#39FF88")
        case "red_charcoal":
            return Color(hex: "#D1495B")
        default:
            return Color(hex: "#2B7A78")
        }
    }
}
