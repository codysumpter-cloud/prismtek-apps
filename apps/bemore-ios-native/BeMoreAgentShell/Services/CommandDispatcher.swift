import Foundation

class CommandDispatcher {
    static let shared = CommandDispatcher()
    
    private let allowedPatterns = [
        "^git (pull|push|status|log|add|commit|fetch|checkout|merge) .*",
        "^xcodebuild .*",
        "^ls .*",
        "^git$",
        "^ls$"
    ]
    
    private let forbiddenChars = [";", "&&", "||", "|", "`", "$(", "${", ">>", ">", "<"]
    
    func validateCommand(_ command: WorkspaceCommand) -> CommandValidationResult {
        let payload = command.payload.trimmingCharacters(in: .whitespacesAndNewlines)
        
        // Block empty commands
        guard !payload.isEmpty else {
            return .blocked("Security Error: Empty command")
        }
        
        // Block dangerous characters
        for char in forbiddenChars {
            if payload.contains(char) {
                return .blocked("Security Error: Command contains forbidden character '\(char)'. Chaining/piping/redirection is not allowed.")
            }
        }
        
        // Check whitelist
        var isAllowed = false
        for pattern in allowedPatterns {
            if payload.range(of: pattern, options: .regularExpression) != nil {
                isAllowed = true
                break
            }
        }
        
        if !isAllowed {
            return .blocked("Security Error: '\(payload.prefix(50))...' is not in the approved whitelist.")
        }
        
        return .allowed(payload)
    }
    
    func execute(_ command: WorkspaceCommand) -> ShellExecutionResult {
        let validationResult = validateCommand(command)
        
        switch validationResult {
        case .blocked(let error):
            logAction(command.payload, nil, error)
            return .failure(error)
            
        case .allowed(let validCommand):
            let result = runShell(validCommand)
            logAction(validCommand, result.output, result.error)
            return result
        }
    }
    
    private func runShell(_ command: String) -> ShellExecutionResult {
        let task = Process()
        let pipe = Pipe()
        let errorPipe = Pipe()
        
        task.standardOutput = pipe
        task.standardError = errorPipe
        task.arguments = ["-c", command]
        task.executableURL = URL(fileURLWithPath: "/bin/zsh")
        
        do {
            try task.run()
            task.waitUntilExit()
            
            let data = pipe.fileHandleForReading.readDataToEndOfFile()
            let errorData = errorPipe.fileHandleForReading.readDataToEndOfFile()
            
            let output = String(data: data, encoding: .utf8) ?? ""
            let error = String(data: errorData, encoding: .utf8)
            
            if task.terminationStatus == 0 {
                return .success(output)
            } else {
                return .failure(error ?? "Exit code: \(task.terminationStatus)")
            }
        } catch {
            return .failure("Execution failed: \(error.localizedDescription)")
        }
    }
    
    private func logAction(_ command: String, _ output: String?, _ error: String?) {
        let timestamp = ISO8601DateFormatter().string(from: Date())
        var logEntry = "[\(timestamp)] CMD: \(command)\n"
        
        if let output = output, !output.isEmpty {
            logEntry += "[\(timestamp)] OUT: \(output.prefix(500))\n"
        }
        
        if let error = error, !error.isEmpty {
            logEntry += "[\(timestamp)] ERR: \(error)\n"
        }
        
        logEntry += "---\n"
        
        // Log to runtime audit
        Task { @MainActor in
            BeMoreWorkspaceRuntime.shared.appendEvent(
                type: "shell.command.executed",
                message: "Shell command executed",
                metadata: [
                    "command_preview": String(command.prefix(100)),
                    "success": error == nil ? "true" : "false"
                ]
            )
        }
        
        // Write to security audit log file
        writeToSecurityLog(logEntry)
    }
    
    private func writeToSecurityLog(_ entry: String) {
        let fileManager = FileManager.default
        let bemoreDir = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first?
            .appendingPathComponent(".bemore") ?? URL(fileURLWithPath: "")
        
        let logURL = bemoreDir.appendingPathComponent("security-audit.log")
        
        do {
            try fileManager.createDirectory(at: bemoreDir, withIntermediateDirectories: true)
            
            if let data = entry.data(using: .utf8) {
                if fileManager.fileExists(atPath: logURL.path) {
                    let fileHandle = try FileHandle(forWritingTo: logURL)
                    _ = fileHandle.seekToEndOfFile()
                    fileHandle.write(data)
                    fileHandle.closeFile()
                } else {
                    try entry.write(to: logURL, atomically: true, encoding: .utf8)
                }
            }
        } catch {
            print("Failed to write security audit log: \(error)")
        }
    }
}

enum ShellExecutionResult {
    case success(String)
    case failure(String)
    
    var output: String {
        switch self {
        case .success(let output): return output
        case .failure(let error): return "ERROR: \(error)"
        }
    }
    
    var error: String? {
        switch self {
        case .success: return nil
        case .failure(let error): return error
        }
    }
    
    var isSuccess: Bool {
        switch self {
        case .success: return true
        case .failure: return false
        }
    }
}
