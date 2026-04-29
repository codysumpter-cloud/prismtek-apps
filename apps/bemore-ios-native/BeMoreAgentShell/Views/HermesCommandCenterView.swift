import SwiftUI

struct HermesCommandCenterView: View {
    private let localWebUI = URL(string: "http://127.0.0.1:8787")!
    private let hermesWebUIFork = URL(string: "https://github.com/codysumpter-cloud/hermes-webui")!
    private let hermesDesktopFork = URL(string: "https://github.com/codysumpter-cloud/hermes-desktop")!

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: BMOTheme.spacingLG) {
                    hero
                    safetyBoundary
                    capabilityGrid
                    launchSteps
                    desktopUpgrade
                }
                .padding(BMOTheme.spacingMD)
            }
            .background(BMOTheme.backgroundPrimary)
            .navigationTitle("Hermes")
            .toolbarBackground(BMOTheme.backgroundPrimary, for: .navigationBar)
            .toolbarBackground(.visible, for: .navigationBar)
        }
    }

    private var hero: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Hermes Command Center")
                .font(.largeTitle.bold())
                .foregroundColor(BMOTheme.textPrimary)
            Text("Use Hermes WebUI and Hermes Desktop as Prismtek's operator-grade companion surfaces without exposing a private agent runtime publicly.")
                .font(.body)
                .foregroundColor(BMOTheme.textSecondary)
            HStack(spacing: 10) {
                Link(destination: localWebUI) {
                    Label("Open local WebUI", systemImage: "safari.fill")
                }
                .buttonStyle(BMOButtonStyle(isPrimary: true))

                Link(destination: hermesWebUIFork) {
                    Label("WebUI fork", systemImage: "chevron.left.forwardslash.chevron.right")
                }
                .buttonStyle(BMOButtonStyle(isPrimary: false))
            }
        }
        .bmoCard()
    }

    private var safetyBoundary: some View {
        VStack(alignment: .leading, spacing: 10) {
            Label("Runtime boundary", systemImage: "lock.shield.fill")
                .font(.headline)
                .foregroundColor(BMOTheme.textPrimary)
            Text("Hermes should stay local, tunneled, or private-network reachable. Do not publish a live Hermes agent session as an unauthenticated public web route.")
                .foregroundColor(BMOTheme.textSecondary)
            VStack(alignment: .leading, spacing: 6) {
                Text("Default WebUI: http://127.0.0.1:8787")
                Text("Remote access: SSH tunnel or Tailscale")
                Text("Public exposure: require password auth and private-network controls")
            }
            .font(.caption.monospaced())
            .foregroundColor(BMOTheme.textTertiary)
        }
        .bmoCard()
    }

    private var capabilityGrid: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Borrowed from Hermes")
                .font(.title2.bold())
                .foregroundColor(BMOTheme.textPrimary)
            LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 12) {
                capability("Sessions", "Resume CLI/WebUI sessions and keep project context visible.", "clock.arrow.circlepath")
                capability("Workspace", "Browse, preview, edit, and download workspace files.", "folder.fill")
                capability("Profiles", "Switch provider configs and local model endpoints by profile.", "person.2.fill")
                capability("Skills", "Review reusable procedures, memory, tools, and scheduled jobs.", "wand.and.stars")
            }
        }
    }

    private var launchSteps: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("Local launch")
                .font(.title2.bold())
                .foregroundColor(BMOTheme.textPrimary)
            Text("From your machine or server:")
                .foregroundColor(BMOTheme.textSecondary)
            Text("git clone https://github.com/codysumpter-cloud/hermes-webui.git hermes-webui\ncd hermes-webui\npython3 bootstrap.py")
                .font(.caption.monospaced())
                .foregroundColor(BMOTheme.textPrimary)
                .textSelection(.enabled)
                .padding(12)
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(BMOTheme.backgroundCard)
                .clipShape(RoundedRectangle(cornerRadius: BMOTheme.radiusMedium, style: .continuous))
        }
        .bmoCard()
    }

    private var desktopUpgrade: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("Desktop upgrade path")
                .font(.title2.bold())
                .foregroundColor(BMOTheme.textPrimary)
            Text("Hermes Desktop is an Electron app for installing, configuring, and chatting with Hermes Agent. BeMore keeps the native iOS/macOS app shell, but adopts the same command-center concepts: install guidance, provider setup, sessions, profiles, memory, skills, schedules, gateways, and logs.")
                .foregroundColor(BMOTheme.textSecondary)
            Link(destination: hermesDesktopFork) {
                Label("Open Hermes Desktop fork", systemImage: "desktopcomputer")
            }
            .buttonStyle(BMOButtonStyle(isPrimary: false))
        }
        .bmoCard()
    }

    private func capability(_ title: String, _ body: String, _ icon: String) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Image(systemName: icon)
                .foregroundColor(BMOTheme.accent)
            Text(title)
                .font(.headline)
                .foregroundColor(BMOTheme.textPrimary)
            Text(body)
                .font(.caption)
                .foregroundColor(BMOTheme.textSecondary)
        }
        .padding(12)
        .frame(maxWidth: .infinity, minHeight: 132, alignment: .topLeading)
        .background(BMOTheme.backgroundCard)
        .clipShape(RoundedRectangle(cornerRadius: BMOTheme.radiusMedium, style: .continuous))
    }
}
