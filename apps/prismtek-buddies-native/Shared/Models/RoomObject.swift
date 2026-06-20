import Foundation
import CoreGraphics

/// Kind of furniture/prop placed in the cozy room. Drives which Buddy interaction
/// is offered when the object is tapped.
enum RoomObjectKind: String, Codable {
    case chair, desk, bed, shelf, plant, window, rug, musicPlayer, computer
}

/// The interaction a Buddy performs at an object. Maps (in BuddyActionController)
/// to a `BuddyState` animation row + a human-readable action label.
enum BuddyInteraction: String, Codable {
    case sit, work, rest, wave, inspect, waterPlant, listen, celebrate, wait
}

/// A single placeable room object. Decoded from `default-room-objects.json` at launch.
///
/// Coordinates are normalized to the room canvas (0...1, origin top-left):
/// - `position`   center of the sprite
/// - `size`       sprite size as a fraction of the room width/height
/// - `buddyAnchor` where Bitbud's feet stand when interacting with this object
/// - `zIndex`     draw order (higher = front)
struct RoomObject: Identifiable, Codable {
    let id: String
    let name: String
    let kind: RoomObjectKind
    let interaction: BuddyInteraction
    /// Base name (no extension) of the PNG in Resources/RoomArt. nil => no sprite.
    let assetName: String?
    let position: CGPoint
    let size: CGSize
    let buddyAnchor: CGPoint
    let zIndex: Double
}

extension RoomObject {
    /// Loads the default room registry from the bundled JSON. Falls back to an
    /// empty array (room still renders Bitbud + flat theme) if the file is missing
    /// or malformed.
    static func loadDefaultRoom() -> [RoomObject] {
        guard let url = Bundle.main.url(forResource: "default-room-objects", withExtension: "json"),
              let data = try? Data(contentsOf: url),
              let decoded = try? JSONDecoder().decode([RoomObject].self, from: data) else {
            return []
        }
        return decoded
    }
}
