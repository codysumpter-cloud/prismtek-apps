
import SwiftUI
import SafariServices

actor WebBrowserService {
    static let shared = WebBrowserService()
    private init() {}

    func openURL(_ url: URL) {
        DispatchQueue.main.async {
            if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
               let rootVC = windowScene.windows.first?.rootViewController {
                let safariVC = SFSafariViewController(url: url)
                rootVC.present(safariVC, animated: true)
            }
        }
    }

    nonisolated func validateURL(_ urlString: String) -> URL? {
        return URL(string: urlString)
    }
}
