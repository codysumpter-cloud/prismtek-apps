import SwiftUI
import WebKit

struct BuddyAgentBrowserView: View {
    @State private var addressText = "https://www.google.com/search?q=Prismtek+Buddy+agent"
    @State private var currentURL = URL(string: "https://www.google.com/search?q=Prismtek+Buddy+agent")!
    @State private var pendingTool: BuddyAgentToolDraft?
    @State private var receipts: [BuddyAgentReceipt] = []

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                header
                toolRail
                Divider().overlay(BMOTheme.divider)
                BuddyWebView(url: currentURL)
                    .overlay(alignment: .bottom) {
                        if let pendingTool {
                            pendingToolCard(pendingTool)
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
                    Text("Buddy can research, prepare actions, and ask before touching phone tools.")
                        .foregroundColor(BMOTheme.textSecondary)
                        .font(.caption)
                }
                Spacer()
                StatusBadge(label: "User-approved", color: BMOTheme.success)
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
                toolButton(
                    title: "Summarize Page",
                    icon: "doc.text.magnifyingglass",
                    risk: "low"
                ) {
                    pendingTool = BuddyAgentToolDraft(
                        title: "Summarize current page",
                        risk: .low,
                        summary: "Buddy will prepare a page summary from the visible browser context when the runtime/browser extraction bridge is connected.",
                        confirmationLabel: "Save Summary Draft"
                    )
                }

                toolButton(
                    title: "Save to Memory",
                    icon: "brain.head.profile",
                    risk: "low"
                ) {
                    pendingTool = BuddyAgentToolDraft(
                        title: "Save page to Buddy memory",
                        risk: .low,
                        summary: "Buddy will save the current page URL and your note as a memory receipt. No external write happens without approval.",
                        confirmationLabel: "Save Memory Receipt"
                    )
                }

                toolButton(
                    title: "Calendar Draft",
                    icon: "calendar.badge.plus",
                    risk: "medium"
                ) {
                    pendingTool = BuddyAgentToolDraft(
                        title: "Prepare calendar event",
                        risk: .medium,
                        summary: "Buddy can draft a calendar event from the page or chat context. The event should be reviewed before EventKit creation is enabled.",
                        confirmationLabel: "Prepare Event Draft"
                    )
                }

                toolButton(
                    title: "Message Draft",
                    icon: "message.badge.waveform",
                    risk: "high"
                ) {
                    pendingTool = BuddyAgentToolDraft(
                        title: "Prepare message draft",
                        risk: .high,
                        summary: "Buddy can draft a message, but sending must stay user-reviewed through the system compose sheet or Messages handoff.",
                        confirmationLabel: "Prepare Message Draft"
                    )
                }
            }
            .padding(.horizontal, BMOTheme.spacingMD)
            .padding(.vertical, BMOTheme.spacingSM)
        }
        .background(BMOTheme.backgroundSecondary)
    }

    private func toolButton(title: String, icon: String, risk: String, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            HStack(spacing: 8) {
                Image(systemName: icon)
                VStack(alignment: .leading, spacing: 1) {
                    Text(title)
                        .font(.caption.weight(.semibold))
                    Text("risk: \(risk)")
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

    private func pendingToolCard(_ draft: BuddyAgentToolDraft) -> some View {
        VStack(alignment: .leading, spacing: BMOTheme.spacingSM) {
            HStack {
                Label(draft.title, systemImage: draft.risk.systemImage)
                    .foregroundColor(BMOTheme.textPrimary)
                    .font(.headline)
                Spacer()
                StatusBadge(label: draft.risk.label, color: draft.risk.color)
            }

            Text(draft.summary)
                .foregroundColor(BMOTheme.textSecondary)
                .font(.subheadline)
                .fixedSize(horizontal: false, vertical: true)

            Text("Current page: \(currentURL.absoluteString)")
                .foregroundColor(BMOTheme.textTertiary)
                .font(.caption)
                .lineLimit(2)

            HStack {
                Button("Cancel") {
                    pendingTool = nil
                }
                .buttonStyle(.bordered)

                Spacer()

                Button(draft.confirmationLabel) {
                    receipts.insert(
                        BuddyAgentReceipt(
                            toolTitle: draft.title,
                            url: currentURL.absoluteString,
                            risk: draft.risk.label,
                            createdAt: Date()
                        ),
                        at: 0
                    )
                    pendingTool = nil
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

private struct BuddyAgentToolDraft: Identifiable, Equatable {
    let id = UUID()
    let title: String
    let risk: BuddyAgentRisk
    let summary: String
    let confirmationLabel: String
}

private struct BuddyAgentReceipt: Identifiable, Codable, Equatable {
    let id = UUID()
    let toolTitle: String
    let url: String
    let risk: String
    let createdAt: Date
}

private enum BuddyAgentRisk: String, Equatable {
    case low
    case medium
    case high

    var label: String {
        switch self {
        case .low: return "low risk"
        case .medium: return "review"
        case .high: return "confirm"
        }
    }

    var systemImage: String {
        switch self {
        case .low: return "checkmark.shield.fill"
        case .medium: return "exclamationmark.shield.fill"
        case .high: return "lock.shield.fill"
        }
    }

    var color: Color {
        switch self {
        case .low: return BMOTheme.success
        case .medium: return BMOTheme.warning
        case .high: return BMOTheme.error
        }
    }
}

#Preview {
    BuddyAgentBrowserView()
}