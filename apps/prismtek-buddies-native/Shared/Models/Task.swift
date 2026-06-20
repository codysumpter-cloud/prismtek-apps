import Foundation

/// A single cozy-room to-do item. Codable so the list can be JSON-persisted via @AppStorage.
struct BuddyTask: Identifiable, Codable, Equatable {
    var id: UUID
    var title: String
    var isDone: Bool
    var createdAt: Date

    init(id: UUID = UUID(), title: String, isDone: Bool = false, createdAt: Date = Date()) {
        self.id = id
        self.title = title
        self.isDone = isDone
        self.createdAt = createdAt
    }
}
