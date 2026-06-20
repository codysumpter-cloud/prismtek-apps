import SwiftUI
#if os(macOS)
import AppKit
#else
import UIKit
#endif

/// Interactive pixel-art cozy room.
///
/// The scene is now sprite-backed from wall to floor: tiny PNG tiles repeat across
/// the wall and floor, a pixel baseboard separates the planes, and every prop/Buddy
/// image renders with nearest-neighbor interpolation. The side panels can stay normal
/// SwiftUI; the room itself should read like a small pixel scene.
struct CozyRoomView: View {
    @EnvironmentObject var appState: AppState
    @AppStorage("buddy.room.theme") private var themeID: String = BuddyRoomTheme.defaultID

    private var theme: BuddyRoomTheme { BuddyRoomTheme.theme(for: themeID) }

    var body: some View {
        let theme = self.theme
        GeometryReader { geo in
            let w = geo.size.width
            let h = geo.size.height
            let floorTop = h * 0.62
            let petScale = petScale(for: w)
            let buddyFeet = CGPoint(x: appState.buddyAnchor.x * w, y: appState.buddyAnchor.y * h)
            let buddyTop = buddyFeet.y - 104 * petScale
            let backObjects = appState.roomObjects.filter { $0.zIndex < 50 }.sorted { $0.zIndex < $1.zIndex }
            let frontObjects = appState.roomObjects.filter { $0.zIndex >= 50 }.sorted { $0.zIndex < $1.zIndex }

            ZStack(alignment: .topLeading) {
                PixelTiledBackdrop(
                    tileName: "wall_tile",
                    fallback: theme.wallColor,
                    tileSize: 32,
                    drawPixelGrid: true
                )
                .frame(width: w, height: floorTop)

                PixelTiledBackdrop(
                    tileName: "floor_tile",
                    fallback: theme.floorColor,
                    tileSize: 32,
                    drawPixelGrid: true
                )
                .frame(width: w, height: h - floorTop)
                .offset(y: floorTop)

                PixelBaseboard(accent: theme.accentColor)
                    .frame(width: w, height: 10)
                    .offset(y: floorTop - 6)

                ForEach(backObjects) { object in
                    RoomObjectButton(
                        object: object,
                        roomSize: geo.size,
                        accent: theme.accentColor,
                        isSelected: appState.selectedObjectID == object.id
                    ) {
                        appState.interact(with: object)
                    }
                    .zIndex(object.zIndex)
                }

                SelectedBuddyRenderer(state: appState.buddyState, pixelScale: petScale)
                    .frame(width: 96 * petScale, height: 104 * petScale)
                    .position(x: buddyFeet.x, y: buddyTop + 52 * petScale)
                    .zIndex(50)
                    .animation(.interpolatingSpring(stiffness: 140, damping: 18), value: appState.buddyAnchor)
                    .animation(.easeInOut(duration: 0.18), value: appState.buddyState)

                BuddyFootPixelShadow(width: 44 * petScale, accent: theme.accentColor)
                    .position(x: buddyFeet.x, y: buddyFeet.y - 2)
                    .zIndex(49)
                    .animation(.interpolatingSpring(stiffness: 140, damping: 18), value: appState.buddyAnchor)

                ForEach(frontObjects) { object in
                    RoomObjectButton(
                        object: object,
                        roomSize: geo.size,
                        accent: theme.accentColor,
                        isSelected: appState.selectedObjectID == object.id
                    ) {
                        appState.interact(with: object)
                    }
                    .zIndex(object.zIndex)
                }

                if !appState.actionLabel.isEmpty {
                    PixelActionLabel(text: appState.actionLabel)
                        .padding(8)
                        .zIndex(100)
                }
            }
            .frame(width: w, height: h)
            .background(theme.wallColor)
            .clipped()
        }
    }

    private func petScale(for width: CGFloat) -> CGFloat {
        max(0.66, min(1.18, width / 680))
    }
}

private struct PixelTiledBackdrop: View {
    let tileName: String
    let fallback: Color
    let tileSize: CGFloat
    let drawPixelGrid: Bool

    var body: some View {
        GeometryReader { geo in
            let columns = max(1, Int(ceil(geo.size.width / tileSize)) + 1)
            let rows = max(1, Int(ceil(geo.size.height / tileSize)) + 1)

            ZStack(alignment: .topLeading) {
                fallback
                if let img = RoomArt.image(named: tileName) {
                    ForEach(0..<rows, id: \.self) { row in
                        ForEach(0..<columns, id: \.self) { col in
                            Image(platformImage: img)
                                .interpolation(.none)
                                .resizable()
                                .frame(width: tileSize, height: tileSize)
                                .position(x: CGFloat(col) * tileSize + tileSize / 2,
                                          y: CGFloat(row) * tileSize + tileSize / 2)
                        }
                    }
                }
                if drawPixelGrid {
                    PixelGridOverlay(tileSize: tileSize)
                }
            }
            .clipped()
        }
    }
}

private struct PixelGridOverlay: View {
    let tileSize: CGFloat

    var body: some View {
        GeometryReader { geo in
            let columns = max(1, Int(ceil(geo.size.width / tileSize)) + 1)
            let rows = max(1, Int(ceil(geo.size.height / tileSize)) + 1)
            ZStack(alignment: .topLeading) {
                ForEach(0..<columns, id: \.self) { col in
                    Rectangle()
                        .fill(Color.black.opacity(0.08))
                        .frame(width: 1, height: geo.size.height)
                        .offset(x: CGFloat(col) * tileSize)
                }
                ForEach(0..<rows, id: \.self) { row in
                    Rectangle()
                        .fill(Color.white.opacity(0.05))
                        .frame(width: geo.size.width, height: 1)
                        .offset(y: CGFloat(row) * tileSize)
                }
            }
            .allowsHitTesting(false)
        }
    }
}

private struct PixelBaseboard: View {
    let accent: Color

    var body: some View {
        GeometryReader { geo in
            let tileW: CGFloat = 64
            let columns = max(1, Int(ceil(geo.size.width / tileW)) + 1)
            ZStack(alignment: .topLeading) {
                accent.opacity(0.35)
                if let img = RoomArt.image(named: "baseboard") {
                    ForEach(0..<columns, id: \.self) { col in
                        Image(platformImage: img)
                            .interpolation(.none)
                            .resizable()
                            .frame(width: tileW, height: geo.size.height)
                            .position(x: CGFloat(col) * tileW + tileW / 2, y: geo.size.height / 2)
                    }
                }
                Rectangle().fill(Color.black.opacity(0.25)).frame(height: 2).offset(y: geo.size.height - 2)
            }
            .clipped()
        }
    }
}

private struct BuddyFootPixelShadow: View {
    let width: CGFloat
    let accent: Color

    var body: some View {
        HStack(spacing: 0) {
            Rectangle().fill(Color.black.opacity(0.18))
            Rectangle().fill(accent.opacity(0.18))
            Rectangle().fill(Color.black.opacity(0.18))
        }
        .frame(width: width, height: 6)
        .allowsHitTesting(false)
    }
}

private struct PixelActionLabel: View {
    let text: String

    var body: some View {
        Text(text)
            .font(.system(size: 11, weight: .semibold, design: .monospaced))
            .foregroundStyle(.white)
            .padding(.horizontal, 8)
            .padding(.vertical, 4)
            .background(
                ZStack {
                    Rectangle().fill(Color.black.opacity(0.72))
                    Rectangle().strokeBorder(Color.white.opacity(0.22), lineWidth: 1)
                }
            )
    }
}


private struct RoomObjectButton: View {
    let object: RoomObject
    let roomSize: CGSize
    let accent: Color
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        let spriteW = object.size.width * roomSize.width
        let spriteH = object.size.height * roomSize.height

        Button(action: action) {
            RoomObjectSprite(
                object: object,
                roomSize: roomSize,
                accent: accent,
                isSelected: isSelected
            )
        }
        .buttonStyle(.plain)
        .frame(width: spriteW, height: spriteH)
        .contentShape(Rectangle())
        .position(x: object.position.x * roomSize.width, y: object.position.y * roomSize.height)
        .accessibilityLabel(Text(object.name))
        .accessibilityHint(Text("Move Buddy here"))
    }
}

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
                    .interpolation(.none)
                    .resizable()
                    .scaledToFit()
            } else {
                Rectangle().fill(accent.opacity(0.5))
            }
        }
        .frame(width: spriteW, height: spriteH)
        .offset(y: isSelected ? -2 : 0)
        .overlay {
            if isSelected {
                PixelSelectionOutline(accent: accent)
                    .frame(width: spriteW + 8, height: spriteH + 8)
            }
        }
        .animation(.easeInOut(duration: 0.12), value: isSelected)
        .contentShape(Rectangle())
    }
}

private struct PixelSelectionOutline: View {
    let accent: Color

    var body: some View {
        GeometryReader { geo in
            ZStack(alignment: .topLeading) {
                Rectangle().strokeBorder(Color.black.opacity(0.55), lineWidth: 4)
                Rectangle().strokeBorder(accent, lineWidth: 2)
                Rectangle().fill(accent)
                    .frame(width: 5, height: 5)
                    .offset(x: 0, y: 0)
                Rectangle().fill(accent)
                    .frame(width: 5, height: 5)
                    .offset(x: geo.size.width - 5, y: 0)
                Rectangle().fill(accent)
                    .frame(width: 5, height: 5)
                    .offset(x: 0, y: geo.size.height - 5)
                Rectangle().fill(accent)
                    .frame(width: 5, height: 5)
                    .offset(x: geo.size.width - 5, y: geo.size.height - 5)
            }
        }
        .allowsHitTesting(false)
    }
}

/// RoomArt PNG loader/cache. It supports both the flat RoomArt files and nested
/// RoomArt/RoomTiles PNGs generated for this polish pass.
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
        let subdirs = [nil, "RoomArt", "RoomArt/RoomTiles", "Buddies"]
        for subdir in subdirs {
            if let url = Bundle.main.url(forResource: named, withExtension: "png", subdirectory: subdir),
               let img = NSImage(contentsOf: url) {
                return img
            }
        }
        return NSImage(named: named)
        #else
        if let img = UIImage(named: named) { return img }
        let subdirs = [nil, "RoomArt", "RoomArt/RoomTiles", "Buddies"]
        for subdir in subdirs {
            if let url = Bundle.main.url(forResource: named, withExtension: "png", subdirectory: subdir),
               let data = try? Data(contentsOf: url),
               let img = UIImage(data: data) {
                return img
            }
        }
        return nil
        #endif
    }
}
