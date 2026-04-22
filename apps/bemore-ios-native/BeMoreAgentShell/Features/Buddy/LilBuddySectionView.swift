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

struct LilBuddyReceipt: Identifiable, Codable, Hashable {
    var id: String
    var lilBuddyID: String
    var parentBuddyInstanceId: String
    var action: String
    var summary: String
    var outcome: String
    var createdAt: Date
}

private struct LilBuddyLibraryState: Codable, Hashable {
    var version: String = "1.1.0"
    var items: [LilBuddy] = []
    var receipts: [LilBuddyReceipt] = []
}

actor LilBuddyStore {
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

    func receipts(for parentBuddyInstanceId: String, lilBuddyID: String) -> [LilBuddyReceipt] {
        load().receipts
            .filter { $0.parentBuddyInstanceId == parentBuddyInstanceId && $0.lilBuddyID == lilBuddyID }
            .sorted { $0.createdAt > $1.createdAt }
    }

    func createLilBuddy(
        parentBuddyInstanceId: String,
        parentBuddyDisplayName: String,
        name: String,
        role: String,
        mission: String
    ) -> ([LilBuddy], [LilBuddyReceipt]) {
        var state = load()
        let now = Date()
        let lilBuddy = LilBuddy(
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
        state.items.append(lilBuddy)
        state.receipts.insert(
            LilBuddyReceipt(
                id: "lil_receipt_\(UUID().uuidString.lowercased())",
                lilBuddyID: lilBuddy.id,
                parentBuddyInstanceId: parentBuddyInstanceId,
                action: "spawn",
                summary: "Spawned Lil’ Buddy \(name)",
                outcome: "ready",
                createdAt: now
            ),
            at: 0
        )
        persist(state)
        return (lilBuddies(for: parentBuddyInstanceId), receipts(for: parentBuddyInstanceId, lilBuddyID: lilBuddy.id))
    }

    func updateStatus(
        lilBuddyID: String,
        parentBuddyInstanceId: String,
        status: LilBuddyStatus,
        action: String,
        summary: String
    ) -> ([LilBuddy], [LilBuddyReceipt]) {
        var state = load()
        if let index = state.items.firstIndex(where: { $0.id == lilBuddyID }) {
            state.items[index].status = status
            state.items[index].updatedAt = Date()
            state.receipts.insert(
                LilBuddyReceipt(
                    id: "lil_receipt_\(UUID().uuidString.lowercased())",
                    lilBuddyID: lilBuddyID,
                    parentBuddyInstanceId: parentBuddyInstanceId,
                    action: action,
                    summary: summary,
                    outcome: status.rawValue,
                    createdAt: Date()
                ),
                at: 0
            )
            persist(state)
        }
        return (lilBuddies(for: parentBuddyInstanceId), receipts(for: parentBuddyInstanceId, lilBuddyID: lilBuddyID))
    }

    func dispatchMission(
        lilBuddyID: String,
        parentBuddyInstanceId: String
    ) -> ([LilBuddy], [LilBuddyReceipt]) {
        var state = load()
        guard let index = state.items.firstIndex(where: { $0.id == lilBuddyID }) else {
            return (lilBuddies(for: parentBuddyInstanceId), receipts(for: parentBuddyInstanceId, lilBuddyID: lilBuddyID))
        }
        let lilBuddy = state.items[index]
        state.items[index].status = .active
        state.items[index].updatedAt = Date()
        state.receipts.insert(
            LilBuddyReceipt(
                id: "lil_receipt_\(UUID().uuidString.lowercased())",
                lilBuddyID: lilBuddyID,
                parentBuddyInstanceId: parentBuddyInstanceId,
                action: "dispatch",
                summary: "Dispatched \(lilBuddy.name) on mission: \(lilBuddy.mission)",
                outcome: "active",
                createdAt: Date()
            ),
            at: 0
        )
        persist(state)
        return (lilBuddies(for: parentBuddyInstanceId), receipts(for: parentBuddyInstanceId, lilBuddyID: lilBuddyID))
    }

    func retireLilBuddy(
        lilBuddyID: String,
        parentBuddyInstanceId: String
    ) -> [LilBuddy] {
        var state = load()
        let retiringName = state.items.first(where: { $0.id == lilBuddyID })?.name ?? "Lil’ Buddy"
        state.items.removeAll { $0.id == lilBuddyID }
        state.receipts.insert(
            LilBuddyReceipt(
                id: "lil_receipt_\(UUID().uuidString.lowercased())",
                lilBuddyID: lilBuddyID,
                parentBuddyInstanceId: parentBuddyInstanceId,
                action: "retire",
                summary: "Retired \(retiringName)",
                outcome: "retired",
                createdAt: Date()
            ),
            at: 0
        )
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
    @State private var selectedReceipts: [String: [LilBuddyReceipt]] = [:]
    @State private var statusMessage: String?

    var body: some View {
        VStack(alignment: .leading, spacing: BMOTheme.spacingMD) {
            HStack(alignment: .top) {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Lil’ Buddies")
                        .font(.headline)
                        .foregroundColor(BMOTheme.textPrimary)
                    Text("Spawn small sub-agents under \(buddy.displayName) for focused missions like scouting, drafting, checking, or follow-through. This runtime is local to iPhone and does not require a Mac connection.")
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
                            Button("Dispatch") {
                                dispatch(lilBuddy)
                            }
                            .buttonStyle(BMOButtonStyle(isPrimary: lilBuddy.status != .active))

                            Menu("Set Status") {
                                Button("Ready") { setStatus(for: lilBuddy, status: .ready, action: "reset", summary: "Reset \(lilBuddy.name) for another run.") }
                                Button("Blocked") { setStatus(for: lilBuddy, status: .blocked, action: "block", summary: "Marked \(lilBuddy.name) as blocked.") }
                                Button("Done") { setStatus(for: lilBuddy, status: .done, action: "complete", summary: "Marked \(lilBuddy.name) mission complete.") }
                            }
                            .foregroundColor(BMOTheme.accent)

                            Spacer()

                            Button("Retire") {
                                retire(lilBuddy)
                            }
                            .foregroundColor(BMOTheme.error)
                        }

                        let receipts = selectedReceipts[lilBuddy.id] ?? []
                        if receipts.isEmpty == false {
                            VStack(alignment: .leading, spacing: 6) {
                                Text("Mission receipts")
                                    .font(.caption.weight(.semibold))
                                    .foregroundColor(BMOTheme.textTertiary)
                                ForEach(receipts.prefix(3)) { receipt in
                                    VStack(alignment: .leading, spacing: 2) {
                                        Text(receipt.summary)
                                            .font(.caption)
                                            .foregroundColor(BMOTheme.textPrimary)
                                        Text("\(receipt.action.capitalized) • \(receipt.outcome.capitalized) • \(BuddyMarkdownRenderer.iso8601(receipt.createdAt))")
                                            .font(.caption2)
                                            .foregroundColor(BMOTheme.textTertiary)
                                    }
                                }
                            }
                        }
                    }
                    .padding(BMOTheme.spacingMD)
                    .background(BMOTheme.backgroundSecondary)
                    .clipShape(RoundedRectangle(cornerRadius: BMOTheme.radiusSmall, style: .continuous))
                }
            }
        }
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
            let (items, receipts) = await LilBuddyStore.shared.createLilBuddy(
                parentBuddyInstanceId: buddy.instanceId,
                parentBuddyDisplayName: buddy.displayName,
                name: cleanedName,
                role: cleanedRole,
                mission: cleanedMission
            )
            await MainActor.run {
                lilBuddies = items
                if let created = items.first(where: { $0.name == cleanedName }) {
                    selectedReceipts[created.id] = receipts
                }
                lilBuddyName = ""
                lilBuddyRole = "Scout"
                lilBuddyMission = ""
                statusMessage = "\(buddy.displayName) spawned Lil’ Buddy \(cleanedName)."
            }
        }
    }

    private func dispatch(_ lilBuddy: LilBuddy) {
        Task {
            let (items, receipts) = await LilBuddyStore.shared.dispatchMission(
                lilBuddyID: lilBuddy.id,
                parentBuddyInstanceId: buddy.instanceId
            )
            await MainActor.run {
                lilBuddies = items
                selectedReceipts[lilBuddy.id] = receipts
                statusMessage = "Dispatched \(lilBuddy.name) locally on iPhone."
            }
        }
    }

    private func setStatus(for lilBuddy: LilBuddy, status: LilBuddyStatus, action: String, summary: String) {
        Task {
            let (items, receipts) = await LilBuddyStore.shared.updateStatus(
                lilBuddyID: lilBuddy.id,
                parentBuddyInstanceId: buddy.instanceId,
                status: status,
                action: action,
                summary: summary
            )
            await MainActor.run {
                lilBuddies = items
                selectedReceipts[lilBuddy.id] = receipts
                statusMessage = summary
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
                selectedReceipts[lilBuddy.id] = []
                statusMessage = "Retired Lil’ Buddy \(lilBuddy.name)."
            }
        }
    }

    private func reloadLilBuddies() async {
        let items = await LilBuddyStore.shared.lilBuddies(for: buddy.instanceId)
        var receiptMap: [String: [LilBuddyReceipt]] = [:]
        for item in items {
            receiptMap[item.id] = await LilBuddyStore.shared.receipts(for: buddy.instanceId, lilBuddyID: item.id)
        }
        await MainActor.run {
            lilBuddies = items
            selectedReceipts = receiptMap
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
