import Foundation

struct BeMoreLinkedProviderStatus: Decodable, Identifiable, Hashable {
    var id: String { provider }
    let provider: String
    let label: String
    let configured: Bool
    let scope: String?
    let linked: Bool
    let accountLabel: String?
    let accountId: String?
    let updatedAt: String?
}

struct BeMoreLinkedProviderPayload: Decodable {
    let ok: Bool
    let sessionId: String
    let providers: [BeMoreLinkedProviderStatus]
}

struct BeMoreRuntimeRelayPayload: Decodable {
    let ok: Bool?
    let error: String?
    let path: String?
}

@MainActor
final class BeMoreLinkedRelayStore: ObservableObject {
    @Published var providers: [BeMoreLinkedProviderStatus] = []
    @Published var runtimeRelaySummary: String = "Not checked"
    @Published var lastError: String?

    func refresh(baseURL: String) async {
        let trimmed = baseURL.trimmingCharacters(in: .whitespacesAndNewlines)
        guard let root = URL(string: trimmed.isEmpty ? "https://prismtek.dev" : trimmed) else {
            lastError = "Invalid gateway URL."
            return
        }

        do {
            let authURL = root.appending(path: "api/bemore-auth-status")
            let (authData, _) = try await URLSession.shared.data(from: authURL)
            let authPayload = try JSONDecoder().decode(BeMoreLinkedProviderPayload.self, from: authData)
            providers = authPayload.providers
        } catch {
            lastError = error.localizedDescription
        }

        do {
            var components = URLComponents(url: root.appending(path: "api/bemore-runtime-proxy"), resolvingAgainstBaseURL: false)
            components?.queryItems = [URLQueryItem(name: "path", value: "/status")]
            guard let runtimeURL = components?.url else { return }
            let (runtimeData, response) = try await URLSession.shared.data(from: runtimeURL)
            if let http = response as? HTTPURLResponse, http.statusCode == 200 {
                runtimeRelaySummary = "Configured"
            } else {
                let payload = try? JSONDecoder().decode(BeMoreRuntimeRelayPayload.self, from: runtimeData)
                runtimeRelaySummary = payload?.error ?? "Unavailable"
            }
        } catch {
            runtimeRelaySummary = error.localizedDescription
        }
    }
}
