
import Foundation

enum GitHubError: Error {
    case invalidURL
    case requestFailed(Int)
    case decodingError
}

actor GitHubService {
    static let shared = GitHubService()
    private init() {}

    private let baseUrl = "https://api.github.com"

    func searchRepositories(query: String) async throws -> [GitHubRepo] {
        let encodedQuery = query.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? ""
        guard let url = URL(string: "\(baseUrl)/search/repositories?q=\(encodedQuery)") else {
            throw GitHubError.invalidURL
        }

        let (data, response) = try await URLSession.shared.data(from: url)
        guard let httpResponse = response as? HTTPURLResponse, (200...299).contains(httpResponse.statusCode) else {
            let code = (response as? HTTPURLResponse)?.statusCode ?? 0
            throw GitHubError.requestFailed(code)
        }

        let decoded = try JSONDecoder().decode(GitHubSearchResponse.self, from: data)
        return decoded.items
    }

    func getRepository(owner: String, repo: String) async throws -> GitHubRepo {
        guard let url = URL(string: "\(baseUrl)/repos/\(owner)/\(repo)") else {
            throw GitHubError.invalidURL
        }

        let (data, response) = try await URLSession.shared.data(from: url)
        guard let httpResponse = response as? HTTPURLResponse, (200...299).contains(httpResponse.statusCode) else {
            let code = (response as? HTTPURLResponse)?.statusCode ?? 0
            throw GitHubError.requestFailed(code)
        }

        return try JSONDecoder().decode(GitHubRepo.self, from: data)
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
