import Foundation

enum PixelLabClientError: Error {
    case invalidResponse
    case requestFailed(Int, String?)
    case missingPreview
    case decodeFailure(String?)
}

struct PixelLabPalettePayload: Codable, Hashable {
    var primary: String
    var secondary: String
    var accent: String
    var outline: String
    var background: String?

    static func make(for paletteID: String) -> PixelLabPalettePayload {
        switch paletteID {
        case "rose_white":
            return .init(primary: "#F28CB1", secondary: "#FFF5FA", accent: "#B8336A", outline: "#6B2447", background: nil)
        case "sky_navy":
            return .init(primary: "#7CC6FE", secondary: "#D9F0FF", accent: "#1D3557", outline: "#89C2D9", background: nil)
        case "aqua_teal":
            return .init(primary: "#72F1E8", secondary: "#C8FFF4", accent: "#008080", outline: "#114B5F", background: nil)
        case "forest_moss":
            return .init(primary: "#2F6B3D", secondary: "#8BAE5A", accent: "#D8F3DC", outline: "#344E41", background: nil)
        case "peach_brown":
            return .init(primary: "#FFC6A5", secondary: "#FFF1E6", accent: "#B5654A", outline: "#7A5230", background: nil)
        case "yellow_cocoa":
            return .init(primary: "#F4D35E", secondary: "#FFF6CC", accent: "#B08900", outline: "#6F4E37", background: nil)
        case "purple_gold":
            return .init(primary: "#8D6BFF", secondary: "#E6C15A", accent: "#3C096C", outline: "#FFD166", background: nil)
        case "black_neon":
            return .init(primary: "#111111", secondary: "#39FF88", accent: "#00E5FF", outline: "#F5F749", background: nil)
        case "red_charcoal":
            return .init(primary: "#D1495B", secondary: "#2B2D42", accent: "#F2CC8F", outline: "#8D99AE", background: nil)
        default:
            return .init(primary: "#8FD9C8", secondary: "#FFF8E7", accent: "#2B7A78", outline: "#17252A", background: nil)
        }
    }
}

struct PixelLabGenerateRequest: Codable, Hashable {
    var description: String
    var width: Int
    var height: Int
    var model: String
    var palette: PixelLabPalettePayload
    var transparentBackground: Bool
    var format: String

    enum CodingKeys: String, CodingKey {
        case description
        case width
        case height
        case model
        case palette
        case transparentBackground = "transparent_background"
        case format
    }
}

struct PixelLabGenerateResponse: Hashable {
    var previewURL: URL?
    var imageData: Data?
    var responseSnippet: String?

    init(data: Data) throws {
        responseSnippet = String(data: data.prefix(300), encoding: .utf8)
        let object = try JSONSerialization.jsonObject(with: data)
        previewURL = Self.findURL(in: object)
        imageData = Self.findImageData(in: object)

        if previewURL == nil, imageData == nil {
            throw PixelLabClientError.decodeFailure(responseSnippet)
        }
    }

    private static func findURL(in value: Any) -> URL? {
        if let dictionary = value as? [String: Any] {
            for key in ["preview_url", "previewUrl", "image_url", "imageUrl", "url"] {
                if let raw = dictionary[key] as? String,
                   let url = URL(string: raw),
                   raw.isEmpty == false {
                    return url
                }
            }
            for child in dictionary.values {
                if let found = findURL(in: child) {
                    return found
                }
            }
        }
        if let array = value as? [Any] {
            for child in array {
                if let found = findURL(in: child) {
                    return found
                }
            }
        }
        return nil
    }

    private static func findImageData(in value: Any) -> Data? {
        if let dictionary = value as? [String: Any] {
            for key in ["image", "image_base64", "imageBase64", "png_base64", "pngBase64", "preview_image"] {
                if let raw = dictionary[key] as? String,
                   let data = Data(base64Encoded: raw),
                   raw.isEmpty == false {
                    return data
                }
            }
            for child in dictionary.values {
                if let found = findImageData(in: child) {
                    return found
                }
            }
        }
        if let array = value as? [Any] {
            for child in array {
                if let found = findImageData(in: child) {
                    return found
                }
            }
        }
        return nil
    }
}

struct PixelLabClient {
    var session: URLSession = .shared
    var baseURL: URL = URL(string: "https://api.pixellab.ai")!

    func generatePreview(
        spec: BuddyAppearancePreviewSpec,
        accessToken: String
    ) async throws -> PixelLabGenerateResponse {
        let requestBody = PixelLabGenerateRequest(
            description: BuddyAppearanceRenderContract.pixelDescription(for: spec),
            width: 48,
            height: 48,
            model: "bitforge",
            palette: .make(for: spec.paletteID),
            transparentBackground: true,
            format: "png"
        )

        var request = URLRequest(url: baseURL.appendingPathComponent("generate"))
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("application/json", forHTTPHeaderField: "Accept")
        request.setValue("Bearer \(accessToken)", forHTTPHeaderField: "Authorization")
        request.httpBody = try JSONEncoder().encode(requestBody)

        let (data, response) = try await session.data(for: request)
        guard let httpResponse = response as? HTTPURLResponse else {
            throw PixelLabClientError.invalidResponse
        }
        guard (200...299).contains(httpResponse.statusCode) else {
            throw PixelLabClientError.requestFailed(httpResponse.statusCode, String(data: data.prefix(300), encoding: .utf8))
        }
        return try PixelLabGenerateResponse(data: data)
    }

    func downloadImage(from url: URL) async throws -> Data {
        let (data, response) = try await session.data(from: url)
        guard let httpResponse = response as? HTTPURLResponse,
              (200...299).contains(httpResponse.statusCode) else {
            throw PixelLabClientError.requestFailed((response as? HTTPURLResponse)?.statusCode ?? 0, nil)
        }
        return data
    }

    func validateToken(_ token: String) async -> Bool {
        let spec = BuddyAppearanceRenderContract.makePreviewSpec(
            buddyName: "Buddy",
            archetypeID: "pixel_pet",
            paletteID: "mint_cream",
            asciiVariantID: "starter_a",
            expressionTone: "friendly",
            accentLabel: "preview",
            renderStyle: .pixel
        )

        do {
            _ = try await generatePreview(spec: spec, accessToken: token)
            return true
        } catch let PixelLabClientError.requestFailed(status, _) {
            return status != 401 && status != 403
        } catch {
            return false
        }
    }
}
