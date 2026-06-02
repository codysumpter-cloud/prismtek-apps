import SwiftUI
import WebKit

private let buddyActionLoopSchemaVersion = "2026-06-02.buddy-action.v1"
private let buddyAgentSessionSchemaVersion = "2026-06-02.buddy-agent-session.v1"

struct BuddyAgentBrowserView: View {
    @State private var addressText = "https://www.google.com/search?q=Prismtek+Buddy+agent"
    @State private var currentURL = URL(string: "https://www.google.com/search?q=Prismtek+Buddy+agent")!
    @State private var missionText = "Research this page, save what matters, and prepare a useful note."
    @State private var pendingAction: BuddyAction?
    @State private var receipts: [BuddyReceipt] = []
    @StateObject private var sessionStore = BuddyAgentSessionStore()

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                header
                agentLoopPanel
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
                    Text("Buddy talks to you. Lil' Buddy works the steps and reports back.")
                        .foregroundColor(BMOTheme.textSecondary)
                        .font(.caption)
                }
                Spacer()
                StatusBadge(label: sessionStore.activeSession?.status.displayLabel ?? "ready", color: sessionStore.activeSession?.status.color ?? BMOTheme.success)
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
                    status: sessionStore.activeSession == nil ? "waiting for mission" : "owning the mission",
                    detail: "Talks to you, delegates steps, and asks approval when risk appears.",
                    color: BMOTheme.accent
                )

                agentStatusCard(
                    name: "Lil' Buddy",
                    role: "Worker",
                    icon: "hammer.circle.fill",
                    status: sessionStore.latestWorkerStatus,
                    detail: "Works safe steps, reports back to Buddy, and pauses on protected actions.",
                    color: BMOTheme.success
                )
            }

            HStack(spacing: BMOTheme.spacingSM) {
                Button("Taste Demo Run") {
                    let demoReceipts = sessionStore.runSafeDemo(
                        originalHumanRequest: missionText,
                        currentURL: currentURL.absoluteString
                    )
                    receipts.insert(contentsOf: demoReceipts, at: 0)
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
                actionButton(
                    title: "Summarize Page",
                    icon: "doc.text.magnifyingglass",
                    type: .browserSummarize,
                    risk: .readOnly,
                    intent: "Lil' Buddy should prepare a concise summary from the currently loaded browser page."
                )

                actionButton(
                    title: "Save Memory",
                    icon: "brain.head.profile",
                    type: .memoryRemember,
                    risk: .draftOnly,
                    intent: "Lil' Buddy should save the current page URL and a user-reviewed note to Buddy memory."
                )

                actionButton(
                    title: "Note Draft",
                    icon: "note.text.badge.plus",
                    type: .noteDraft,
                    risk: .draftOnly,
                    intent: "Lil' Buddy should prepare a reusable note draft from this page or task context."
                )

                actionButton(
                    title: "Calendar Draft",
                    icon: "calendar.badge.plus",
                    type: .calendarDraft,
                    risk: .draftOnly,
                    intent: "Lil' Buddy should prepare a calendar event draft. Event creation remains a later approval step."
                )

                actionButton(
                    title: "Message Draft",
                    icon: "message.badge.waveform",
                    type: .messageDraft,
                    risk: .draftOnly,
                    intent: "Lil' Buddy should prepare a message draft. Sending remains user-reviewed."
                )

                actionButton(
                    title: "Email Draft",
                    icon: "envelope.badge.fill",
                    type: .emailDraft,
                    risk: .draftOnly,
                    intent: "Lil' Buddy should prepare an email draft. Sending remains user-reviewed."
                )
            }
            .padding(.horizontal, BMOTheme.spacingMD)
            .padding(.vertical, BMOTheme.spacingSM)
        }
        .background(BMOTheme.backgroundSecondary)
    }

    @ViewBuilder
    private var receiptTimeline: some View {
        if !receipts.isEmpty {
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
                        ForEach(Array(receipts.prefix(8))) { receipt in
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
                    }
                }
            }
            .padding(.horizontal, BMOTheme.spacingMD)
            .padding(.vertical, BMOTheme.spacingSM)
            .background(BMOTheme.backgroundPrimary)
        }
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
                Text("Lil' Buddy paused and reported a protected step. Buddy is asking you before work resumes.")
                    .foregroundColor(BMOTheme.warning)
                    .font(.caption.weight(.semibold))
            }

            HStack {
                Button(action.requiresApproval ? "Deny" : "Cancel") {
                    if action.requiresApproval {
                        let receipt = BuddyReceipt.from(
                            action: action,
                            status: .denied,
                            summary: "Buddy denied the protected worker request. Lil' Buddy stopped and needs a safer plan."
                        )
                        receipts.insert(receipt, at: 0)
                        sessionStore.denyProtectedAction(action, receipt: receipt)
                    } else {
                        let receipt = BuddyReceipt.from(
                            action: action,
                            status: .cancelled,
                            summary: "User cancelled the delegated worker action before execution."
                        )
                        receipts.insert(receipt, at: 0)
                        sessionStore.cancelWorkerStep(action, receipt: receipt)
                    }
                    pendingAction = nil
                }
                .buttonStyle(.bordered)

                Spacer()

                Button(action.requiresApproval ? "Approve & Resume" : action.type.confirmationLabel) {
                    let receipt = BuddyReceipt.from(
                        action: action,
                        status: .completed,
                        summary: action.requiresApproval
                            ? "Human approved the protected request through Buddy. Lil' Buddy may resume with a bounded next step."
                            : action.type.receiptSummary
                    )
                    receipts.insert(receipt, at: 0)

                    if action.requiresApproval {
                        sessionStore.approveProtectedAction(action, receipt: receipt)
                    } else {
                        sessionStore.completeWorkerStep(action, receipt: receipt)
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

private final class BuddyAgentSessionStore: ObservableObject {
    @Published var activeSession: BuddyAgentSession?
    @Published var activeDelegation: BuddyDelegation?
    @Published var workerReports: [BuddyWorkerReport] = []
    @Published var timeline: [BuddyAgentTimelineEvent] = []

    var latestWorkerStatus: String {
        workerReports.first?.status.displayLabel ?? "ready for safe work"
    }

    func startSession(originalHumanRequest: String) {
        let request = sanitizedMission(originalHumanRequest)
        let session = BuddyAgentSession(
            id: UUID(),
            schemaVersion: buddyAgentSessionSchemaVersion,
            originalHumanRequest: request,
            orchestrator: BuddyAgentRuntimeProfile.buddy,
            worker: BuddyAgentRuntimeProfile.lilBuddy,
            status: .running,
            createdAt: Date()
        )
        activeSession = session
        activeDelegation = nil
        workerReports = []
        timeline = [
            BuddyAgentTimelineEvent(
                speaker: "Buddy",
                role: .orchestrator,
                summary: "I heard the mission: \"\(request)\". I’ll talk to you and hand safe steps to Lil' Buddy."
            ),
            BuddyAgentTimelineEvent(
                speaker: "Lil' Buddy",
                role: .worker,
                summary: "Ready. I’ll work the steps, report back to Buddy, and stop if protected approval appears."
            )
        ]
    }

    func createDelegatedAction(
        title: String,
        intent: String,
        type: BuddyActionType,
        risk: BuddyRiskClass,
        currentURL: String
    ) -> BuddyAction {
        ensureSession()
        guard let session = activeSession else {
            return BuddyAction.draft(
                sessionId: nil,
                delegationId: nil,
                buddyId: "default",
                title: title,
                intent: intent,
                type: type,
                risk: risk,
                currentURL: currentURL
            )
        }

        let delegation = BuddyDelegation(
            id: UUID(),
            sessionId: session.id,
            orchestratorAgentId: session.orchestrator.agentId,
            workerAgentId: session.worker.agentId,
            objective: title,
            nextInstruction: intent,
            status: risk.requiresApproval ? .blocked : .running,
            createdAt: Date()
        )
        activeDelegation = delegation

        appendTimeline(
            speaker: "Buddy",
            role: .orchestrator,
            summary: risk.requiresApproval
                ? "Lil' Buddy is asking for a protected step. I’m pausing the work and bringing it to you."
                : "Delegated to Lil' Buddy: \(title)."
        )

        return BuddyAction.draft(
            sessionId: session.id,
            delegationId: delegation.id,
            buddyId: "default",
            title: title,
            intent: intent,
            type: type,
            risk: risk,
            currentURL: currentURL
        )
    }

    func completeWorkerStep(_ action: BuddyAction, receipt: BuddyReceipt) {
        let report = BuddyWorkerReport(
            sessionId: action.sessionId,
            delegationId: action.delegationId,
            status: .stepCompleted,
            summary: "Completed \(action.title) and produced receipt \(receipt.id.uuidString.prefix(8)).",
            completedActionIds: [action.id],
            producedReceiptIds: [receipt.id],
            proposedNextInstruction: "Buddy can choose the next safe step from the original mission."
        )
        workerReports.insert(report, at: 0)
        activeSession?.status = .running
        activeDelegation?.status = .completed
        appendTimeline(speaker: "Lil' Buddy", role: .worker, summary: report.summary)
        appendTimeline(speaker: "Buddy", role: .orchestrator, summary: "Report received. I can continue the mission without bothering you unless approval is needed.")
    }

    func cancelWorkerStep(_ action: BuddyAction, receipt: BuddyReceipt) {
        let report = BuddyWorkerReport(
            sessionId: action.sessionId,
            delegationId: action.delegationId,
            status: .blocked,
            summary: "The delegated step was cancelled before execution.",
            completedActionIds: [],
            producedReceiptIds: [receipt.id],
            proposedNextInstruction: "Buddy should choose a safer or clearer next step."
        )
        workerReports.insert(report, at: 0)
        activeDelegation?.status = .cancelled
        appendTimeline(speaker: "Lil' Buddy", role: .worker, summary: report.summary)
    }

    func approveProtectedAction(_ action: BuddyAction, receipt: BuddyReceipt) {
        let report = BuddyWorkerReport(
            sessionId: action.sessionId,
            delegationId: action.delegationId,
            status: .stepCompleted,
            summary: "Human approval came through Buddy. Protected step is recorded and work can resume safely.",
            completedActionIds: [action.id],
            producedReceiptIds: [receipt.id],
            proposedNextInstruction: "Resume with the next bounded, non-protected step."
        )
        workerReports.insert(report, at: 0)
        activeSession?.status = .running
        activeDelegation?.status = .completed
        appendTimeline(speaker: "Buddy", role: .orchestrator, summary: "Approval received. I’m resuming Lil' Buddy with a bounded next step.")
        appendTimeline(speaker: "Lil' Buddy", role: .worker, summary: report.summary)
    }

    func denyProtectedAction(_ action: BuddyAction, receipt: BuddyReceipt) {
        let report = BuddyWorkerReport(
            sessionId: action.sessionId,
            delegationId: action.delegationId,
            status: .needsApproval,
            summary: "Protected step was denied. Lil' Buddy stopped and reported back to Buddy.",
            completedActionIds: [],
            producedReceiptIds: [receipt.id],
            proposedNextInstruction: "Buddy should replan without the protected action."
        )
        workerReports.insert(report, at: 0)
        activeSession?.status = .waitingForHuman
        activeDelegation?.status = .blocked
        appendTimeline(speaker: "Buddy", role: .orchestrator, summary: "Denied. I’ll replan instead of letting Lil' Buddy continue that path.")
        appendTimeline(speaker: "Lil' Buddy", role: .worker, summary: report.summary)
    }

    func runSafeDemo(originalHumanRequest: String, currentURL: String) -> [BuddyReceipt] {
        startSession(originalHumanRequest: originalHumanRequest)
        let steps: [(String, String, BuddyActionType, BuddyRiskClass)] = [
            (
                "Summarize Page",
                "Lil' Buddy should inspect the current page and prepare a concise summary.",
                .browserSummarize,
                .readOnly
            ),
            (
                "Save Memory",
                "Lil' Buddy should stage the useful takeaway as a Buddy memory.",
                .memoryRemember,
                .draftOnly
            ),
            (
                "Note Draft",
                "Lil' Buddy should prepare a note draft from the result.",
                .noteDraft,
                .draftOnly
            )
        ]

        var generatedReceipts: [BuddyReceipt] = []
        for step in steps {
            let action = createDelegatedAction(
                title: step.0,
                intent: step.1,
                type: step.2,
                risk: step.3,
                currentURL: currentURL
            )
            let receipt = BuddyReceipt.from(action: action, status: .completed, summary: action.type.receiptSummary)
            generatedReceipts.append(receipt)
            completeWorkerStep(action, receipt: receipt)
        }
        activeSession?.status = .completed
        appendTimeline(speaker: "Buddy", role: .orchestrator, summary: "Safe demo loop complete. Buddy stayed human-facing; Lil' Buddy did the worker steps.")
        return Array(generatedReceipts.reversed())
    }

    private func ensureSession() {
        if activeSession == nil {
            startSession(originalHumanRequest: "Continue from the current Agent Browser context.")
        }
    }

    private func sanitizedMission(_ mission: String) -> String {
        let trimmed = mission.trimmingCharacters(in: .whitespacesAndNewlines)
        return trimmed.isEmpty ? "Continue from the current Agent Browser context." : trimmed
    }

    private func appendTimeline(speaker: String, role: BuddyAgentRole, summary: String) {
        timeline.insert(BuddyAgentTimelineEvent(speaker: speaker, role: role, summary: summary), at: 0)
    }
}

private enum BuddyAgentRole: String, Codable, Equatable {
    case orchestrator
    case worker

    var displayName: String {
        switch self {
        case .orchestrator: return "Buddy"
        case .worker: return "Lil' Buddy"
        }
    }

    var color: Color {
        switch self {
        case .orchestrator: return BMOTheme.accent
        case .worker: return BMOTheme.success
        }
    }
}

private enum BuddyAgentSessionStatus: String, Codable, Equatable {
    case open
    case waitingForHuman = "waiting-for-human"
    case running
    case completed
    case failed
    case cancelled

    var displayLabel: String {
        switch self {
        case .open: return "open"
        case .waitingForHuman: return "approval needed"
        case .running: return "running"
        case .completed: return "complete"
        case .failed: return "failed"
        case .cancelled: return "cancelled"
        }
    }

    var color: Color {
        switch self {
        case .open, .running: return BMOTheme.accent
        case .waitingForHuman: return BMOTheme.warning
        case .completed: return BMOTheme.success
        case .failed, .cancelled: return BMOTheme.error
        }
    }
}

private enum BuddyDelegationStatus: String, Codable, Equatable {
    case queued
    case running
    case blocked
    case completed
    case cancelled
    case failed
}

private enum BuddyWorkerReportStatus: String, Codable, Equatable {
    case stepCompleted = "step-completed"
    case needsNextStep = "needs-next-step"
    case blocked
    case needsApproval = "needs-approval"
    case failed
    case done

    var displayLabel: String {
        switch self {
        case .stepCompleted: return "reported step complete"
        case .needsNextStep: return "waiting for Buddy"
        case .blocked: return "blocked"
        case .needsApproval: return "needs approval"
        case .failed: return "failed"
        case .done: return "done"
        }
    }
}

private struct BuddyAgentRuntimeProfile: Identifiable, Codable, Equatable {
    var id: String { agentId }
    var agentId: String
    var buddyId: String
    var role: BuddyAgentRole
    var displayName: String
    var canTalkToHuman: Bool
    var canDelegate: Bool
    var canExecuteTools: Bool

    static let buddy = BuddyAgentRuntimeProfile(
        agentId: "buddy-orchestrator-default",
        buddyId: "default",
        role: .orchestrator,
        displayName: "Buddy",
        canTalkToHuman: true,
        canDelegate: true,
        canExecuteTools: false
    )

    static let lilBuddy = BuddyAgentRuntimeProfile(
        agentId: "lil-buddy-worker-default",
        buddyId: "default",
        role: .worker,
        displayName: "Lil' Buddy",
        canTalkToHuman: false,
        canDelegate: false,
        canExecuteTools: true
    )
}

private struct BuddyAgentSession: Identifiable, Codable, Equatable {
    var id: UUID
    var schemaVersion: String
    var originalHumanRequest: String
    var orchestrator: BuddyAgentRuntimeProfile
    var worker: BuddyAgentRuntimeProfile
    var status: BuddyAgentSessionStatus
    var createdAt: Date
}

private struct BuddyDelegation: Identifiable, Codable, Equatable {
    var id: UUID
    var sessionId: UUID
    var orchestratorAgentId: String
    var workerAgentId: String
    var objective: String
    var nextInstruction: String
    var status: BuddyDelegationStatus
    var createdAt: Date
}

private struct BuddyWorkerReport: Identifiable, Codable, Equatable {
    var id = UUID()
    var sessionId: UUID?
    var delegationId: UUID?
    var status: BuddyWorkerReportStatus
    var summary: String
    var completedActionIds: [UUID]
    var producedReceiptIds: [UUID]
    var proposedNextInstruction: String?
    var createdAt = Date()
}

private struct BuddyAgentTimelineEvent: Identifiable, Codable, Equatable {
    var id = UUID()
    var speaker: String
    var role: BuddyAgentRole
    var summary: String
    var createdAt = Date()
}

private enum BuddyRiskClass: String, Codable, CaseIterable, Equatable {
    case readOnly = "read-only"
    case draftOnly = "draft-only"
    case write
    case externalAction = "external-action"
    case destructive
    case money
    case identity
    case location
    case credential
    case repoMutation = "repo-mutation"

    var displayLabel: String {
        switch self {
        case .readOnly: return "read-only"
        case .draftOnly: return "draft"
        case .write, .externalAction, .location, .repoMutation: return "confirm"
        case .destructive, .money, .identity: return "deny by default"
        case .credential: return "denied"
        }
    }

    var requiresApproval: Bool {
        switch self {
        case .readOnly, .draftOnly:
            return false
        case .write, .externalAction, .destructive, .money, .identity, .location, .credential, .repoMutation:
            return true
        }
    }

    var systemImage: String {
        switch self {
        case .readOnly: return "checkmark.shield.fill"
        case .draftOnly: return "doc.badge.plus"
        case .write, .externalAction, .location, .repoMutation: return "exclamationmark.shield.fill"
        case .destructive, .money, .identity, .credential: return "lock.shield.fill"
        }
    }

    var color: Color {
        switch self {
        case .readOnly, .draftOnly: return BMOTheme.success
        case .write, .externalAction, .location, .repoMutation: return BMOTheme.warning
        case .destructive, .money, .identity, .credential: return BMOTheme.error
        }
    }
}

private enum BuddyActionType: String, Codable, Equatable {
    case browserOpen = "browser.open"
    case browserSummarize = "browser.summarize"
    case memoryRemember = "memory.remember"
    case noteDraft = "note.draft"
    case calendarDraft = "calendar.draft"
    case calendarCreate = "calendar.create"
    case messageDraft = "message.draft"
    case emailDraft = "email.draft"

    var confirmationLabel: String {
        switch self {
        case .browserOpen: return "Open Page"
        case .browserSummarize: return "Lil' Buddy Complete Step"
        case .memoryRemember: return "Lil' Buddy Save Memory"
        case .noteDraft: return "Lil' Buddy Draft Note"
        case .calendarDraft: return "Lil' Buddy Draft Event"
        case .calendarCreate: return "Request Approval"
        case .messageDraft: return "Lil' Buddy Draft Message"
        case .emailDraft: return "Lil' Buddy Draft Email"
        }
    }

    var receiptSummary: String {
        switch self {
        case .browserOpen:
            return "Lil' Buddy opened a guarded browser page."
        case .browserSummarize:
            return "Lil' Buddy prepared a review-safe page summary draft."
        case .memoryRemember:
            return "Lil' Buddy staged a memory write for Buddy review."
        case .noteDraft:
            return "Lil' Buddy prepared a note draft."
        case .calendarDraft:
            return "Lil' Buddy prepared a calendar draft without creating an event."
        case .calendarCreate:
            return "Lil' Buddy requested calendar creation and Buddy routed it through approval."
        case .messageDraft:
            return "Lil' Buddy prepared a message draft without sending."
        case .emailDraft:
            return "Lil' Buddy prepared an email draft without sending."
        }
    }
}

private enum BuddyActionStatus: String, Codable, Equatable {
    case draft
    case delegated
    case needsReview = "needs-review"
    case approved
    case running
    case completed
    case failed
    case cancelled
    case denied
}

private struct BuddyActionInputRef: Identifiable, Codable, Equatable {
    var id = UUID()
    var kind: String
    var label: String
    var value: String
    var redacted: Bool = false
}

private struct BuddyAction: Identifiable, Codable, Equatable {
    var id: UUID
    var schemaVersion: String
    var sessionId: UUID?
    var delegationId: UUID?
    var buddyId: String
    var title: String
    var intent: String
    var type: BuddyActionType
    var source: String
    var status: BuddyActionStatus
    var risk: BuddyRiskClass
    var requiresApproval: Bool
    var assignedAgentRole: BuddyAgentRole
    var createdAt: Date
    var updatedAt: Date?
    var inputRefs: [BuddyActionInputRef]
    var receiptId: String?

    static func draft(
        sessionId: UUID?,
        delegationId: UUID?,
        buddyId: String,
        title: String,
        intent: String,
        type: BuddyActionType,
        risk: BuddyRiskClass,
        currentURL: String
    ) -> BuddyAction {
        BuddyAction(
            id: UUID(),
            schemaVersion: buddyActionLoopSchemaVersion,
            sessionId: sessionId,
            delegationId: delegationId,
            buddyId: buddyId,
            title: title,
            intent: intent,
            type: type,
            source: "orchestrator",
            status: risk.requiresApproval ? .needsReview : .delegated,
            risk: risk,
            requiresApproval: risk.requiresApproval,
            assignedAgentRole: .worker,
            createdAt: Date(),
            updatedAt: nil,
            inputRefs: [
                BuddyActionInputRef(kind: "url", label: "current-page", value: currentURL)
            ],
            receiptId: nil
        )
    }
}

private struct BuddyReceipt: Identifiable, Codable, Equatable {
    var id: UUID
    var actionId: UUID
    var sessionId: UUID?
    var delegationId: UUID?
    var agentRole: BuddyAgentRole
    var createdAt: Date
    var status: BuddyActionStatus
    var title: String
    var summary: String
    var risk: BuddyRiskClass
    var redactions: [String]

    static func from(action: BuddyAction, status: BuddyActionStatus, summary: String) -> BuddyReceipt {
        BuddyReceipt(
            id: UUID(),
            actionId: action.id,
            sessionId: action.sessionId,
            delegationId: action.delegationId,
            agentRole: action.assignedAgentRole,
            createdAt: Date(),
            status: status,
            title: action.title,
            summary: summary,
            risk: action.risk,
            redactions: ["raw prompts", "tokens", "cookies", "private keys", "OAuth material"]
        )
    }
}

#Preview {
    BuddyAgentBrowserView()
}
