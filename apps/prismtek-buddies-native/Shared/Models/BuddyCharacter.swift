import Foundation

/// How a selectable buddy is rendered in the room.
///
/// - `animatedAtlas`: a multi-frame buddy driven by `BitbudRenderer` + `BitbudFrames`
///   (e.g. Bitbud). Reacts to every `BuddyState` with a real animation row.
/// - `staticImage`: a single 64x64 PNG with no animation frames. The room renders the
///   one image and conveys emotes via the action LABEL plus a small bob/scale only
///   (there are no per-state frames to switch to). See `docs/prismtek-buddies/buddy-actions.md`.
enum BuddyRenderKind: String, Codable, Hashable {
    case animatedAtlas
    case staticImage
}

/// A selectable buddy character. Lives in `BuddyCharacter.registry`; the chosen id is
/// persisted via `@AppStorage("buddy.selected.id")`. The room renderer (`CozyRoomView`)
/// picks the renderer by `kind`.
///
/// Asset notes:
/// - `animatedAtlas` buddies ignore `assetName` and render through `BitbudRenderer`
///   (frames already bundled in Resources/BitbudFrames).
/// - `staticImage` buddies use `assetName` = base name (no extension) of a PNG in
///   Resources/Buddies.
struct BuddyCharacter: Identifiable, Hashable {
    let id: String
    let name: String
    let kind: BuddyRenderKind
    /// For `.staticImage`: base PNG name in Resources/Buddies. For `.animatedAtlas`: nil.
    let assetName: String?
    /// Short blurb shown in the picker / Buddy Studio.
    let blurb: String
}

extension BuddyCharacter {
    /// Default selected buddy id (animated Bitbud).
    static let defaultID = "bitbud"

    /// The registry of selectable buddies:
    /// - Bitbud: the animated atlas buddy (BitbudFrames + BitbudRenderer).
    /// - 4 static single-frame buddies (Cody/Prismtek-owned Buddy art, 64x64).
    static let registry: [BuddyCharacter] = [
        BuddyCharacter(
            id: "bitbud",
            name: "Bitbud",
            kind: .animatedAtlas,
            assetName: nil,
            blurb: "Animated companion with idle, wave, work, review, celebrate frames."
        ),
        BuddyCharacter(
            id: "buddy-classic",
            name: "Buddy",
            kind: .staticImage,
            assetName: "buddy_classic",
            blurb: "Static Buddy (single frame). Emotes show as labels + a small bob."
        ),
        BuddyCharacter(
            id: "buddy-green",
            name: "Green Buddy",
            kind: .staticImage,
            assetName: "buddy_green",
            blurb: "Static green Buddy variant (single frame)."
        ),
        BuddyCharacter(
            id: "buddy-pink",
            name: "Pink Buddy",
            kind: .staticImage,
            assetName: "buddy_pink",
            blurb: "Static pink Buddy variant (single frame)."
        ),
        BuddyCharacter(
            id: "buddy-purple",
            name: "Purple Buddy",
            kind: .staticImage,
            assetName: "buddy_purple",
            blurb: "Static purple Buddy variant (single frame)."
        )
    ]

    /// Look up a buddy by id, falling back to the default (Bitbud).
    static func buddy(for id: String) -> BuddyCharacter {
        registry.first { $0.id == id } ?? registry[0]
    }
}
