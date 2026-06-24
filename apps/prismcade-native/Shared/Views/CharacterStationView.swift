import SwiftUI
import WebKit

struct CharacterStationView: View {
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        ZStack {
            LinearGradient(
                colors: [
                    Color(red: 0.04, green: 0.05, blue: 0.08),
                    Color(red: 0.08, green: 0.10, blue: 0.16),
                    Color(red: 0.03, green: 0.12, blue: 0.14)
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()

            VStack(spacing: 0) {
                HStack(spacing: 12) {
                    VStack(alignment: .leading, spacing: 2) {
                        Text("Character Creation Station")
                            .font(.system(size: 20, weight: .black, design: .rounded))
                        Text("Bundled Prismcade creator · no localhost required")
                            .font(.system(size: 11, weight: .heavy, design: .monospaced))
                            .foregroundStyle(Color(red: 0.45, green: 0.92, blue: 1.0))
                    }
                    Spacer()
                    Button("Close") { dismiss() }
                        .buttonStyle(.borderedProminent)
                        .tint(Color(red: 0.15, green: 0.75, blue: 0.85))
                }
                .padding(14)
                .background(Color.black.opacity(0.22))

                if let url = CharacterStationBundle.resourceURL {
                    CharacterStationWebView(url: url)
                        .background(Color.black.opacity(0.2))
                } else {
                    MissingCharacterStationView()
                }
            }
        }
        #if os(macOS)
        .frame(minWidth: 980, minHeight: 740)
        #endif
    }
}

private enum CharacterStationBundle {
    static var resourceURL: URL? {
        Bundle.main.url(forResource: "character-station", withExtension: "html", subdirectory: "Creator")
            ?? Bundle.main.url(forResource: "character-station", withExtension: "html")
            ?? Bundle.main.urls(forResourcesWithExtension: "html", subdirectory: nil)?.first(where: { $0.lastPathComponent == "character-station.html" })
    }
}

private struct MissingCharacterStationView: View {
    var body: some View {
        VStack(spacing: 10) {
            Image(systemName: "exclamationmark.triangle.fill")
                .font(.system(size: 42, weight: .bold))
                .foregroundStyle(Color(red: 1.0, green: 0.82, blue: 0.35))
            Text("Creator resource missing")
                .font(.system(size: 24, weight: .black, design: .rounded))
            Text("Expected Shared/Resources/Creator/character-station.html to be bundled in the Prismcade app target.")
                .font(.system(size: 13, weight: .medium, design: .rounded))
                .foregroundStyle(.white.opacity(0.7))
                .multilineTextAlignment(.center)
                .frame(maxWidth: 520)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .padding(28)
    }
}

#if os(macOS)
private struct CharacterStationWebView: NSViewRepresentable {
    let url: URL

    func makeNSView(context: Context) -> WKWebView {
        makeConfiguredWebView()
    }

    func updateNSView(_ webView: WKWebView, context: Context) {
        load(url, in: webView)
    }
}
#else
private struct CharacterStationWebView: UIViewRepresentable {
    let url: URL

    func makeUIView(context: Context) -> WKWebView {
        makeConfiguredWebView()
    }

    func updateUIView(_ webView: WKWebView, context: Context) {
        load(url, in: webView)
    }
}
#endif

private func makeConfiguredWebView() -> WKWebView {
    let configuration = WKWebViewConfiguration()
    configuration.defaultWebpagePreferences.allowsContentJavaScript = true

    let webView = WKWebView(frame: .zero, configuration: configuration)
    webView.allowsBackForwardNavigationGestures = false
    #if os(macOS)
    webView.setValue(false, forKey: "drawsBackground")
    #else
    webView.isOpaque = false
    webView.backgroundColor = .clear
    webView.scrollView.backgroundColor = .clear
    #endif
    return webView
}

private func load(_ url: URL, in webView: WKWebView) {
    guard webView.url != url else { return }
    webView.loadFileURL(url, allowingReadAccessTo: url.deletingLastPathComponent())
}
