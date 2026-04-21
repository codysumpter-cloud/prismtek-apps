import Foundation

struct OAuthLinkService {
    func authorizationURL(for provider: LinkedAccountProvider, stackConfig: StackConfig) -> URL? {
        switch provider {
        case .github:
            return URL(string: "https://github.com/settings/personal-access-tokens/new")
        case .chatgpt:
            return URL(string: "https://platform.openai.com/api-keys")
        case .pixelLab:
            return URL(string: "https://pixellab.ai/")
        }
    }
}
