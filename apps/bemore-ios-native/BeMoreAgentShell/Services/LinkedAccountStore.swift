import Foundation

extension Paths {
    static var linkedAccountsFile: URL { stateDirectory.appendingPathComponent("linked-accounts.json") }
}

enum LinkedAccountProvider: String, Codable, CaseIterable, Identifiable {
    case github
    case chatgpt
    case pixelLab

    var id: String { rawValue }

    var title: String {
        switch self {
        case .github: return "GitHub"
        case .chatgpt: return "ChatGPT / OpenAI"
        case .pixelLab: return "PixelLab"
        }
    }

    var launchURL: URL? {
        switch self {
        case .github: return URL(string: "https://github.com/login")
        case .chatgpt: return URL(string: "https://chatgpt.com/")
        case .pixelLab: return URL(string: "https://pixellab.ai/")
        }
    }

    var tokenHint: String {
        switch self {
        case .github: return "Paste a GitHub access token or PAT if you want private repo access from the app today."
        case .chatgpt: return "Paste an OpenAI-compatible access token if you want the linked route usable before full OAuth lands."
        case .pixelLab: return "Paste your PixelLab API token from https://api.pixellab.ai/"
        }
    }

    var accountPlaceholder: String {
        switch self {
        case .github: return "username"
        case .chatgpt: return "email or account label"
        case .pixelLab: return "PixelLab handle"
        }
    }
}

enum LinkedAccountStatus: String, Codable {
    case unlinked
    case pending
    case linked
}

struct LinkedAccountRecord: Codable, Hashable, Identifiable {
    var id: String { provider.rawValue }
    var provider: LinkedAccountProvider
    var status: LinkedAccountStatus
    var accountHandle: String?
    var accessToken: String?
    var connectionMode: String?
    var linkedAt: Date?
    var lastError: String?

    static func empty(_ provider: LinkedAccountProvider) -> LinkedAccountRecord {
        LinkedAccountRecord(provider: provider, status: .unlinked, accountHandle: nil, accessToken: nil, connectionMode: nil, linkedAt: nil, lastError: nil)
    }

    var isLinked: Bool { status == .linked && !(accessToken?.isEmpty ?? true) }
}

@MainActor
final class LinkedAccountStore: ObservableObject {
    @Published private(set) var records: [LinkedAccountRecord] = LinkedAccountProvider.allCases.map(LinkedAccountRecord.empty)

    func load() {
        guard let data = try? Data(contentsOf: Paths.linkedAccountsFile),
              let decoded = try? JSONDecoder().decode([LinkedAccountRecord].self, from: data) else {
            records = LinkedAccountProvider.allCases.map(LinkedAccountRecord.empty)
            persist()
            return
        }
        records = LinkedAccountProvider.allCases.map { provider in
            decoded.first(where: { $0.provider == provider }) ?? .empty(provider)
        }
    }

    func record(for provider: LinkedAccountProvider) -> LinkedAccountRecord {
        records.first(where: { $0.provider == provider }) ?? .empty(provider)
    }

    func markPending(_ provider: LinkedAccountProvider) {
        update(provider) {
            $0.status = .pending
            $0.lastError = nil
            $0.connectionMode = "browser"
        }
    }

    func completeLink(_ provider: LinkedAccountProvider, accountHandle: String?, accessToken: String?, connectionMode: String) {
        update(provider) {
            $0.accountHandle = accountHandle?.trimmingCharacters(in: .whitespacesAndNewlines).nilIfBlank
            $0.accessToken = accessToken?.trimmingCharacters(in: .whitespacesAndNewlines).nilIfBlank
            $0.connectionMode = connectionMode
            $0.linkedAt = .now
            $0.lastError = nil
            $0.status = ($0.accessToken?.isEmpty == false) ? .linked : .pending
        }
    }

    func unlink(_ provider: LinkedAccountProvider) {
        update(provider) {
            $0 = .empty(provider)
        }
    }

    private func update(_ provider: LinkedAccountProvider, mutate: (inout LinkedAccountRecord) -> Void) {
        var next = record(for: provider)
        mutate(&next)
        if let index = records.firstIndex(where: { $0.provider == provider }) {
            records[index] = next
        } else {
            records.append(next)
        }
        persist()
    }

    private func persist() {
        do {
            let encoder = JSONEncoder()
            encoder.outputFormatting = [.prettyPrinted, .sortedKeys]
            let data = try encoder.encode(records)
            try data.write(to: Paths.linkedAccountsFile, options: [.atomic])
        } catch {}
    }
}

private extension String {
    var nilIfBlank: String? {
        let trimmed = trimmingCharacters(in: .whitespacesAndNewlines)
        return trimmed.isEmpty ? nil : trimmed
    }
}
