import SwiftUI
import WebKit

struct BuddyAgentBrowserView: View {
    @State private var addressText = "https://www.google.com/search?q=Prismtek+Buddy+agent"
    @State private var currentURL = URL(string: "https://www.google.com/search?q=Prismtek+Buddy+agent")!
    @State private var missionText = "Research this page, save what matters, and prepare a useful note."
    @State private var pendingAction: BuddyAction?
    @StateObject private var sessionStore = BuddyAgentSessionStore()

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                header
                agentLoopPanel
                worldStatePanel
                toolRail
                receiptTimeline
                Divider().overlay(BMOTheme.divider)
                BuddyWebView(url: currentURL)
                    .overlay(alignment: .bottom) {
                        if let pendingAction {
                            pendingActionCard(pendingAction)
                                .padding()
                        }
                    }
            }
            .background(BMOTheme.backgroundPrimary.ignoresSafeArea())
            .navigationTitle("Buddy Agent")
            .navigationBarTitleDisplayMode(.inline)
        }
    }

    private var header: some View {
        VStack(alignment: .leading, spacing: BMOTheme.spacingSM) {
            HStack(spacing: BMOTheme.spacingSM) {
                Image(systemName: "safari.fill")
                    .foregroundColor(BMOTheme.accent)
                    .font(.title2)
                VStack(alignment: .leading, spacing: 2) {
                    Text("Buddy + Lil' Buddy Agent Loop")
                        .foregroundColor(BMOTheme.textPrimary)
                        .font(.headline)
                    Text("Buddy talks to you. Lil' Buddy works delegated steps and reports back.")
                        .foregroundColor(BMOTheme.textSecondary)
                        .font(.caption)
                }
                Spacer()
                StatusBadge(
                    label: sessionStore.activeSession?.status.displayLabel ?? "ready",
                    color: sessionStore.activeSession?.status.color ?? BMOTheme.success
                )
            }

            HStack(spacing: BMOTheme.spacingSM) {
                TextField("Give Buddy a mission", text: $missionText)
                    .textInputAutocapitalization(.sentences)
                    .autocorrectionDisabled(false)
                    .padding(12)
                    .foregroundColor(BMOTheme.textPrimary)
                    .background(BMOTheme.backgroundSecondary)
                    .clipShape(RoundedRectangle(cornerRadius: BMOTheme.radiusSmall, style: .continuous))

                Button("Start") {
                    sessionStore.startSession(originalHumanRequest: missionText)
                }
                .buttonStyle(BMOButtonStyle(isPrimary: false))
                .disabled(missionText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
            }

            HStack(spacing: BMOTheme.spacingSM) {
                TextField("Search or enter URL", text: $addressText)
                    .textInputAutocapitalization(.never)
                    .autocorrectionDisabled()
                    .keyboardType(.URL)
                    .padding(12)
                    .foregroundColor(BMOTheme.textPrimary)
                    .background(BMOTheme.backgroundSecondary)
                    .clipShape(RoundedRectangle(cornerRadius: BMOTheme.radiusSmall, style: .continuous))
                    .onSubmit(loadAddress)

                Button(action: loadAddress) {
                    Image(systemName: "arrow.right.circle.fill")
                        .font(.title2)
                }
                .buttonStyle(.plain)
                .foregroundColor(BMOTheme.accent)
            }
        }
        .padding(BMOTheme.spacingMD)
        .background(BMOTheme.backgroundPrimary)
    }

    private var agentLoopPanel: some View {
        VStack(alignment: .leading, spacing: BMOTheme.spacingSM) {
            HStack(alignment: .top, spacing: BMOTheme.spacingSM) {
                agentStatusCard(
                    name: "Buddy",
                    role: "Orchestrator",
                    icon: "person.crop.circle.badge.checkmark",
                    status: sessionStore.worldState.buddyStatus,
                    detail: "Owns the human conversation, delegates bounded steps, and asks approval when policy requires it.",
                    color: BMOTheme.accent
                )

                agentStatusCard(
                    name: "Lil' Buddy",
                    role: "Worker",
                    icon: "hammer.circle.fill",
                    status: sessionStore.latestWorkerStatus,
                    detail: "Executes safe delegated work, reports every step, and pauses when approval is needed.",
                    color: BMOTheme.success
                )
            }

            HStack(spacing: BMOTheme.spacingSM) {
                Button("Taste Demo Run") {
                    sessionStore.runSafeDemo(
                        originalHumanRequest: missionText,
                        currentURL: currentURL.absoluteString
                    )
                }
                .buttonStyle(BMOButtonStyle(isPrimary: true))

                Button("Create Event Approval Demo") {
                    pendingAction = sessionStore.createDelegatedAction(
                        title: "Create calendar event",
                        intent: "Lil' Buddy prepared an event creation request. Buddy must ask you before anything is written to Calendar.",
                        type: .calendarCreate,
                        risk: .write,
                        currentURL: currentURL.absoluteString
                    )
                }
                .buttonStyle(BMOButtonStyle(isPrimary: false))
            }

            if !sessionStore.timeline.isEmpty {
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: BMOTheme.spacingSM) {
                        ForEach(Array(sessionStore.timeline.prefix(8))) { event in
                            timelineCard(event)
                        }
                    }
                }
            }
        }
        .padding(.horizontal, BMOTheme.spacingMD)
        .padding(.bottom, BMOTheme.spacingSM)
        .background(BMOTheme.backgroundPrimary)
    }

    private var worldStatePanel: some View {
        VStack(alignment: .leading, spacing: BMOTheme.spacingXS) {
            HStack {
                Label("World State", systemImage: "square.grid.3x3.middle.filled")
                    .foregroundColor(BMOTheme.textPrimary)
                    .font(.caption.weight(.semibold))
                Spacer()
                StatusBadge(label: sessionStore.worldState.activeSurface.rawValue, color: BMOTheme.accent)
            }
            Text(sessionStore.worldState.currentMission)
                .foregroundColor(BMOTheme.textSecondary)
                .font(.caption2)
                .lineLimit(2)
            if let activeTool = sessionStore.worldState.activeTool {
                Text("active tool: \(activeTool)")
                    .foregroundColor(BMOTheme.warning)
                    .font(.caption2.weight(.semibold))
            }
            if !sessionStore.worldState.visibleArtifacts.isEmpty {
                Text(sessionStore.worldState.visibleArtifacts.prefix(3).joined(separator: " • "))
                    .foregroundColor(BMOTheme.textTertiary)
                    .font(.caption2)
                    .lineLimit(2)
            }
        }
        .padding(.horizontal, BMOTheme.spacingMD)
        .padding(.bottom, BMOTheme.spacingSM)
        .background(BMOTheme.backgroundPrimary)
    }

    private func agentStatusCard(
        name: String,
        role: String,
        icon: String,
        status: String,
        detail: String,
        color: Color
    ) -> some View {
        VStack(alignment: .leading, spacing: BMOTheme.spacingXS) {
            HStack {
                Label(name, systemImage: icon)
                    .foregroundColor(BMOTheme.textPrimary)
                    .font(.caption.weight(.bold))
                Spacer()
                StatusBadge(label: role, color: color)
            }
            Text(status)
                .foregroundColor(color)
                .font(.caption.weight(.semibold))
            Text(detail)
                .foregroundColor(BMOTheme.textSecondary)
                .font(.caption2)
                .lineLimit(3)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(12)
        .background(BMOTheme.backgroundCard)
        .clipShape(RoundedRectangle(cornerRadius: BMOTheme.radiusMedium, style: .continuous))
    }

    private func timelineCard(_ event: BuddyAgentTimelineEvent) -> some View {
        VStack(alignment: .leading, spacing: 4) {
            HStack {
                Text(event.speaker)
                    .foregroundColor(event.role.color)
                    .font(.caption.weight(.bold))
                Spacer()
                Text(event.createdAt, style: .time)
                    .foregroundColor(BMOTheme.textTertiary)
                    .font(.caption2)
            }
            Text(event.summary)
                .foregroundColor(BMOTheme.textSecondary)
                .font(.caption2)
                .lineLimit(3)
        }
        .frame(width: 220, alignment: .leading)
        .padding(10)
        .background(BMOTheme.backgroundSecondary)
        .clipShape(RoundedRectangle(cornerRadius: BMOTheme.radiusSmall, style: .continuous))
    }

    private var toolRail: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: BMOTheme.spacingSM) {
                actionButton(title: "Summarize Page", icon: "doc.text.magnifyingglass", type: .browserSummarize, risk: .readOnly, intent: "Lil' Buddy should prepare a concise summary from the currently loaded browser page.")
                actionButton(title: "Save Memory", icon: "brain.head.profile", type: .memoryRemember, risk: .draftOnly, intent: "Lil' Buddy should save the current page URL and a user-reviewed note to Buddy memory.")
                actionButton(title: "Note Draft", icon: "note.text.badge.plus", type: .noteDraft, risk: .draftOnly, intent: "Lil' Buddy should prepare a reusable note draft from this page or task context.")
                actionButton(title: "Calendar Draft", icon: "calendar.badge.plus", type: .calendarDraft, risk: .draftOnly, intent: "Lil' Buddy should prepare a calendar event draft. Event creation remains a later approval step.")
                actionButton(title: "Message Draft", icon: "message.badge.waveform", type: .messageDraft, risk: .draftOnly, intent: "Lil' Buddy should prepare a message draft. Sending remains user-reviewed.")
                actionButton(title: "Email Draft", icon: "envelope.badge.fill", type: .emailDraft, risk: .draftOnly, intent: "Lil' Buddy should prepare an email draft. Sending remains user-reviewed.")
            }
            .padding(.horizontal, BMOTheme.spacingMD)
            .padding(.vertical, BMOTheme.spacingSM)
        }
        .background(BMOTheme.backgroundSecondary)
    }

    @ViewBuilder
    private var receiptTimeline: some View {
        if !sessionStore.receipts.isEmpty {
            VStack(alignment: .leading, spacing: BMOTheme.spacingXS) {
                HStack {
                    Label("Receipts", systemImage: "checklist.checked")
                        .foregroundColor(BMOTheme.textPrimary)
                        .font(.caption.weight(.semibold))
                    Spacer()
                    Text("local draft log")
                        .foregroundColor(BMOTheme.textTertiary)
                        .font(.caption2)
                }
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: BMOTheme.spacingSM) {
                        ForEach(Array(sessionStore.receipts.prefix(8))) { receipt in
                            receiptCard(receipt)
                        }
                    }
                }
            }
            .padding(.horizontal, BMOTheme.spacingMD)
            .padding(.vertical, BMOTheme.spacingSM)
            .background(BMOTheme.backgroundPrimary)
        }
    }

    private func receiptCard(_ receipt: BuddyReceipt) -> some View {
        VStack(alignment: .leading, spacing: 4) {
            HStack {
                Text(receipt.agentRole.displayName)
                    .foregroundColor(receipt.agentRole.color)
                    .font(.caption2.weight(.bold))
                Spacer()
                Text(receipt.status.rawValue)
                    .foregroundColor(BMOTheme.textTertiary)
                    .font(.caption2)
            }
            Text(receipt.title)
                .foregroundColor(BMOTheme.textPrimary)
                .font(.caption.weight(.semibold))
                .lineLimit(1)
            Text(receipt.summary)
                .foregroundColor(BMOTheme.textSecondary)
                .font(.caption2)
                .lineLimit(2)
            Text(receipt.createdAt, style: .time)
                .foregroundColor(BMOTheme.textTertiary)
                .font(.caption2)
        }
        .frame(width: 200, alignment: .leading)
        .padding(10)
        .background(BMOTheme.backgroundCard)
        .clipShape(RoundedRectangle(cornerRadius: BMOTheme.radiusSmall, style: .continuous))
    }

    private func actionButton(
        title: String,
        icon: String,
        type: BuddyActionType,
        risk: BuddyRiskClass,
        intent: String
    ) -> some View {
        Button {
            pendingAction = sessionStore.createDelegatedAction(
                title: title,
                intent: intent,
                type: type,
                risk: risk,
                currentURL: currentURL.absoluteString
            )
        } label: {
            HStack(spacing: 8) {
                Image(systemName: icon)
                VStack(alignment: .leading, spacing: 1) {
                    Text(title)
                        .font(.caption.weight(.semibold))
                    Text(risk.displayLabel)
                        .font(.caption2)
                        .foregroundColor(BMOTheme.textTertiary)
                }
            }
            .foregroundColor(BMOTheme.textPrimary)
            .padding(.horizontal, 12)
            .padding(.vertical, 10)
            .background(BMOTheme.backgroundCard)
            .clipShape(RoundedRectangle(cornerRadius: BMOTheme.radiusSmall, style: .continuous))
        }
        .buttonStyle(.plain)
    }

    private func pendingActionCard(_ action: BuddyAction) -> some View {
        VStack(alignment: .leading, spacing: BMOTheme.spacingSM) {
            HStack {
                Label(action.title, systemImage: action.risk.systemImage)
                    .foregroundColor(BMOTheme.textPrimary)
                    .font(.headline)
                Spacer()
                StatusBadge(label: action.risk.displayLabel, color: action.risk.color)
            }

            Text(action.intent)
                .foregroundColor(BMOTheme.textSecondary)
                .font(.subheadline)
                .fixedSize(horizontal: false, vertical: true)

            VStack(alignment: .leading, spacing: 4) {
                Text("Buddy → Lil' Buddy delegation")
                Text("Action type: \(action.type.rawValue)")
                Text("Approval: \(action.requiresApproval ? "Buddy must ask you" : "Lil' Buddy can continue")")
                Text("Current page: \(currentURL.absoluteString)")
                    .lineLimit(2)
            }
            .foregroundColor(BMOTheme.textTertiary)
            .font(.caption)

            if action.requiresApproval {
                Text("Lil' Buddy paused and reported a gated step. Buddy is asking you before work resumes.")
                    .foregroundColor(BMOTheme.warning)
                    .font(.caption.weight(.semibold))
            }

            HStack {
                Button(action.requiresApproval ? "Deny" : "Cancel") {
                    if action.requiresApproval {
                        sessionStore.denyGatedAction(action)
                    } else {
                        sessionStore.cancelWorkerStep(action)
                    }
                    pendingAction = nil
                }
                .buttonStyle(.bordered)

                Spacer()

                Button(action.requiresApproval ? "Approve & Resume" : action.type.confirmationLabel) {
                    if action.requiresApproval {
                        sessionStore.approveGatedAction(action)
                    } else {
                        sessionStore.completeWorkerStep(action)
                    }
                    pendingAction = nil
                }
                .buttonStyle(BMOButtonStyle(isPrimary: true))
            }
        }
        .bmoCard()
        .shadow(color: .black.opacity(0.35), radius: 18, y: 8)
    }

    private func loadAddress() {
        let trimmed = addressText.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return }

        if let directURL = URL(string: trimmed), directURL.scheme != nil {
            currentURL = directURL
            return
        }

        if trimmed.contains(".") && !trimmed.contains(" "), let url = URL(string: "https://\(trimmed)") {
            currentURL = url
            addressText = url.absoluteString
            return
        }

        var components = URLComponents(string: "https://www.google.com/search")
        components?.queryItems = [URLQueryItem(name: "q", value: trimmed)]
        if let searchURL = components?.url {
            currentURL = searchURL
            addressText = searchURL.absoluteString
        }
    }
}

struct BuddyWebView: UIViewRepresentable {
    let url: URL

    func makeUIView(context: Context) -> WKWebView {
        let configuration = WKWebViewConfiguration()
        configuration.defaultWebpagePreferences.allowsContentJavaScript = true
        let webView = WKWebView(frame: .zero, configuration: configuration)
        webView.allowsBackForwardNavigationGestures = true
        webView.navigationDelegate = context.coordinator
        webView.scrollView.backgroundColor = UIColor(BMOTheme.backgroundPrimary)
        webView.load(URLRequest(url: url))
        return webView
    }

    func updateUIView(_ webView: WKWebView, context: Context) {
        guard webView.url != url else { return }
        webView.load(URLRequest(url: url))
    }

    func makeCoordinator() -> Coordinator {
        Coordinator()
    }

    final class Coordinator: NSObject, WKNavigationDelegate {
        func webView(
            _ webView: WKWebView,
            decidePolicyFor navigationAction: WKNavigationAction,
            decisionHandler: @escaping (WKNavigationActionPolicy) -> Void
        ) {
            guard let url = navigationAction.request.url else {
                decisionHandler(.cancel)
                return
            }

            let allowedSchemes: Set<String> = ["http", "https", "about"]
            if let scheme = url.scheme?.lowercased(), allowedSchemes.contains(scheme) {
                decisionHandler(.allow)
            } else {
                decisionHandler(.cancel)
            }
        }
    }
}

#Preview {
    BuddyAgentBrowserView()
}
