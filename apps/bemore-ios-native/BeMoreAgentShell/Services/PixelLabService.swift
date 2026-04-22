import Foundation

enum PixelLabError: Error {
    case invalidURL
    case requestFailed(Int, String?)
    case decodingError
    case noToken
    case missingImageData
}

// MARK: - MCP Request/Response Models

struct MCPRequest: Codable {
    let jsonrpc: String
    let method: String
    let params: [String: String]?
    let id: String
}

struct MCPResponse: Codable {
    let jsonrpc: String
    let result: MCPResult?
    let error: MCPError?
    let id: String
}

struct MCPResult: Codable {
    let image: String?  // base64 encoded image
    let url: String?
    let message: String?
}

struct MCPError: Codable {
    let code: Int
    let message: String
}

// MARK: - PixelLab Service (MCP Client)

@MainActor
public class PixelLabService: ObservableObject {
    public static let shared = PixelLabService()
    
    private let mcpEndpoint = "https://api.pixellab.ai/mcp"
    private init() {}
    
    @Published public var isLoading = false
    @Published public var lastError: String?
    
    // MARK: - Public Methods
    
    /// Generate pixel art via PixelLab MCP endpoint
    func generatePixelArt(
        prompt: String,
        width: Int = 64,
        height: Int = 64,
        style: String = "pixelart",
        accessToken: String? = nil
    ) async throws -> Data {
        guard let token = accessToken?.trimmingCharacters(in: .whitespacesAndNewlines), !token.isEmpty else {
            throw PixelLabError.noToken
        }
        
        let requestBody = MCPRequest(
            jsonrpc: "2.0",
            method: "generate_pixel",
            params: [
                "prompt": prompt,
                "width": "\(width)",
                "height": "\(height)",
                "style": style
            ],
            id: UUID().uuidString
        )
        
        let data = try await makeMCPCall(request: requestBody, token: token)
        
        // Decode MCP response
        let response = try JSONDecoder().decode(MCPResponse.self, from: data)
        
        if let error = response.error {
            throw PixelLabError.requestFailed(error.code, error.message)
        }
        
        guard let result = response.result else {
            throw PixelLabError.missingImageData
        }
        
        // Return base64 image data or fetch from URL
        if let base64Image = result.image,
           let imageData = Data(base64Encoded: base64Image) {
            return imageData
        }
        
        if let imageUrl = result.url {
            return try await downloadImage(from: imageUrl)
        }
        
        throw PixelLabError.missingImageData
    }
    
    /// Check account status and credits
    func checkAccountStatus(accessToken: String? = nil) async throws -> (creditsRemaining: Int?, status: String) {
        guard let token = accessToken?.trimmingCharacters(in: .whitespacesAndNewlines), !token.isEmpty else {
            throw PixelLabError.noToken
        }
        
        let requestBody = MCPRequest(
            jsonrpc: "2.0",
            method: "status",
            params: nil,
            id: UUID().uuidString
        )
        
        let data = try await makeMCPCall(request: requestBody, token: token)
        
        let response = try JSONDecoder().decode(MCPResponse.self, from: data)
        
        if let error = response.error {
            return (nil, "Error: \(error.message)")
        }
        
        let credits = Int(response.result?.message ?? "") ?? 0
        return (credits, "active")
    }
    
    /// Validate a token by making a status check
    func validateToken(_ token: String) async -> (isValid: Bool, handle: String?) {
        do {
            let (_, status) = try await checkAccountStatus(accessToken: token)
            return (status == "active", nil)
        } catch {
            return (false, nil)
        }
    }
    
    // MARK: - Private Helpers
    
    private func makeMCPCall(request: MCPRequest, token: String) async throws -> Data {
        guard let url = URL(string: mcpEndpoint) else {
            throw PixelLabError.invalidURL
        }
        
        var urlRequest = URLRequest(url: url)
        urlRequest.httpMethod = "POST"
        urlRequest.setValue("application/json", forHTTPHeaderField: "Content-Type")
        urlRequest.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        urlRequest.timeoutInterval = 120 // 2 minute timeout for generation
        
        let encoder = JSONEncoder()
        urlRequest.httpBody = try encoder.encode(request)
        
        let (data, response) = try await URLSession.shared.data(for: urlRequest)
        
        guard let httpResponse = response as? HTTPURLResponse else {
            throw PixelLabError.requestFailed(0, nil)
        }
        
        if !(200...299).contains(httpResponse.statusCode) {
            let errorString = String(data: data, encoding: .utf8)
            throw PixelLabError.requestFailed(httpResponse.statusCode, errorString)
        }
        
        return data
    }
    
    private func downloadImage(from urlString: String) async throws -> Data {
        guard let url = URL(string: urlString) else {
            throw PixelLabError.invalidURL
        }
        
        let (data, response) = try await URLSession.shared.data(from: url)
        
        guard let httpResponse = response as? HTTPURLResponse,
              (200...299).contains(httpResponse.statusCode) else {
            throw PixelLabError.requestFailed(0, "Failed to download image")
        }
        
        return data
    }
}
