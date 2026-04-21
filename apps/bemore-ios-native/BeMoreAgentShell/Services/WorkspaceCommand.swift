import Foundation

struct WorkspaceCommand: Codable {
    let action: String
    let payload: String
    let arguments: [String]?
    let requiresConfirmation: Bool
    
    static func decode(from jsonString: String) -> WorkspaceCommand? {
        guard let data = jsonString.data(using: .utf8) else { return nil }
        return try? JSONDecoder().decode(WorkspaceCommand.self, from: data)
    }
}

enum CommandValidationResult {
    case allowed(String)
    case blocked(String)
}
