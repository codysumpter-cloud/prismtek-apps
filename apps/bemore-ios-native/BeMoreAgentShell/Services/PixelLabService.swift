import Foundation

enum PixelLabError: Error {
    case requestFailed(Int, String?)
    case decodingError
    case noToken
    case missingImageData
}

@MainActor
public final class PixelLabService: ObservableObject {
    public static let shared = PixelLabService()

    @Published public var isLoading = false
    @Published public var lastError: String?

    private let client = PixelLabClient()

    private init() {}

    func generatePixelArt(
        prompt: String,
        width: Int = 64,
        height: Int = 64,
        style: String = "pixelart",
        accessToken: String? = nil
    ) async throws -> Data {
        guard let token = accessToken?.trimmingCharacters(in: .whitespacesAndNewlines), !token.isEmpty else {
            throw PixelLabError.noToken
        }

        let spec = BuddyAppearanceRenderContract.makePreviewSpec(
            buddyName: "Buddy",
            archetypeID: style == "retro" ? "pixel_pet" : "console_pet",
            paletteID: "mint_cream",
            asciiVariantID: "starter_a",
            expressionTone: "friendly",
            accentLabel: prompt,
            renderStyle: .pixel,
            customization: BuddyAppearanceRenderContract.defaultCustomization(for: style == "retro" ? "pixel_pet" : "console_pet")
        )

        do {
            let response = try await client.generatePreview(spec: spec, accessToken: token)
            if let data = response.imageData {
                return data
            }
            if let url = response.previewURL {
                return try await client.downloadImage(from: url)
            }
            throw PixelLabError.missingImageData
        } catch let PixelLabClientError.requestFailed(status, message) {
            throw PixelLabError.requestFailed(status, message)
        } catch let PixelLabClientError.decodeFailure(message) {
            throw PixelLabError.requestFailed(200, message)
        } catch {
            throw PixelLabError.decodingError
        }
    }

    func checkAccountStatus(accessToken: String? = nil) async throws -> (creditsRemaining: Int?, status: String) {
        guard let token = accessToken?.trimmingCharacters(in: .whitespacesAndNewlines), !token.isEmpty else {
            throw PixelLabError.noToken
        }

        let isValid = await client.validateToken(token)
        return (nil, isValid ? "active" : "invalid")
    }

    func validateToken(_ token: String) async -> (isValid: Bool, handle: String?) {
        let trimmed = token.trimmingCharacters(in: .whitespacesAndNewlines)
        guard trimmed.isEmpty == false else { return (false, nil) }
        return (await client.validateToken(trimmed), nil)
    }
}
