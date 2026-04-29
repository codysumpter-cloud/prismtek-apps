import AppKit
import SwiftUI

struct HermesMacCommandCenterView: View {
    private let localWebUI = URL(string: "http://127.0.0.1:8787")!
    private let gatewayAPI = URL(string: "http://127.0.0.1:8642")!
    private let hermesWebUIFork = URL(string: "https://github.com/codysumpter-cloud/hermes-webui")!
    private let hermesDesktopFork = URL(string: "https://github.com/codysumpter-cloud/hermes-desktop")!

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            header
            HStack(alignment: .top, spacing: 14) {
                VStack(alignment: .leading, spacing: 14) {
                    launchPanel
                    commandPanel
                }
                .frame(maxWidth: .infinity, alignment: .leading)

                VStack(alignment: .leading, spacing: 14) {
                    boundaryPanel
                    desktopConceptPanel
                }
                .frame(width: 320, alignment: .topLeading)
            }
        }
        .padding()
        .background(Color.white.opacity(0.72))
        .clipShape(RoundedRectangle(cornerRadius: 18))
        .shadow(color: .black.opacity(0.06), radius: 18, y: 8)
    }

    private var header: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Hermes Command Center")
                .font(.title2.bold())
            Text("Borrow the best ideas from Hermes WebUI and Hermes Desktop — install guidance, local runtime launch, profiles, sessions, skills, schedules, gateways, memory, and logs — while keeping BeMore Mac native SwiftUI.")
                .foregroundStyle(.secondary)
        }
    }

    private var launchPanel: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Launch surfaces")
                .font(.headline)
            HStack(spacing: 10) {
                Button("Open WebUI") {
                    NSWorkspace.shared.open(localWebUI)
                }
                .buttonStyle(.borderedProminent)

                Button("Open Gateway API") {
                    NSWorkspace.shared.open(gatewayAPI)
                }
                .buttonStyle(.bordered)

                Button("WebUI fork") {
                    NSWorkspace.shared.open(hermesWebUIFork)
                }
                .buttonStyle(.bordered)
            }
            Text("Default local WebUI: http://127.0.0.1:8787")
                .font(.caption.monospaced())
                .foregroundStyle(.secondary)
        }
        .padding()
        .background(Color.white.opacity(0.86))
        .clipShape(RoundedRectangle(cornerRadius: 14))
    }

    private var commandPanel: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Local start command")
                .font(.headline)
            Text("git clone https://github.com/codysumpter-cloud/hermes-webui.git hermes-webui\ncd hermes-webui\npython3 bootstrap.py")
                .font(.caption.monospaced())
                .textSelection(.enabled)
                .padding(12)
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(Color.black.opacity(0.08))
                .clipShape(RoundedRectangle(cornerRadius: 10))
            Text("Hermes WebUI auto-detects Hermes Agent, Python, state directory, workspace, and port. BeMore Mac links to the local UI instead of embedding a live agent session inside the app.")
                .foregroundStyle(.secondary)
        }
        .padding()
        .background(Color.white.opacity(0.86))
        .clipShape(RoundedRectangle(cornerRadius: 14))
    }

    private var boundaryPanel: some View {
        VStack(alignment: .leading, spacing: 10) {
            Label("Security boundary", systemImage: "lock.shield.fill")
                .font(.headline)
            Text("Keep Hermes local, tunneled, or private-network reachable. Use SSH tunneling, Tailscale, and HERMES_WEBUI_PASSWORD when the UI is reachable beyond localhost.")
                .font(.subheadline)
                .foregroundStyle(.secondary)
            VStack(alignment: .leading, spacing: 6) {
                Text("127.0.0.1 default bind")
                Text("8787 WebUI")
                Text("8642 gateway API")
                Text("~/.hermes state")
            }
            .font(.caption.monospaced())
            .foregroundStyle(.secondary)
        }
        .padding()
        .background(Color.white.opacity(0.86))
        .clipShape(RoundedRectangle(cornerRadius: 14))
    }

    private var desktopConceptPanel: some View {
        VStack(alignment: .leading, spacing: 10) {
            Label("Desktop upgrade", systemImage: "desktopcomputer")
                .font(.headline)
            Text("Hermes Desktop is Electron + React. BeMore Mac should not paste that stack into SwiftUI; it should adopt the product shape: guided setup, sessions, profiles, memory, skills, tools, schedules, gateways, backups, and logs.")
                .font(.subheadline)
                .foregroundStyle(.secondary)
            Button("Open Desktop fork") {
                NSWorkspace.shared.open(hermesDesktopFork)
            }
            .buttonStyle(.bordered)
        }
        .padding()
        .background(Color.white.opacity(0.86))
        .clipShape(RoundedRectangle(cornerRadius: 14))
    }
}
