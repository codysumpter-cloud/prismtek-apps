import SwiftUI

struct OperatorCommandResponder: ViewModifier {
    @StateObject private var presenter = OperatorCommandPresenter()
    let messageContent: String
    let onResponse: (String) -> Void
    
    func body(content: Content) -> some View {
        ZStack {
            content
            
            if case .pendingConfirmation(let command) = presenter.state {
                Color.black.opacity(0.5)
                    .ignoresSafeArea()
                    .onTapGesture { presenter.cancel() }
                
                CommandConfirmationView(
                    commandPayload: command.payload,
                    commandArguments: command.arguments,
                    onConfirm: {
                        presenter.confirm()
                        // Send acknowledgment
                        onResponse("Executing operator command: \(command.payload)")
                    },
                    onCancel: {
                        presenter.cancel()
                        onResponse("Operator command cancelled by user.")
                    }
                )
            }
            
            if case .executing = presenter.state {
                VStack(spacing: 16) {
                    ProgressView()
                        .scaleEffect(1.5)
                        .tint(BMOTheme.accent)
                    
                    Text("Executing on Mac...")
                        .font(.headline)
                        .foregroundColor(BMOTheme.textPrimary)
                }
                .padding(32)
                .background(BMOTheme.backgroundSecondary)
                .clipShape(RoundedRectangle(cornerRadius: BMOTheme.radiusLarge))
            }
            
            if case .completed(let result) = presenter.state {
                VStack(spacing: 16) {
                    Image(systemName: result.isSuccess ? "checkmark.circle.fill" : "xmark.circle.fill")
                        .font(.system(size: 48))
                        .foregroundColor(result.isSuccess ? BMOTheme.success : BMOTheme.error)
                    
                    Text(result.isSuccess ? "Command Executed" : "Command Failed")
                        .font(.headline)
                        .foregroundColor(BMOTheme.textPrimary)
                    
                    ScrollView {
                        Text(result.output)
                            .font(.system(.caption, design: .monospaced))
                            .foregroundColor(BMOTheme.textSecondary)
                            .frame(maxWidth: .infinity, alignment: .leading)
                    }
                    .frame(maxHeight: 200)
                    .padding(12)
                    .background(BMOTheme.backgroundCard)
                    .clipShape(RoundedRectangle(cornerRadius: 8))
                    
                    Button {
                        presenter.dismiss()
                        onResponse("Operator result:\n```\n\(result.output.prefix(500))\n```")
                    } label: {
                        Text("Dismiss")
                            .font(.headline)
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 14)
                    }
                    .buttonStyle(.plain)
                    .background(BMOTheme.accent)
                    .clipShape(RoundedRectangle(cornerRadius: BMOTheme.radiusMedium))
                }
                .padding(24)
                .background(BMOTheme.backgroundSecondary)
                .clipShape(RoundedRectangle(cornerRadius: BMOTheme.radiusLarge))
            }
        }
        .onChange(of: messageContent) { _, newContent in
            let (isCommand, command) = presenter.isWaitingForConfirmation(newContent)
            if isCommand, let cmd = command {
                presenter.presentConfirmation(cmd)
            }
        }
    }
}

extension View {
    func operatorCommandResponder(messageContent: String, onResponse: @escaping (String) -> Void) -> some View {
        modifier(OperatorCommandResponder(messageContent: messageContent, onResponse: onResponse))
    }
}
