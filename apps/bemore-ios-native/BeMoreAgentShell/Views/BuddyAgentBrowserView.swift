import SwiftUI
import WebKit

private let buddyActionLoopSchemaVersion = "2026-06-02.buddy-action.v1"

struct BuddyAgentBrowserView: View {
    @State private var addressText = "https://www.google.com/search?q=Prismtek+Buddy+agent"
    @State private var currentURL = URL(string: "https://www.google.com/search?q=Prismtek+Buddy+agent")!
    @State private var pendingAction: BuddyAction?
    @State private var receipts: [BuddyReceipt] = []

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                header
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
                    Text("Guarded Agent Browser")
                        .foregroundColor(BMOTheme.textPrimary)
                        .font(.headline)
                    Text("Buddy creates typed action drafts, asks before risky tools, and leaves receipts.")
                        .foregroundColor(BMOTheme.textSecondary)
                        .font(.caption)
                }
                Spacer()
                StatusBadge(label: "Action Loop v1", color: BMOTheme.success)
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

    private var toolRail: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: BMOTheme.spacingSM) {
                actionButton(
                    title: "Summarize Page",
                    icon: "doc.text.magnifyingglass",
                    type: .browserSummarize,
                    risk: .readOnly,
                    intent: "Prepare a concise summary from the currently loaded browser page."
                )

                actionButton(
                    title: "Save Memory",
                    icon: "brain.head.profile",
                    type: .memoryRemember,
                    risk: .draftOnly,
                    intent: "Save the current page URL and a user-reviewed note to Buddy memory."
                )

                actionButton(
                    title: "Note Draft",
                    icon: "note.text.badge.plus",
                    type: .noteDraft,
                    risk: .draftOnly,
                    intent: "Prepare a reusable note draft from this page or task context."
                )

                actionButton(
                    title: "Calendar Draft",
                    icon: "calendar.badge.plus",
                    type: .calendarDraft,
                    risk: .draftOnly,
                    intent: "Prepare a calendar event draft. EventKit creation remains a later approval step."
                )

                actionButton(
                    title: "Message Draft",
                    icon: "message.badge.waveform",
                    type: .messageDraft,
                    risk: .draftOnly,
                    intent: "Prepare a message draft. Sending remains user-reviewed."
                )

                actionButton(
                    title: "Email Draft",
                    icon: "envelope.badge.fill",
                    type: .emailDraft,
                    risk: .draftOnly,
                    intent: "Prepare an email draft. Sending remains user-reviewed."
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
                        ForEach(Array(receipts.prefix(5))) { receipt in
                            VStack(alignment: .leading, spacing: 4) {
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
                            .frame(width: 180, alignment: .leading)
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
            pendingAction = BuddyAction.draft(
                buddyId: "default",
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
                Text("Action type: \(action.type.rawValue)")
                Text("Approval: \(action.requiresApproval ? "required" : "review-safe draft")")
                Text("Current page: \(currentURL.absoluteString)")
                    .lineLimit(2)
            }
            .foregroundColor(BMOTheme.textTertiary)
            .font(.caption)

            HStack {
                Button("Cancel") {
                    let receipt = BuddyReceipt.from(
                        action: action,
                        status: .cancelled,
                        summary: "User cancelled the action draft before execution."
                    )
                    receipts.insert(receipt, at: 0)
                    pendingAction = nil
                }
                .buttonStyle(.bordered)

                Spacer()

                Button(action.type.confirmationLabel) {
                    let receipt = BuddyReceipt.from(
                        action: action,
                        status: .completed,
                        summary: action.type.receiptSummary
                    )
                    receipts.insert(receipt, at: 0)
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
    case messageDraft = "message.draft"
    case emailDraft = "email.draft"

    var confirmationLabel: String {
        switch self {
        case .browserOpen: return "Open Page"
        case .browserSummarize: return "Save Summary Draft"
        case .memoryRemember: return "Save Memory Receipt"
        case .noteDraft: return "Prepare Note Draft"
        case .calendarDraft: return "Prepare Event Draft"
        case .messageDraft: return "Prepare Message Draft"
        case .emailDraft: return "Prepare Email Draft"
        }
    }

    var receiptSummary: String {
        switch self {
        case .browserOpen:
            return "Buddy opened a guarded browser page."
        case .browserSummarize:
            return "Buddy prepared a review-safe page summary draft."
        case .memoryRemember:
            return "Buddy staged a memory write for user review."
        case .noteDraft:
            return "Buddy prepared a note draft."
        case .calendarDraft:
            return "Buddy prepared a calendar draft without creating an event."
        case .messageDraft:
            return "Buddy prepared a message draft without sending."
        case .emailDraft:
            return "Buddy prepared an email draft without sending."
        }
    }
}

private enum BuddyActionStatus: String, Codable, Equatable {
    case draft
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
    var buddyId: String
    var title: String
    var intent: String
    var type: BuddyActionType
    var source: String
    var status: BuddyActionStatus
    var risk: BuddyRiskClass
    var requiresApproval: Bool
    var createdAt: Date
    var updatedAt: Date?
    var inputRefs: [BuddyActionInputRef]
    var receiptId: String?

    static func draft(
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
            buddyId: buddyId,
            title: title,
            intent: intent,
            type: type,
            source: "agent-tab",
            status: .draft,
            risk: risk,
            requiresApproval: risk.requiresApproval,
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
