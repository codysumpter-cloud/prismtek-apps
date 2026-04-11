import SwiftUI

enum BuddyMood {
    case idle
    case happy
    case thinking
    case working
    case sleepy
    case levelUp
    case needsAttention
}

struct BuddyAsciiView: View {
    let buddyName: String
    let mood: BuddyMood
    @State private var tick = 0

    var body: some View {
        Text(frame)
            .font(.system(size: 22, weight: .bold, design: .monospaced))
            .foregroundStyle(.mint)
            .padding(24)
            .frame(maxWidth: .infinity, minHeight: 260, alignment: .center)
            .background(
                LinearGradient(colors: [Color.black.opacity(0.88), Color.green.opacity(0.24)], startPoint: .topLeading, endPoint: .bottomTrailing)
            )
            .clipShape(RoundedRectangle(cornerRadius: 8))
            .task {
                while !Task.isCancelled {
                    try? await Task.sleep(nanoseconds: 520_000_000)
                    tick += 1
                }
            }
            .accessibilityLabel("\(buddyName) \(label)")
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

    private var framesForMood: [String] {
        switch mood {
        case .idle:
            return [
                Self.make(["    /\\", "  < o  o >", "  /|  v |\\", " /_|____|_\\", "   /_  _\\"]),
                Self.make(["    /\\", "  < o  o >", "  /|  v |\\", " /_|____|_\\", "   \\_  _/"])
            ]
        case .happy:
            return [
                Self.make(["  \\ /\\ /", "  < ^  ^ >", "  /|  * |\\", " /_|____|_\\", "    /  \\"]),
                Self.make([" *  /\\  *", "  < ^  o >", "  /|  * |\\", " /_|____|_\\", "    \\  /"])
            ]
        case .thinking:
            return [
                Self.make(["    /\\   ?", "  < o  o >", "  /|  ? |\\", " /_|____|_\\", "    /  \\"]),
                Self.make(["    /\\  ..", "  < o  O >", "  /|  ? |\\", " /_|____|_\\", "    \\  /"])
            ]
        case .working:
            return [
                Self.make(["    /\\  #", "  < >  < >", "  /| [ ]|\\", " /_|____|_\\", "   /_  _\\"]),
                Self.make(["    /\\  ##", "  < >  < >", "  /| [*]|\\", " /_|____|_\\", "   \\_  _/"])
            ]
        case .sleepy:
            return [
                Self.make(["    /\\   z", "  < -  - >", "  /|  . |\\", " /_|____|_\\", "    /__\\"]),
                Self.make(["    /\\  zz", "  < -  - >", "  /|  . |\\", " /_|____|_\\", "   _/  \\_"])
            ]
        case .levelUp:
            return [
                Self.make([" ** /\\ **", "  < ^  ^ >", "  /|{*}|\\", " /_|____|_\\", "    /  \\"]),
                Self.make(["*** /\\ ***", "  < ^  o >", "  /|{*}|\\", " /_|____|_\\", "    \\  /"])
            ]
        case .needsAttention:
            return [
                Self.make([" !  /\\  !", "  < o  o >", "  /|  ! |\\", " /_|____|_\\", "    /  \\"]),
                Self.make([" !! /\\ !!", "  < O  o >", "  /|  ! |\\", " /_|____|_\\", "    \\  /"])
            ]
        }
    }

    private static func make(_ lines: [String]) -> String {
        lines.joined(separator: "\n")
    }
}
