import SwiftUI

/// Renders a `.staticImage` buddy: a single 64x64 PNG from Resources/Buddies.
///
/// Static buddies have NO animation frames, so emotes are conveyed by the room's
/// action label (handled in `CozyRoomView`/`AppState`) plus a small state-driven
/// bob/scale here. Active (non-idle) states nudge the sprite up and scale it slightly
/// so a tap/emote still reads as "the buddy reacted". Crisp pixels via
/// `.interpolation(.none)`.
struct StaticBuddyRenderer: View {
    let assetName: String
    let state: BuddyState
    var pixelScale: CGFloat = 1.0

    var body: some View {
        let active = state != .idle
        Group {
            if let img = BuddyArt.image(named: assetName) {
                Image(platformImage: img)
                    .interpolation(.none)
                    .resizable()
                    .scaledToFit()
            } else {
                // Fallback shape if the PNG is missing — keeps the room populated.
                RoundedRectangle(cornerRadius: 8)
                    .fill(Color.accentColor.opacity(0.6))
            }
        }
        .frame(width: 96 * pixelScale, height: 104 * pixelScale)
        // Static fallback "reaction": a small bob up + scale on any non-idle state.
        .scaleEffect(active ? 1.06 : 1.0)
        .offset(y: active ? -4 * pixelScale : 0)
        .animation(.easeInOut(duration: 0.22), value: state)
    }
}

/// Picks the right renderer for the currently selected buddy by `kind`:
/// - `.animatedAtlas` -> `BitbudRenderer(state:)` (real animation frames).
/// - `.staticImage`   -> `StaticBuddyRenderer` (single PNG + bob/scale fallback).
///
/// Reads the selected buddy id from `@AppStorage("buddy.selected.id")` so the room and
/// Mini Mode stay in sync. Default = Bitbud.
struct SelectedBuddyRenderer: View {
    let state: BuddyState
    var pixelScale: CGFloat = 1.0

    @AppStorage("buddy.selected.id") private var selectedID: String = BuddyCharacter.defaultID

    var body: some View {
        let buddy = BuddyCharacter.buddy(for: selectedID)
        switch buddy.kind {
        case .animatedAtlas:
            BitbudRenderer(state: state, pixelScale: pixelScale)
        case .staticImage:
            StaticBuddyRenderer(assetName: buddy.assetName ?? "buddy_classic",
                                state: state,
                                pixelScale: pixelScale)
        }
    }
}

/// Static buddy PNG loader/cache. Mirrors `BitbudFrames`/`RoomArt`: loads bundled
/// PNGs from Resources/Buddies (added via XcodeGen as flat resources).
enum BuddyArt {
    private static var cache: [String: PlatformImage?] = [:]

    static func image(named: String) -> PlatformImage? {
        if let cached = cache[named] { return cached }
        let img = load(named)
        cache[named] = img
        return img
    }

    private static func load(_ named: String) -> PlatformImage? {
        #if os(macOS)
        if let url = Bundle.main.url(forResource: named, withExtension: "png"),
           let img = NSImage(contentsOf: url) {
            return img
        }
        return NSImage(named: named)
        #else
        if let img = UIImage(named: named) { return img }
        if let url = Bundle.main.url(forResource: named, withExtension: "png"),
           let data = try? Data(contentsOf: url) {
            return UIImage(data: data)
        }
        return nil
        #endif
    }
}
