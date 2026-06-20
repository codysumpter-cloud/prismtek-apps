import SwiftUI
#if os(macOS)
import AppKit
#else
import UIKit
#endif

/// Original SwiftUI cozy room scene — all shapes/gradients, no third-party art.
/// Zones: wall, floor, desk/workstation, shelf/decor, window/ambience, pet placement.
/// Wall/floor/accent colors and desk/decor labels are driven by the selected
/// `BuddyRoomTheme` (persisted via @AppStorage, default Cozy Desk).
struct CozyRoomView: View {
    @EnvironmentObject var appState: AppState
    @AppStorage("buddy.room.theme") private var themeID: String = BuddyRoomTheme.defaultID

    private var theme: BuddyRoomTheme { BuddyRoomTheme.theme(for: themeID) }

    var body: some View {
        let theme = self.theme
        GeometryReader { geo in
            let w = geo.size.width
            let h = geo.size.height
            let floorY = h * 0.66

            ZStack {
                // Wall (theme-driven)
                LinearGradient(
                    colors: [theme.wallColor,
                             theme.wallColor.darkened(by: 0.18)],
                    startPoint: .top, endPoint: .bottom
                )

                // Floor (theme-driven)
                VStack(spacing: 0) {
                    Spacer()
                    LinearGradient(
                        colors: [theme.floorColor,
                                 theme.floorColor.darkened(by: 0.18)],
                        startPoint: .top, endPoint: .bottom
                    )
                    .frame(height: h - floorY)
                }

                // Window / ambience zone (top-right)
                WindowZone(active: anyAmbienceOn, accent: theme.accentColor)
                    .frame(width: w * 0.26, height: h * 0.30)
                    .position(x: w * 0.80, y: h * 0.24)

                // Shelf / decor zone (top-left)
                ShelfZone(label: theme.decorLabel, accent: theme.accentColor)
                    .frame(width: w * 0.30, height: h * 0.22)
                    .position(x: w * 0.20, y: h * 0.20)

                // Desk / workstation zone (lower-left on floor)
                DeskZone(working: appState.buddyState == .running,
                         label: theme.deskLabel,
                         accent: theme.accentColor)
                    .frame(width: w * 0.34, height: h * 0.28)
                    .position(x: w * 0.26, y: floorY + (h - floorY) * 0.32)

                // Rug under pet
                Ellipse()
                    .fill(theme.accentColor.opacity(0.35))
                    .frame(width: w * 0.30, height: h * 0.10)
                    .position(x: w * 0.66, y: floorY + (h - floorY) * 0.45)

                // Pet placement zone
                BitbudRenderer(state: appState.buddyState, pixelScale: petScale(for: w))
                    .position(x: w * 0.66, y: floorY + (h - floorY) * 0.20)
                    .shadow(color: .black.opacity(0.25), radius: 6, y: 6)
            }
            .clipped()
        }
    }

    private var anyAmbienceOn: Bool {
        appState.rainOn || appState.keyboardOn || appState.fireplaceOn || appState.cafeOn
    }

    private func petScale(for width: CGFloat) -> CGFloat {
        max(0.9, min(1.6, width / 520))
    }
}

private struct WindowZone: View {
    let active: Bool
    let accent: Color
    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 10)
                .fill(Color(red: 0.20, green: 0.17, blue: 0.30))
            RoundedRectangle(cornerRadius: 6)
                .fill(
                    LinearGradient(
                        colors: active
                            ? [Color(red: 0.55, green: 0.75, blue: 0.95), Color(red: 0.30, green: 0.45, blue: 0.70)]
                            : [Color(red: 0.18, green: 0.22, blue: 0.40), Color(red: 0.10, green: 0.12, blue: 0.24)],
                        startPoint: .top, endPoint: .bottom
                    )
                )
                .padding(8)
            // Mullions
            Rectangle().fill(Color(red: 0.20, green: 0.17, blue: 0.30)).frame(width: 4)
            Rectangle().fill(Color(red: 0.20, green: 0.17, blue: 0.30)).frame(height: 4)
            if active {
                Circle().fill(accent.opacity(0.85)).frame(width: 18, height: 18)
                    .offset(x: 20, y: -16)
            }
        }
    }
}

private struct ShelfZone: View {
    let label: String
    let accent: Color
    var body: some View {
        VStack(spacing: 4) {
            ForEach(0..<2, id: \.self) { _ in
                ZStack(alignment: .bottom) {
                    HStack(spacing: 6) {
                        RoundedRectangle(cornerRadius: 2).fill(Color(red: 0.70, green: 0.35, blue: 0.35)).frame(width: 10, height: 26)
                        RoundedRectangle(cornerRadius: 2).fill(Color(red: 0.35, green: 0.55, blue: 0.45)).frame(width: 10, height: 32)
                        RoundedRectangle(cornerRadius: 2).fill(accent).frame(width: 10, height: 22)
                        Circle().fill(Color(red: 0.55, green: 0.70, blue: 0.45)).frame(width: 16, height: 16)
                    }
                    Rectangle().fill(Color(red: 0.45, green: 0.32, blue: 0.25)).frame(height: 5)
                }
            }
            Text(label)
                .font(.system(size: 9, weight: .semibold))
                .foregroundStyle(.white.opacity(0.65))
        }
    }
}

private struct DeskZone: View {
    let working: Bool
    let label: String
    let accent: Color
    var body: some View {
        ZStack(alignment: .bottom) {
            // Desk top + legs
            VStack(spacing: 0) {
                RoundedRectangle(cornerRadius: 4)
                    .fill(Color(red: 0.45, green: 0.32, blue: 0.25))
                    .frame(height: 14)
                HStack {
                    Rectangle().fill(Color(red: 0.38, green: 0.27, blue: 0.21)).frame(width: 10)
                    Spacer()
                    Rectangle().fill(Color(red: 0.38, green: 0.27, blue: 0.21)).frame(width: 10)
                }
            }
            // Desk label
            Text(label)
                .font(.system(size: 9, weight: .semibold))
                .foregroundStyle(.white.opacity(0.65))
                .offset(y: -2)
            // Monitor on desk
            VStack(spacing: 0) {
                RoundedRectangle(cornerRadius: 4)
                    .fill(working ? accent : Color(red: 0.15, green: 0.18, blue: 0.24))
                    .frame(width: 54, height: 34)
                Rectangle().fill(Color(red: 0.20, green: 0.20, blue: 0.22)).frame(width: 8, height: 8)
            }
            .offset(y: -22)
        }
    }
}

// MARK: - Color helper

private extension Color {
    /// Returns a darker variant by scaling RGB components toward black.
    /// Cross-platform (resolves via the platform's native color).
    func darkened(by amount: Double) -> Color {
        let factor = max(0, 1 - amount)
        #if os(macOS)
        let native = NSColor(self).usingColorSpace(.sRGB) ?? NSColor(self)
        return Color(red: Double(native.redComponent) * factor,
                     green: Double(native.greenComponent) * factor,
                     blue: Double(native.blueComponent) * factor)
        #else
        var r: CGFloat = 0, g: CGFloat = 0, b: CGFloat = 0, a: CGFloat = 0
        UIColor(self).getRed(&r, green: &g, blue: &b, alpha: &a)
        return Color(red: Double(r) * factor,
                     green: Double(g) * factor,
                     blue: Double(b) * factor)
        #endif
    }
}
