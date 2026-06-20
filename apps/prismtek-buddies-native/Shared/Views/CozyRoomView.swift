import SwiftUI
#if os(macOS)
import AppKit
#else
import UIKit
#endif

/// Interactive PIXEL-ART cozy room.
///
/// Renders the room from the `RoomObject` registry (loaded from
/// `default-room-objects.json`) as hard-edged sprite images. The wall/floor are FLAT
/// theme-colored pixel blocks (no gradients). Each object is tappable: tapping moves
/// Bitbud to the object's `buddyAnchor`, sets a Buddy animation state, and shows an
/// action label.
///
/// All sprites + Bitbud render with `.interpolation(.none)` for crisp pixels.
/// `BuddyRoomTheme` (wall/floor/accent) still drives the palette.
struct CozyRoomView: View {
    @EnvironmentObject var appState: AppState
    @AppStorage("buddy.room.theme") private var themeID: String = BuddyRoomTheme.defaultID

    private var theme: BuddyRoomTheme { BuddyRoomTheme.theme(for: themeID) }

    var body: some View {
        let theme = self.theme
        GeometryReader { geo in
            let w = geo.size.width
            let h = geo.size.height
            let floorTop = h * 0.66

            ZStack(alignment: .topLeading) {
                // Flat wall band (no gradient).
                theme.wallColor
                    .frame(width: w, height: floorTop)

                // Flat floor band (no gradient).
                theme.floorColor
                    .frame(width: w, height: h - floorTop)
                    .offset(y: floorTop)

                // 2px pixel skirting line in the accent color at the wall/floor seam.
                theme.accentColor
                    .frame(width: w, height: 2)
                    .offset(y: floorTop - 1)

                // Room objects (sorted by zIndex), then Bitbud layered by its own anchor.
                ForEach(appState.roomObjects.sorted { $0.zIndex < $1.zIndex }) { object in
                    RoomObjectSprite(
                        object: object,
                        roomSize: geo.size,
                        accent: theme.accentColor,
                        isSelected: appState.selectedObjectID == object.id
                    )
                    .zIndex(object.zIndex)
                    .onTapGesture { appState.interact(with: object) }
                }

                // Bitbud — moves to the active buddyAnchor, animated.
                BitbudRenderer(state: appState.buddyState, pixelScale: petScale(for: w))
                    .frame(width: 96 * petScale(for: w), height: 104 * petScale(for: w))
                    .position(x: appState.buddyAnchor.x * w,
                              y: appState.buddyAnchor.y * h - 52 * petScale(for: w))
                    .zIndex(50)
                    .animation(.easeInOut(duration: 0.45), value: appState.buddyAnchor)

                // Action label (flat pixel-style chip, top-left).
                if !appState.actionLabel.isEmpty {
                    Text(appState.actionLabel)
                        .font(.system(size: 11, weight: .semibold, design: .monospaced))
                        .foregroundStyle(.white)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(Color.black.opacity(0.55))
                        .padding(8)
                        .zIndex(100)
                }
            }
            .frame(width: w, height: h)
            .clipped()
        }
    }

    private func petScale(for width: CGFloat) -> CGFloat {
        max(0.7, min(1.4, width / 600))
    }
}

/// A single hard-edged room sprite. Falls back to a flat accent block if the PNG
/// can't load, so the room layout stays intact. Shows a subtle selected state
/// (accent outline + slight scale).
private struct RoomObjectSprite: View {
    let object: RoomObject
    let roomSize: CGSize
    let accent: Color
    let isSelected: Bool

    var body: some View {
        let w = roomSize.width
        let h = roomSize.height
        let spriteW = object.size.width * w
        let spriteH = object.size.height * h

        Group {
            if let name = object.assetName, let img = RoomArt.image(named: name) {
                Image(platformImage: img)
                    .interpolation(.none)   // hard-edged pixels, no blur
                    .resizable()
                    .scaledToFit()
            } else {
                // Fallback flat block keeps the layout readable if art is missing.
                Rectangle().fill(accent.opacity(0.5))
            }
        }
        .frame(width: spriteW, height: spriteH)
        .scaleEffect(isSelected ? 1.08 : 1.0)
        .overlay {
            if isSelected {
                Rectangle()
                    .strokeBorder(accent, lineWidth: 2)
                    .frame(width: spriteW + 4, height: spriteH + 4)
            }
        }
        .animation(.easeInOut(duration: 0.15), value: isSelected)
        .position(x: object.position.x * w, y: object.position.y * h)
        .contentShape(Rectangle())
    }
}

/// RoomArt PNG loader/cache. Mirrors BitbudFrames: loads bundled PNGs from
/// Resources/RoomArt (added via XcodeGen as flat resources).
enum RoomArt {
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
