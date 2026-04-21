import XCTest
@testable import BeMoreAgent

final class LinkedAccountFlowTests: XCTestCase {
    func testOAuthLinkServiceRoutesProvidersToRelevantAccountPages() {
        let service = OAuthLinkService()

        XCTAssertEqual(service.authorizationURL(for: .github, stackConfig: .default)?.absoluteString, "https://github.com/settings/personal-access-tokens/new")
        XCTAssertEqual(service.authorizationURL(for: .chatgpt, stackConfig: .default)?.absoluteString, "https://platform.openai.com/api-keys")
        XCTAssertEqual(service.authorizationURL(for: .pixelLab, stackConfig: .default)?.absoluteString, "https://pixellab.ai/")
    }
}
