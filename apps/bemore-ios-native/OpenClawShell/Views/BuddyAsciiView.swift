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
            .accessibilityLabel("\(buddy?.displayName ?? "Buddy") \(label)")
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
        let frames = framesForMood
        return frames[tick % frames.count]
    }

    private var paletteAccent: Color {
        BuddyPaletteDisplay.color(for: buddy?.identity.palette ?? templatePaletteID)
    }

    private var templatePaletteID: String {
        template.map { CouncilBuddyIdentityCatalog.identity(for: $0).palette } ?? "mint_cream"
    }

    private var asciiVariantID: String {
        buddy?.visual?.asciiVariantId ?? "starter_a"
    }

    private var framesForMood: [String] {
        if let template {
            let state = moodKey
            if state == "idle", template.ascii.idleFrames.isEmpty == false {
                return style(template.ascii.idleFrames)
            }
            if let expression = template.ascii.expressions[state] {
                return style([expression, template.ascii.baseSilhouette])
            }
            return style(activeTemplateFallbackFrames(for: template.ascii.baseSilhouette))
        }
        switch mood {
        case .idle:
            return style([
                Self.make(["    /\\", "  < o  o >", "  /|  v |\\", " /_|____|_\\", "   /_  _\\"]),
                Self.make(["    /\\", "  < o  o >", "  /|  v |\\", " /_|____|_\\", "   \\_  _/"])
            ])
        case .happy:
            return style([
                Self.make(["  \\ /\\ /", "  < ^  ^ >", "  /|  * |\\", " /_|____|_\\", "    /  \\"]),
                Self.make([" *  /\\  *", "  < ^  o >", "  /|  * |\\", " /_|____|_\\", "    \\  /"])
            ])
        case .thinking:
            return style([
                Self.make(["    /\\   ?", "  < o  o >", "  /|  ? |\\", " /_|____|_\\", "    /  \\"]),
                Self.make(["    /\\  ..", "  < o  O >", "  /|  ? |\\", " /_|____|_\\", "    \\  /"])
            ])
        case .working:
            return style([
                Self.make(["    /\\  #", "  < >  < >", "  /| [ ]|\\", " /_|____|_\\", "   /_  _\\"]),
                Self.make(["    /\\  ##", "  < >  < >", "  /| [*]|\\", " /_|____|_\\", "   \\_  _/"])
            ])
        case .sleepy:
            return style([
                Self.make(["    /\\   z", "  < -  - >", "  /|  . |\\", " /_|____|_\\", "    /__\\"]),
                Self.make(["    /\\  zz", "  < -  - >", "  /|  . |\\", " /_|____|_\\", "   _/  \\_"])
            ])
        case .levelUp:
            return style([
                Self.make([" ** /\\ **", "  < ^  ^ >", "  /|{*}|\\", " /_|____|_\\", "    /  \\"]),
                Self.make(["*** /\\ ***", "  < ^  o >", "  /|{*}|\\", " /_|____|_\\", "    \\  /"])
            ])
        case .needsAttention:
            return style([
                Self.make([" !  /\\  !", "  < o  o >", "  /|  ! |\\", " /_|____|_\\", "    /  \\"]),
                Self.make([" !! /\\ !!", "  < O  o >", "  /|  ! |\\", " /_|____|_\\", "    \\  /"])
            ])
        }
    }

    private func activeTemplateFallbackFrames(for silhouette: String) -> [String] {
        switch mood {
        case .idle:
            return [silhouette]
        case .happy:
            return [Self.wrap(silhouette, top: "\\   /", bottom: "  YES"), Self.wrap(silhouette, top: " \\ / ", bottom: "  <3 ")]
        case .thinking:
            return [Self.wrap(silhouette, top: "  ? ", bottom: "  ..."), Self.wrap(silhouette, top: " ?  ", bottom: "  hmm")]
        case .working:
            return [Self.wrap(silhouette, top: "  ##", bottom: "[work]"), Self.wrap(silhouette, top: " ###", bottom: "[build]")]
        case .sleepy:
            return [Self.wrap(silhouette, top: "   z", bottom: " rest"), Self.wrap(silhouette, top: "  zz", bottom: " slow")]
        case .levelUp:
            return [Self.wrap(silhouette, top: "** **", bottom: "LEVEL"), Self.wrap(silhouette, top: "*****", bottom: " UP! ")]
        case .needsAttention:
            return [Self.wrap(silhouette, top: " ! !", bottom: "check"), Self.wrap(silhouette, top: "!! !!", bottom: " care")]
        }
    }

    private var moodKey: String {
        switch mood {
        case .idle: return buddy?.visual?.currentAnimationState ?? buddy?.state.mood ?? "idle"
        case .happy: return "happy"
        case .thinking: return "thinking"
        case .working: return "working"
        case .sleepy: return "sleepy"
        case .levelUp: return "levelUp"
        case .needsAttention: return "needsAttention"
        }
    }

    private static func make(_ lines: [String]) -> String {
        lines.joined(separator: "\n")
    }

    private static func wrap(_ silhouette: String, top: String, bottom: String) -> String {
        "\(top)\n\(silhouette.trimmingCharacters(in: .newlines))\n\(bottom)"
    }

    private func style(_ frames: [String]) -> [String] {
        frames.map { frame in
            switch asciiVariantID {
            case "starter_b":
                return frame
                    .replacingOccurrences(of: "<", with: "(")
                    .replacingOccurrences(of: ">", with: ")")
                    .replacingOccurrences(of: "/\\", with: "/\\+")
            case "starter_c":
                return frame
                    .replacingOccurrences(of: "<", with: "[")
                    .replacingOccurrences(of: ">", with: "]")
                    .replacingOccurrences(of: "/\\", with: "/\\#")
            default:
                return frame
            }
        }
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
