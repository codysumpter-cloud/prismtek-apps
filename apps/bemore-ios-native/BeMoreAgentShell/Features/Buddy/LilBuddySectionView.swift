import Foundation
import SwiftUI

struct LilBuddy: Identifiable, Codable, Hashable {
    var id: String
    var parentBuddyInstanceId: String
    var parentBuddyDisplayName: String
    var name: String
    var role: String
    var mission: String
    var status: LilBuddyStatus
    var createdAt: Date
    var updatedAt: Date
}

enum LilBuddyStatus: String, Codable, CaseIterable, Hashable, Identifiable {
    case ready
    case active
    case blocked
    case done

    var id: String { rawValue }

    var title: String {
        switch self {
        case .ready: return "Ready"
        case .active: return "Active"
        case .blocked: return "Blocked"
        case .done: return "Done"
        }
    }

    var color: Color {
        switch self {
        case .ready: return BMOTheme.accent
        case .active: return BMOTheme.success
        case .blocked: return BMOTheme.warning
        case .done: return BMOTheme.textSecondary
        }
    }
}

private struct LilBuddyLibraryState: Codable, Hashable {
    var version: String = "1.0.0"
    var items: [LilBuddy] = []
}

private actor LilBuddyStore {
    static let shared = LilBuddyStore()

    private let encoder: JSONEncoder = {
        let encoder = JSONEncoder()
        encoder.outputFormatting = [.prettyPrinted, .sortedKeys]
        encoder.dateEncodingStrategy = .iso8601
        return encoder
    }()

    private let decoder: JSONDecoder = {
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        return decoder
    }()

    private var url: URL {
        Paths.stateDirectory.appendingPathComponent("lil-buddies.json")
    }

    func lilBuddies(for parentBuddyInstanceId: String) -> [LilBuddy] {
        load().items
            .filter { $0.parentBuddyInstanceId == parentBuddyInstanceId }
            .sorted { lhs, rhs in
                if lhs.updatedAt == rhs.updatedAt { return lhs.name < rhs.name }
                return lhs.updatedAt > rhs.updatedAt
            }
    }

    func createLilBuddy(
        parentBuddyInstanceId: String,
        parentBuddyDisplayName: String,
        name: String,
        role: String,
        mission: String
    ) -> [LilBuddy] {
        var state = load()
        let now = Date()
        state.items.append(
            LilBuddy(
                id: "lil_\(UUID().uuidString.lowercased())",
                parentBuddyInstanceId: parentBuddyInstanceId,
                parentBuddyDisplayName: parentBuddyDisplayName,
                name: name,
                role: role,
                mission: mission,
                status: .ready,
                createdAt: now,
                updatedAt: now
            )
        )
        persist(state)
        return lilBuddies(for: parentBuddyInstanceId)
    }

    func updateStatus(
        lilBuddyID: String,
        parentBuddyInstanceId: String,
        status: LilBuddyStatus
    ) -> [LilBuddy] {
        var state = load()
        if let index = state.items.firstIndex(where: { $0.id == lilBuddyID }) {
            state.items[index].status = status
            state.items[index].updatedAt = Date()
            persist(state)
        }
        return lilBuddies(for: parentBuddyInstanceId)
    }

    func retireLilBuddy(
        lilBuddyID: String,
        parentBuddyInstanceId: String
    ) -> [LilBuddy] {
        var state = load()
        state.items.removeAll { $0.id == lilBuddyID }
        persist(state)
        return lilBuddies(for: parentBuddyInstanceId)
    }

    private func load() -> LilBuddyLibraryState {
        guard let data = try? Data(contentsOf: url),
              let decoded = try? decoder.decode(LilBuddyLibraryState.self, from: data) else {
            return LilBuddyLibraryState()
        }
        return decoded
    }

    private func persist(_ state: LilBuddyLibraryState) {
        do {
            let data = try encoder.encode(state)
            try FileManager.default.createDirectory(at: url.deletingLastPathComponent(), withIntermediateDirectories: true)
            try data.write(to: url, options: [.atomic])
        } catch {
            // best effort local persistence only
        }
    }
}

struct LilBuddySectionView: View {
    let buddy: BuddyInstance

    @State private var lilBuddies: [LilBuddy] = []
    @State private var lilBuddyName = ""
    @State private var lilBuddyRole = "Scout"
    @State private var lilBuddyMission = ""
    @State private var statusMessage: String?

    var body: some View {
        VStack(alignment: .leading, spacing: BMOTheme.spacingMD) {
            HStack(alignment: .top) {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Lil’ Buddies")
                        .font(.headline)
                        .foregroundColor(BMOTheme.textPrimary)
                    Text("Spawn small sub-agents under \(buddy.displayName) for focused missions like scouting, drafting, checking, or follow-through.")
                        .font(.subheadline)
                        .foregroundColor(BMOTheme.textSecondary)
                }
                Spacer()
                StatusBadge(label: "\(lilBuddies.count) live", color: lilBuddies.isEmpty ? BMOTheme.textSecondary : BMOTheme.success)
            }

            VStack(alignment: .leading, spacing: 10) {
                lilBuddyField("Lil’ Buddy name", text: $lilBuddyName)
                lilBuddyField("Role", text: $lilBuddyRole)
                lilBuddyField("Mission", text: $lilBuddyMission, axis: .vertical)
                Button("Spawn Lil’ Buddy") {
                    spawnLilBuddy()
                }
                .buttonStyle(BMOButtonStyle())
                .disabled(lilBuddyName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty || lilBuddyMission.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
            }

            if let statusMessage {
                Text(statusMessage)
                    .font(.caption)
                    .foregroundColor(BMOTheme.textSecondary)
            }

            if lilBuddies.isEmpty {
                Text("No Lil’ Buddies yet. Spawn one to delegate a focused mission under \(buddy.displayName).")
                    .font(.subheadline)
                    .foregroundColor(BMOTheme.textSecondary)
            } else {
                ForEach(lilBuddies) { lilBuddy in
                    VStack(alignment: .leading, spacing: 8) {
                        HStack(alignment: .top) {
                            VStack(alignment: .leading, spacing: 4) {
                                Text(lilBuddy.name)
                                    .font(.subheadline.weight(.semibold))
                                    .foregroundColor(BMOTheme.textPrimary)
                                Text(lilBuddy.role)
                                    .font(.caption)
                                    .foregroundColor(BMOTheme.accent)
                                Text(lilBuddy.mission)
                                    .font(.caption)
                                    .foregroundColor(BMOTheme.textSecondary)
                            }
                            Spacer()
                            StatusBadge(label: lilBuddy.status.title, color: lilBuddy.status.color)
                        }

                        HStack {
                            Menu("Set Status") {
                                ForEach(LilBuddyStatus.allCases) { status in
                                    Button(status.title) {
                                        setStatus(for: lilBuddy, status: status)
                                    }
                                }
                            }
                            .foregroundColor(BMOTheme.accent)

                            Spacer()

                            Button("Retire") {
                                retire(lilBuddy)
                            }
                            .foregroundColor(BMOTheme.error)
                        }
                    }
                    .padding(BMOTheme.spacingMD)
                    .background(BMOTheme.backgroundSecondary)
                    .clipShape(RoundedRectangle(cornerRadius: BMOTheme.radiusSmall, style: .continuous))
                }
            }
        }
        .bmoCard()
        .task(id: buddy.instanceId) {
            await reloadLilBuddies()
        }
    }

    private func spawnLilBuddy() {
        let cleanedName = lilBuddyName.trimmingCharacters(in: .whitespacesAndNewlines)
        let cleanedRole = lilBuddyRole.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ? "Scout" : lilBuddyRole.trimmingCharacters(in: .whitespacesAndNewlines)
        let cleanedMission = lilBuddyMission.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !cleanedName.isEmpty, !cleanedMission.isEmpty else { return }

        Task {
            let items = await LilBuddyStore.shared.createLilBuddy(
                parentBuddyInstanceId: buddy.instanceId,
                parentBuddyDisplayName: buddy.displayName,
                name: cleanedName,
                role: cleanedRole,
                mission: cleanedMission
            )
            await MainActor.run {
                lilBuddies = items
                lilBuddyName = ""
                lilBuddyRole = "Scout"
                lilBuddyMission = ""
                statusMessage = "\(buddy.displayName) spawned Lil’ Buddy \(cleanedName)."
            }
        }
    }

    private func setStatus(for lilBuddy: LilBuddy, status: LilBuddyStatus) {
        Task {
            let items = await LilBuddyStore.shared.updateStatus(
                lilBuddyID: lilBuddy.id,
                parentBuddyInstanceId: buddy.instanceId,
                status: status
            )
            await MainActor.run {
                lilBuddies = items
                statusMessage = "\(lilBuddy.name) is now \(status.title.lowercased())."
            }
        }
    }

    private func retire(_ lilBuddy: LilBuddy) {
        Task {
            let items = await LilBuddyStore.shared.retireLilBuddy(
                lilBuddyID: lilBuddy.id,
                parentBuddyInstanceId: buddy.instanceId
            )
            await MainActor.run {
                lilBuddies = items
                statusMessage = "Retired Lil’ Buddy \(lilBuddy.name)."
            }
        }
    }

    private func reloadLilBuddies() async {
        let items = await LilBuddyStore.shared.lilBuddies(for: buddy.instanceId)
        await MainActor.run {
            lilBuddies = items
        }
    }
}

private func lilBuddyField(_ placeholder: String, text: Binding<String>, axis: Axis = .horizontal) -> some View {
    TextField(placeholder, text: text, axis: axis)
        .textFieldStyle(.plain)
        .foregroundColor(BMOTheme.textPrimary)
        .padding(BMOTheme.spacingMD)
        .background(BMOTheme.backgroundSecondary)
        .clipShape(RoundedRectangle(cornerRadius: BMOTheme.radiusSmall, style: .continuous))
}
