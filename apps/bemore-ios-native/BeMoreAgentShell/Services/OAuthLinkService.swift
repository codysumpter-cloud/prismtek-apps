import Foundation

struct OAuthLinkService {
    func authorizationURL(for provider: LinkedAccountProvider, stackConfig: StackConfig) -> URL? {
        provider.launchURL
    }
}
