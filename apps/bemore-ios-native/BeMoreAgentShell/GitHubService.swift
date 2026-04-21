
import Foundation

enum GitHubError: Error {
    case invalidURL
    case requestFailed(Int)
    case decodingError
}

public class GitHubService {
    public static let shared = GitHubService()
    private init() {}

    private let baseUrl = "https://api.github.com"

    func searchRepositories(query: String, accessToken: String? = nil) async throws -> [GitHubRepo] {
        let encodedQuery = query.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? ""
        guard let url = URL(string: "\(baseUrl)/search/repositories?q=\(encodedQuery)") else {
            throw GitHubError.invalidURL
        }

        let request = makeRequest(url: url, accessToken: accessToken)
        let (data, response) = try await URLSession.shared.data(for: request)
        guard let httpResponse = response as? HTTPURLResponse, (200...299).contains(httpResponse.statusCode) else {
            let code = (response as? HTTPURLResponse)?.statusCode ?? 0
            throw GitHubError.requestFailed(code)
        }

        let decoded = try JSONDecoder().decode(GitHubSearchResponse.self, from: data)
        return decoded.items
    }

    func getRepository(owner: String, repo: String, accessToken: String? = nil) async throws -> GitHubRepo {
        guard let url = URL(string: "\(baseUrl)/repos/\(owner)/\(repo)") else {
            throw GitHubError.invalidURL
        }

        let request = makeRequest(url: url, accessToken: accessToken)
        let (data, response) = try await URLSession.shared.data(for: request)
        guard let httpResponse = response as? HTTPURLResponse, (200...299).contains(httpResponse.statusCode) else {
            let code = (response as? HTTPURLResponse)?.statusCode ?? 0
            throw GitHubError.requestFailed(code)
        }

        return try JSONDecoder().decode(GitHubRepo.self, from: data)
    }

    private func makeRequest(url: URL, accessToken: String?) -> URLRequest {
        var request = URLRequest(url: url)
        request.setValue("application/vnd.github+json", forHTTPHeaderField: "Accept")
        request.setValue("BeMoreAgent", forHTTPHeaderField: "X-GitHub-Api-Version")
        if let token = accessToken?.trimmingCharacters(in: .whitespacesAndNewlines), !token.isEmpty {
            request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        }
        return request
    }
}

struct GitHubRepo: Codable {
    let id: Int
    let name: String
    let fullName: String
    let description: String?
    let htmlUrl: String
    let stargazersCount: Int

    enum CodingKeys: String, CodingKey {
        case id, description
        case name = "name"
        case fullName = "full_name"
        case htmlUrl = "html_url"
        case stargazersCount = "stargazers_count"
    }
}

struct GitHubSearchResponse: Codable {
    let items: [GitHubRepo]
}
