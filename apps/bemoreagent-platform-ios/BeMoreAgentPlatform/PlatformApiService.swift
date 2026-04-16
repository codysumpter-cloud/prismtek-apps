import Foundation

enum PlatformApiServiceError: Error {
    case invalidURL
    case invalidResponse
    case serverError(String)
}

actor PlatformApiService {
    private let baseURL = "http://localhost:3001/api"
    
    func enqueueGeneration(description: String, templateId: String, target: String, modelId: String) async throws -> [String: Any] {
        guard let url = URL(string: "\(baseURL)/factory/generate") else {
            throw PlatformApiServiceError.invalidURL
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let body: [String: Any] = [
            "description": description,
            "templateId": templateId,
            "target": target,
            "modelId": modelId
        ]
        request.httpBody = try JSONSerialization.data(withJSONObject: body)
        
        let (data, response) = try await URLSession.shared.data(for: request)
        
        guard let httpResponse = response as? HTTPURLResponse, (200...299).contains(httpResponse.statusCode) else {
            throw PlatformApiServiceError.invalidResponse
        }
        
        guard let json = try JSONSerialization.jsonObject(with: data) as? [String: Any] else {
            throw PlatformApiServiceError.invalidResponse
        }
        
        return json
    }
    
    func getJobStatus(jobId: String) async throws -> [String: Any] {
        guard let url = URL(string: "\(baseURL)/factory/jobs/\(jobId)") else {
            throw PlatformApiServiceError.invalidURL
        }
        
        let (data, response) = try await URLSession.shared.data(from: url)
        
        guard let httpResponse = response as? HTTPURLResponse, (200...299).contains(httpResponse.statusCode) else {
            throw PlatformApiServiceError.invalidResponse
        }
        
        guard let json = try JSONSerialization.jsonObject(with: data) as? [String: Any] else {
            throw PlatformApiServiceError.invalidResponse
        }
        
        return json
    }
    
    func launchSandbox(workspaceId: String) async throws -> [String: Any] {
        guard let url = URL(string: "\(baseURL)/sandbox/launch") else {
            throw PlatformApiServiceError.invalidURL
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let body: [String: Any] = ["workspaceId": workspaceId]
        request.httpBody = try JSONSerialization.data(withJSONObject: body)
        
        let (data, response) = try await URLSession.shared.data(for: request)
        
        guard let httpResponse = response as? HTTPURLResponse, (200...299).contains(httpResponse.statusCode) else {
            throw PlatformApiServiceError.invalidResponse
        }
        
        guard let json = try JSONSerialization.jsonObject(with: data) as? [String: Any] else {
            throw PlatformApiServiceError.invalidResponse
        }
        
        return json
    }
}
