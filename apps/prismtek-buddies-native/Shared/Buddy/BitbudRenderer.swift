import SwiftUI

#if os(macOS)
import AppKit
typealias PlatformImage = NSImage
#else
import UIKit
typealias PlatformImage = UIImage
#endif

/// Loads the extracted Bitbud PNG frames (committed in Resources/BitbudFrames) and
/// cycles them on a timer. Never decodes WebP at runtime — frames are pre-sliced PNGs.
struct BitbudRenderer: View {
    let state: BuddyState
    var frameDuration: Double = 0.18
    var pixelScale: CGFloat = 1.0

    @State private var frameIndex: Int = 0

    var body: some View {
        TimelineView(.periodic(from: .now, by: frameDuration)) { context in
            let frames = BitbudFrames.frames(for: state)
            let idx = frameTick(now: context.date, count: frames.count)
            Group {
                if frames.indices.contains(idx), let img = frames[idx] {
                    Image(platformImage: img)
                        .interpolation(.none)
                        .resizable()
                        .scaledToFit()
                } else {
                    // Fallback shape if a frame is missing — keeps the room populated.
                    RoundedRectangle(cornerRadius: 8)
                        .fill(Color.accentColor.opacity(0.6))
                }
            }
            .frame(width: 96 * pixelScale, height: 104 * pixelScale)
        }
    }

    private func frameTick(now: Date, count: Int) -> Int {
        guard count > 0 else { return 0 }
        let elapsed = now.timeIntervalSinceReferenceDate
        return Int(elapsed / frameDuration) % count
    }
}

/// Frame cache. Maps BuddyState -> ordered array of loaded PlatformImages.
enum BitbudFrames {
    /// Atlas row name + frame count for each state (must match the slicer output).
    private static let layout: [BuddyState: (name: String, count: Int)] = [
        .idle: ("idle", 6),
        .waving: ("waving", 4),
        .waiting: ("waiting", 6),
        .running: ("running", 6),
        .review: ("review", 6),
        .failed: ("failed", 8),
        .jumping: ("jumping", 5),
    ]

    private static var cache: [BuddyState: [PlatformImage?]] = [:]

    static func frames(for state: BuddyState) -> [PlatformImage?] {
        if let cached = cache[state] { return cached }
        guard let (name, count) = layout[state] else {
            cache[state] = []
            return []
        }
        let loaded: [PlatformImage?] = (0..<count).map { load("\(name)_\($0)") }
        cache[state] = loaded
        return loaded
    }

    /// Load a PNG bundled as a resource (added via XcodeGen Resources path).
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

extension Image {
    /// Cross-platform Image initializer from NSImage/UIImage.
    init(platformImage: PlatformImage) {
        #if os(macOS)
        self.init(nsImage: platformImage)
        #else
        self.init(uiImage: platformImage)
        #endif
    }
}
