import Foundation
import AuthenticationServices
import SwiftUI
import CryptoKit

// MARK: - OAuth Configuration

struct OAuthProviderConfig: Codable {
 let name: String
 let authorizationURL: String
 let tokenURL: String
 let scopes: [String]
 let clientId: String?
 let redirectURI: String
 let usePKCE: Bool
}

enum OAuthProvider {
 case github
 case chatgpt
 case pixelLab

 var config: OAuthProviderConfig {
 switch self {
 case .github:
 return OAuthProviderConfig(
 name: "GitHub",
 authorizationURL: "https://github.com/login/oauth/authorize",
 tokenURL: "https://github.com/login/oauth/access_token",
 scopes: ["repo", "read:user", "read:org"],
 clientId:nil, // Set via Build Config or environment
 redirectURI: "bemore://oauth/github",
 usePKCE: true
 )
 case .chatgpt:
 return OAuthProviderConfig(
 name: "ChatGPT/OpenAI",
 authorizationURL: "https://auth.openai.com/authorize",
 tokenURL: "https://auth.openai.com/token",
 scopes: ["openid", "profile", "email"],
 clientId: nil,
 redirectURI: "bemore://oauth/chatgpt",
 usePKCE: true
 )
 case .pixelLab:
 return OAuthProviderConfig(
 name: "PixelLab",
 authorizationURL: "https://pixellab.ai/oauth/authorize",
 tokenURL: "https://pixellab.ai/oauth/token",
 scopes: ["generate", "profile"],
 clientId: nil,
 redirectURI: "bemore://oauth/pixellab",
 usePKCE: true
 )
 }
 }

 var linkedAccountProvider: LinkedAccountProvider {
 switch self {
 case .github: return .github
 case .chatgpt: return .chatgpt
 case .pixelLab: return .pixelLab
 }
 }
}

// MARK: - PKCE Helper

struct PKCEParameters {
 let codeVerifier: String
 let codeChallenge: String
 let codeChallengeMethod: String = "S256"

 static func generate() -> PKCEParameters {
 let verifier = generateCodeVerifier()
 let challenge = generateCodeChallenge(verifier: verifier)
 return PKCEParameters(codeVerifier: verifier, codeChallenge: challenge)
 }

 private static func generateCodeVerifier() -> String {
 let characters = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789-._~"
 var result = ""
 for _ in 0..<128 {
 result.append(characters.randomElement()!)
 }
 return result
 }

 private static func generateCodeChallenge(verifier: String) -> String {
 guard let data = verifier.data(using: .utf8) else { return "" }
 let hash = SHA256.hash(data: data)
 let hashData = Data(hash.compactMap { $0 })
 return hashData.base64EncodedString()
 .replacingOccurrences(of: "+", with: "-")
 .replacingOccurrences(of: "/", with: "_")
 .replacingOccurrences(of: "=", with: "")
 }
}

// MARK: - OAuth Token Response

struct OAuthTokenResponse: Codable {
 let accessToken: String
 let tokenType: String
 let expiresIn: Int?
 let refreshToken: String?
 let scope: String?

 enum CodingKeys: String, CodingKey {
 case accessToken = "access_token"
 case tokenType = "token_type"
 case expiresIn = "expires_in"
 case refreshToken = "refresh_token"
 case scope
 }
}

// MARK: - OAuth Service

@MainActor
class OAuthService: NSObject, ObservableObject, ASWebAuthenticationPresentationContextProviding {
 static let shared = OAuthService()

 @Published var isAuthenticating = false
 @Published var lastError: String?

 private var currentSession: ASWebAuthenticationSession?
 private var pkceParameters: PKCEParameters?

 // MARK: - Public Methods

 /// Starts OAuth flow for a provider
 func authenticate(
 _ provider: OAuthProvider,
 completion: @escaping (Result<OAuthTokenResponse, OAuthError>) -> Void
 ) {
 guard !isAuthenticating else {
 completion(.failure(.alreadyInProgress))
 return
 }

 let config = provider.config

 // Generate PKCE parameters
 let pkce = PKCEParameters.generate()
 self.pkceParameters = pkce

 // Build authorization URL
 var components = URLComponents(string: config.authorizationURL)!
 components.queryItems = [
 URLQueryItem(name: "client_id", value: config.clientId ?? getClientId(for: provider)),
 URLQueryItem(name: "redirect_uri", value: config.redirectURI),
 URLQueryItem(name: "scope", value: config.scopes.joined(separator: " ")),
 URLQueryItem(name: "response_type", value: "code"),
 URLQueryItem(name: "state", value: generateState()),
 ]

 if config.usePKCE {
 components.queryItems?.append(URLQueryItem(name: "code_challenge", value: pkce.codeChallenge))
 components.queryItems?.append(URLQueryItem(name: "code_challenge_method", value: pkce.codeChallengeMethod))
 }

 guard let url = components.url else {
 completion(.failure(.invalidURL))
 return
 }

 isAuthenticating = true

 // Create web auth session
 let session = ASWebAuthenticationSession(
 url: url,
 callbackURLScheme: extractScheme(from: config.redirectURI)
 ) { [weak self] callbackURL, error in
 self?.isAuthenticating = false

 if let error = error {
 if (error as NSError).code == ASWebAuthenticationSessionError.canceledLogin.rawValue {
 completion(.failure(.canceledByUser))
 } else {
 completion(.failure(.webError(error.localizedDescription)))
 }
 return
 }

 guard let callbackURL = callbackURL else {
 completion(.failure(.noCallback))
 return
 }

 self?.handleCallback(callbackURL, for: provider, completion: completion)
 }

 session.presentationContextProvider = self
 session.prefersEphemeralWebBrowserSession = false

 currentSession = session
 session.start()
 }

 /// Cancel current authentication
 func cancel() {
 currentSession?.cancel()
 currentSession = nil
 isAuthenticating = false
 }

 // MARK: - ASWebAuthenticationPresentationContextProviding

 func presentationAnchor(for session: ASWebAuthenticationSession) -> ASPresentationAnchor {
 UIApplication.shared.connectedScenes
 .compactMap { $0 as? UIWindowScene }
 .first?.windows
 .first { $0.isKeyWindow } ?? UIWindow()
 }

 // MARK: - Private Methods

 private func handleCallback(
 _ url: URL,
 for provider: OAuthProvider,
 completion: @escaping (Result<OAuthTokenResponse, OAuthError>) -> Void
 ) {
 guard let components = URLComponents(url: url, resolvingAgainstBaseURL: true),
 let code = components.queryItems?.first(where: { $0.name == "code" })?.value else {
 completion(.failure(.noAuthCode))
 return
 }

 exchangeToken(code: code, for: provider, completion: completion)
 }

 private func exchangeToken(
 code: String,
 for provider: OAuthProvider,
 completion: @escaping (Result<OAuthTokenResponse, OAuthError>) -> Void
 ) {
 let config = provider.config

 var request = URLRequest(url: URL(string: config.tokenURL)!)
 request.httpMethod = "POST"
 request.setValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")

 var params: [String: String] = [
 "client_id": getClientId(for: provider),
 "code": code,
 "redirect_uri": config.redirectURI,
 "grant_type": "authorization_code"
 ]

 if let verifier = pkceParameters?.codeVerifier {
 params["code_verifier"] = verifier
 }

 // Add client_secret if configured
 if let secret = getClientSecret(for: provider) {
 params["client_secret"] = secret
 }

 request.httpBody = params
 .map { "\($0.key)=\($0.value.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? $0.value)" }
 .joined(separator: "&")
 .data(using: .utf8)

 URLSession.shared.dataTask(with: request) { data, response, error in
 DispatchQueue.main.async {
 if let error = error {
 completion(.failure(.networkError(error.localizedDescription)))
 return
 }

 guard let data = data else {
 completion(.failure(.noData))
 return
 }

 do {
 let tokenResponse = try JSONDecoder().decode(OAuthTokenResponse.self, from: data)
 completion(.success(tokenResponse))
 } catch {
 // Parse error message if present
 if let errorData = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
 let errorDescription = errorData["error_description"] as? String {
 completion(.failure(.tokenExchangeFailed(errorDescription)))
 } else {
 completion(.failure(.tokenExchangeFailed(error.localizedDescription)))
 }
 }
 }
 }.resume()
 }

 private func getClientId(for provider: OAuthProvider) -> String {
 // In production, load from Info.plist or environment
 switch provider {
 case .github:
 return Bundle.main.infoDictionary?["GITHUB_CLIENT_ID"] as? String ?? ""
 case .chatgpt:
 return Bundle.main.infoDictionary?["OPENAI_CLIENT_ID"] as? String ?? ""
 case .pixelLab:
 return Bundle.main.infoDictionary?["PIXELLAB_CLIENT_ID"] as? String ?? ""
 }
 }

 private func getClientSecret(for provider: OAuthProvider) -> String? {
 switch provider {
 case .github:
 return Bundle.main.infoDictionary?["GITHUB_CLIENT_SECRET"] as? String
 case .chatgpt:
 return Bundle.main.infoDictionary?["OPENAI_CLIENT_SECRET"] as? String
 case .pixelLab:
 return Bundle.main.infoDictionary?["PIXELLAB_CLIENT_SECRET"] as? String
 }
 }

 private func extractScheme(from redirectURI: String) -> String {
 guard let url = URL(string: redirectURI),
 let scheme = url.scheme else { return "" }
 return scheme
 }

 private func generateState() -> String {
 return UUID().uuidString
 }
}

// MARK: - Errors

enum OAuthError: Error {
 case alreadyInProgress
 case invalidURL
 case canceledByUser
 case webError(String)
 case noCallback
 case noAuthCode
 case tokenExchangeFailed(String)
 case networkError(String)
 case noData

 var localizedDescription: String {
 switch self {
 case .alreadyInProgress: return "Authentication already in progress"
 case .invalidURL: return "Invalid authentication URL"
 case .canceledByUser: return "Authentication canceled"
 case .webError(let msg): return "Web error: \(msg)"
 case .noCallback: return "No callback received"
 case .noAuthCode: return "No authorization code in callback"
 case .tokenExchangeFailed(let msg): return "Token exchange failed: \(msg)"
 case .networkError(let msg): return "Network error: \(msg)"
 case .noData: return "No data received from server"
 }
 }
}
