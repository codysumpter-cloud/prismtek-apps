import SwiftUI

/// A cozy-room visual theme. Original Prismtek SwiftUI colors only — no bitmaps,
/// no third-party art. Drives wall/floor/accent rendering and desk/decor labels
/// in `CozyRoomView`.
///
/// `Color` is not `Hashable`/`Equatable` in a stable way, so identity and
/// equality are defined purely on `id`.
struct BuddyRoomTheme: Identifiable, Hashable {
    let id: String
    let name: String
    let wallColor: Color
    let floorColor: Color
    let accentColor: Color
    let deskLabel: String
    let decorLabel: String

    static func == (lhs: BuddyRoomTheme, rhs: BuddyRoomTheme) -> Bool {
        lhs.id == rhs.id
    }

    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
}

extension BuddyRoomTheme {
    /// Original presets. Default is `cozyDesk` (closest to the original room look).
    static let presets: [BuddyRoomTheme] = [
        BuddyRoomTheme(
            id: "cozy-desk",
            name: "Cozy Desk",
            wallColor: Color(red: 0.36, green: 0.30, blue: 0.46),
            floorColor: Color(red: 0.50, green: 0.36, blue: 0.28),
            accentColor: Color(red: 0.30, green: 0.70, blue: 0.55),
            deskLabel: "Workstation",
            decorLabel: "Shelf"
        ),
        BuddyRoomTheme(
            id: "prismcade-room",
            name: "Prismcade Room",
            wallColor: Color(red: 0.22, green: 0.14, blue: 0.40),
            floorColor: Color(red: 0.16, green: 0.10, blue: 0.30),
            accentColor: Color(red: 0.20, green: 0.85, blue: 0.95),
            deskLabel: "Arcade Cab",
            decorLabel: "Neon Rack"
        ),
        BuddyRoomTheme(
            id: "night-build-cave",
            name: "Night Build Cave",
            wallColor: Color(red: 0.13, green: 0.15, blue: 0.19),
            floorColor: Color(red: 0.09, green: 0.10, blue: 0.13),
            accentColor: Color(red: 0.45, green: 0.85, blue: 0.65),
            deskLabel: "Build Desk",
            decorLabel: "Loot Shelf"
        )
    ]

    /// Default theme id (Cozy Desk).
    static let defaultID = "cozy-desk"

    /// Look up a theme by id, falling back to the default.
    static func theme(for id: String) -> BuddyRoomTheme {
        presets.first { $0.id == id } ?? presets[0]
    }
}
