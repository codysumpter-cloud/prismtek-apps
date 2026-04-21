import SwiftUI

struct CommandConfirmationView: View {
    let commandPayload: String
    let commandArguments: [String]?
    let onConfirm: () -> Void
    let onCancel: () -> Void
    
    var body: some View {
        VStack(spacing: 20) {
            Image(systemName: "terminal.fill")
                .font(.system(size: 48))
                .foregroundColor(BMOTheme.accent)
            
            Text("Operator Command Requested")
                .font(.headline)
                .foregroundColor(BMOTheme.textPrimary)
            
            VStack(alignment: .leading, spacing: 12) {
                Text("Command:")
                    .font(.subheadline.weight(.semibold))
                    .foregroundColor(BMOTheme.textSecondary)
                
                Text(commandPayload)
                    .font(.system(.caption, design: .monospaced))
                    .foregroundColor(BMOTheme.textPrimary)
                    .padding(12)
                    .background(BMOTheme.backgroundCard)
                    .clipShape(RoundedRectangle(cornerRadius: 8))
                    .overlay(
                        RoundedRectangle(cornerRadius: 8)
                            .stroke(BMOTheme.divider, lineWidth: 1)
                    )
                
                HStack(spacing: 8) {
                    Image(systemName: "shield.lefthalf.filled")
                        .foregroundColor(BMOTheme.warning)
                    Text("This will execute on your Mac")
                        .font(.caption)
                        .foregroundColor(BMOTheme.textSecondary)
                }
                
                HStack(spacing: 8) {
                    Image(systemName: "clock.fill")
                        .foregroundColor(BMOTheme.textTertiary)
                    Text("Executing in 5 seconds unless cancelled...")
                        .font(.caption)
                        .foregroundColor(BMOTheme.textTertiary)
                        .opacity(0.0) // Placeholder for countdown
                }
            }
            
            HStack(spacing: 16) {
                Button {
                    onCancel()
                } label: {
                    Text("Cancel")
                        .font(.headline)
                        .foregroundColor(BMOTheme.textSecondary)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 14)
                }
                .buttonStyle(.plain)
                .background(BMOTheme.backgroundCard)
                .clipShape(RoundedRectangle(cornerRadius: BMOTheme.radiusMedium))
                
                Button {
                    onConfirm()
                } label: {
                    Text("Execute")
                        .font(.headline)
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 14)
                }
                .buttonStyle(.plain)
                .background(BMOTheme.accent)
                .clipShape(RoundedRectangle(cornerRadius: BMOTheme.radiusMedium))
            }
        }
        .padding(24)
        .background(BMOTheme.backgroundSecondary)
        .clipShape(RoundedRectangle(cornerRadius: BMOTheme.radiusLarge))
        .padding(20)
    }
}

enum OperatorCommandState: Equatable {
    case idle
    case pendingConfirmation(command: WorkspaceCommand)
    case executing(command: WorkspaceCommand)
    case completed(result: ShellExecutionResult)
    
    static func == (lhs: OperatorCommandState, rhs: OperatorCommandState) -> Bool {
        switch (lhs, rhs) {
        case (.idle, .idle): return true
        case (.pendingConfirmation, .pendingConfirmation): return true
        case (.executing, .executing): return true
        case (.completed, .completed): return true
        default: return false
        }
    }
}

@MainActor
class OperatorCommandPresenter: ObservableObject {
    @Published var state: OperatorCommandState = .idle
    
    func presentConfirmation(_ command: WorkspaceCommand) {
        state = .pendingConfirmation(command: command)
    }
    
    func confirm() {
        guard case .pendingConfirmation(let command) = state else { return }
        state = .executing(command: command)
        
        #if os(macOS)
        DispatchQueue.global(qos: .userInitiated).async { [weak self] in
            let result = CommandDispatcher.shared.execute(command)
            
            DispatchQueue.main.async {
                self?.state = .completed(result: result)
            }
        }
        #else
        // On iOS, we cannot execute shell commands locally.
        // In a real scenario, this would send a request to the Mac relay.
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            self?.state = .completed(result: .failure("Execution is only supported on macOS. Please use the Mac paired relay."))
        }
        #endif
    }
    
    func cancel() {
        state = .idle
    }
    
    func dismiss() {
        state = .idle
    }
    
    func isWaitingForConfirmation(_ messageContent: String) -> (Bool, WorkspaceCommand?) {
        // Check for operator command tag
        guard messageContent.contains("[OPERATOR_COMMAND]") || 
              messageContent.contains("```json\n{\"action\"") else {
            return (false, nil)
        }
        
        // Extract JSON from various formats
        if let json = extractOperatorJSON(from: messageContent),
           let command = WorkspaceCommand.decode(from: json) {
            return (true, command)
        }
        
        return (false, nil)
    }
    
    private func extractOperatorJSON(from message: String) -> String? {
        // Try multiple patterns
        let patterns = [
            "\\[OPERATOR_COMMAND\\]\\s*(\\{.*?\\})",
            "```json\\s*(\\{[^`]*\\})\\s*```",
            "`{3}\\s*(\\{[^`]*\\})\\s*`{3}",
            "(\\{\\s*\\\"action\\\"[^}]+\\})",
        ]
        
        for pattern in patterns {
            if let regex = try? NSRegularExpression(pattern: pattern, options: [.dotMatchesLineSeparators]),
               let match = regex.firstMatch(in: message, range: NSRange(message.startIndex..., in: message)) {
                if let range = Range(match.range(at: 1), in: message) {
                    return String(message[range])
                }
            }
        }
        
        return nil
    }
}
