import SwiftUI
import AuthenticationServices

struct OAuthLinkView: View {
 let provider: LinkedAccountProvider
 let linkedAccountStore: LinkedAccountStore

 @State private var isAuthenticating = false
 @State private var errorMessage: String?
 @State private var showTokenFallback = false

 var body: some View {
 NavigationView {
 VStack(spacing: 24) {
 // Provider Icon
 Image(systemName: iconForProvider)
 .font(.system(size: 64))
 .foregroundColor(colorForProvider)

 // Title
 Text("Link \(provider.title)")
 .font(.title.bold())

 // Description
 Text(descriptionForProvider)
 .font(.body)
 .foregroundColor(.secondary)
 .multilineTextAlignment(.center)
 .padding(.horizontal)

 Spacer()

 // OAuth Button
 Button(action: startOAuth) {
 HStack {
 if isAuthenticating {
 ProgressView()
 .progressViewStyle(CircularProgressViewStyle(tint: .white))
 }
 Text(isAuthenticating ? "Connecting..." : "Connect with \(provider.title)")
 .font(.headline)
 }
 .frame(maxWidth: .infinity)
 .padding()
 .background(colorForProvider)
 .foregroundColor(.white)
 .cornerRadius(12)
 }
 .disabled(isAuthenticating)
 .padding(.horizontal)

 // Token Fallback
 Button("Use Access Token Instead") {
 showTokenFallback = true
 }
 .font(.subheadline)
 .foregroundColor(.secondary)

 if let error = errorMessage {
 Text(error)
 .font(.caption)
 .foregroundColor(.red)
 .padding()
 }
 }
 .navigationBarTitleDisplayMode(.inline)
 .navigationBarTitle("")
 }
 .sheet(isPresented: $showTokenFallback) {
 TokenEntryView(provider: provider, linkedAccountStore: linkedAccountStore)
 }
 }

 private func startOAuth() {
 guard let oauthProvider = oauthProviderForLinkedAccount(provider) else {
 errorMessage = "OAuth not configured for this provider"
 return
 }

 isAuthenticating = true
 errorMessage = nil

 OAuthService.shared.authenticate(oauthProvider) { result in
 isAuthenticating = false

 switch result {
 case .success(let tokenResponse):
 // Complete linking
 linkedAccountStore.completeLink(
 provider,
 accountHandle: nil, // Will be fetched from API
 accessToken: tokenResponse.accessToken,
 connectionMode: "oauth"
 )

 case .failure(let error):
 errorMessage = error.localizedDescription
 }
 }
 }

 private var iconForProvider: String {
 switch provider {
 case .github: return "alternative-logo"
 case .chatgpt: return "bolt.circle.fill"
 case .pixelLab: return "square.grid.2x2"
 }
 }

 private var colorForProvider: Color {
 switch provider {
 case .github: return Color(hex: "#24292e")
 case .chatgpt: return Color(hex: "#10a37f")
 case .pixelLab: return Color(hex: "#6366f1")
 }
 }

 private var descriptionForProvider: String {
 switch provider {
 case .github:
 return "Connect your GitHub account to access private repositories and perform actions on your behalf."
 case .chatgpt:
 return "Connect your ChatGPT/OpenAI account to use your subscription and preferences."
 case .pixelLab:
 return "Connect your PixelLab account to generate pixel art for your Buddy."
 }
 }

 private func oauthProviderForLinkedAccount(_ provider: LinkedAccountProvider) -> OAuthProvider? {
 switch provider {
 case .github: return .github
 case .chatgpt: return .chatgpt
 case .pixelLab: return .pixelLab
 }
 }
}

// MARK: - Token Fallback View

struct TokenEntryView: View {
 let provider: LinkedAccountProvider
 let linkedAccountStore: LinkedAccountStore
 @Environment(\.dismiss) private var dismiss

 @State private var accessToken = ""
 @State private var accountHandle = ""
 @State private var isValidating = false
 @State private var errorMessage: String?

 var body: some View {
 NavigationView {
 Form {
 Section("Account") {
 TextField(provider.accountPlaceholder, text: $accountHandle)
 SecureField("Access token", text: $accessToken)
 }

 Section {
 Text(provider.tokenHint)
 .font(.caption)
 .foregroundColor(.secondary)
 }

 if let error = errorMessage {
 Section {
 Text(error)
 .foregroundColor(.red)
 .font(.caption)
 }
 }
 }
 .navigationTitle("Enter Token")
 .navigationBarTitleDisplayMode(.inline)
 .toolbar {
 ToolbarItem(placement: .cancellationAction) {
 Button("Cancel") { dismiss() }
 }
 ToolbarItem(placement: .confirmationAction) {
 Button("Save") {
 saveToken()
 }
 .disabled(accessToken.isEmpty || isValidating)
 }
 }
 }
 }

 private func saveToken() {
 isValidating = true

 // Validate PixelLab token if applicable
 if provider == .pixelLab {
 Task {
 let (isValid, _) = await PixelLabService.shared.validateToken(accessToken)
 await MainActor.run {
 isValidating = false
 if !isValid {
 errorMessage = "Token validation failed"
 return
 }
 completeLink()
 }
 }
 } else {
 completeLink()
 }
 }

 private func completeLink() {
 linkedAccountStore.completeLink(
 provider,
 accountHandle: accountHandle,
 accessToken: accessToken,
 connectionMode: "token"
 )
 dismiss()
 }
}

// MARK: - Color Extension

extension Color {
 init(hex: String) {
 let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
 var int: UInt64 = 0
 Scanner(string: hex).scanHexInt64(&int)
 let a, r, g, b: UInt64
 switch hex.count {
 case 3: // RGB (12-bit)
 (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
 case 6: // RGB (24-bit)
 (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
 case 8: // ARGB (32-bit)
 (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
 default:
 (a, r, g, b) = (1, 1, 1, 0)
 }

 self.init(
 .sRGB,
 red: Double(r) / 255,
 green: Double(g) / 255,
 blue: Double(b) / 255,
 opacity: Double(a) / 255
 )
 }
}
