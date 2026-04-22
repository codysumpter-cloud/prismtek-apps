import XCTest
@testable import BeMoreAgent

final class BuddyAppearanceStudioTests: XCTestCase {
    override func setUp() {
        super.setUp()
        let root = FileManager.default.temporaryDirectory.appendingPathComponent(UUID().uuidString, isDirectory: true)
        try? FileManager.default.createDirectory(at: root, withIntermediateDirectories: true)
        let appSupport = root.appendingPathComponent("ApplicationSupport", isDirectory: true)
        let documents = root.appendingPathComponent("Documents", isDirectory: true)
        try? FileManager.default.createDirectory(at: appSupport, withIntermediateDirectories: true)
        try? FileManager.default.createDirectory(at: documents, withIntermediateDirectories: true)
        Paths.applicationSupportOverride = appSupport
        Paths.documentsOverride = documents
        MockPixelLabURLProtocol.reset()
        PixelLabPreviewService.client = PixelLabClient(session: mockSession, baseURL: URL(string: "https://example.test")!)
    }

    override func tearDown() {
        PixelLabPreviewService.client = PixelLabClient()
        Paths.applicationSupportOverride = nil
        Paths.documentsOverride = nil
        MockPixelLabURLProtocol.reset()
        super.tearDown()
    }

    func testAsciiDinoUsesDistinctDinoFrames() {
        let frames = BuddyAsciiRenderer.frames(archetypeID: "dino", mood: .idle, expressionTone: "friendly", asciiVariantID: "starter_a")
        XCTAssertEqual(frames.count, 3)
        XCTAssertTrue(frames.joined(separator: "\n").contains("_/{"))
        XCTAssertTrue(frames.joined(separator: "\n").contains(">"))
        XCTAssertFalse(frames.joined(separator: "\n").localizedCaseInsensitiveContains("rawr"))
    }

    func testAsciiCatUsesCatSpecificSilhouette() {
        let frames = BuddyAsciiRenderer.frames(archetypeID: "cat_like", mood: .idle, expressionTone: "friendly", asciiVariantID: "starter_a")
        XCTAssertTrue(frames.joined(separator: "\n").contains("/\\\\_/\\\\"))
        XCTAssertFalse(frames.joined(separator: "\n").contains("|_____|"))
    }

    func testPixelLabRequestIncludesArchetypeSpecificPrompt() async throws {
        MockPixelLabURLProtocol.handler = { request in
            let body = try XCTUnwrap(request.httpBody)
            let payload = try JSONDecoder().decode(PixelLabGenerateRequest.self, from: body)
            XCTAssertEqual(payload.width, 48)
            XCTAssertEqual(payload.height, 48)
            XCTAssertTrue(payload.transparentBackground)
            XCTAssertTrue(payload.description.contains("pixel dinosaur buddy"))

            let response = HTTPURLResponse(url: try XCTUnwrap(request.url), statusCode: 200, httpVersion: nil, headerFields: nil)!
            let data = try JSONSerialization.data(withJSONObject: ["image": Data([0x89, 0x50, 0x4E, 0x47]).base64EncodedString()])
            return (response, data)
        }

        let spec = BuddyAppearanceRenderContract.makePreviewSpec(
            buddyName: "Dino",
            archetypeID: "dino",
            paletteID: "mint_cream",
            asciiVariantID: "starter_a",
            expressionTone: "friendly",
            accentLabel: "tail spark",
            renderStyle: .pixel
        )

        let record = await PixelLabPreviewService.sync(spec: spec, accessToken: "test-token")
        XCTAssertEqual(record.status, .ready)
        XCTAssertNotNil(record.localAssetPath)
    }

    func testPixelLabDecodeFailureReturnsFriendlyFallbackRecord() async {
        MockPixelLabURLProtocol.handler = { request in
            let response = HTTPURLResponse(url: request.url!, statusCode: 200, httpVersion: nil, headerFields: nil)!
            return (response, Data("{\"unexpected\":true}".utf8))
        }

        let spec = BuddyAppearanceRenderContract.makePreviewSpec(
            buddyName: "Pixel Pet",
            archetypeID: "pixel_pet",
            paletteID: "mint_cream",
            asciiVariantID: "starter_a",
            expressionTone: "friendly",
            accentLabel: "mint glow",
            renderStyle: .pixel
        )

        let record = await PixelLabPreviewService.sync(spec: spec, accessToken: "test-token")
        XCTAssertEqual(record.status, .failed)
        XCTAssertEqual(record.errorMessage, "Pixel preview format changed. Showing a local fallback.")
    }

    func testCachedPixelPreviewIsReusedWithoutSecondNetworkCall() async {
        MockPixelLabURLProtocol.handler = { request in
            MockPixelLabURLProtocol.requestCount += 1
            let response = HTTPURLResponse(url: request.url!, statusCode: 200, httpVersion: nil, headerFields: nil)!
            let data = try JSONSerialization.data(withJSONObject: ["image": Data([0x89, 0x50, 0x4E, 0x47]).base64EncodedString()])
            return (response, data)
        }

        let spec = BuddyAppearanceRenderContract.makePreviewSpec(
            buddyName: "Pet",
            archetypeID: "pixel_pet",
            paletteID: "mint_cream",
            asciiVariantID: "starter_a",
            expressionTone: "friendly",
            accentLabel: "mint glow",
            renderStyle: .pixel
        )

        _ = await PixelLabPreviewService.sync(spec: spec, accessToken: "test-token")
        _ = await PixelLabPreviewService.sync(spec: spec, accessToken: "test-token")

        XCTAssertEqual(MockPixelLabURLProtocol.requestCount, 1)
    }

    func testAppearanceContractBuildsDeterministicPixelKey() {
        let editorDraft = BuddyAppearanceEditorDraft(
            profileName: "Everyday",
            archetype: "pixel_pet",
            palette: "mint_cream",
            asciiVariantID: "starter_a",
            expressionTone: "friendly",
            accentLabel: "mint glow",
            renderStyle: .pixel,
            pixelVariantID: "",
            pixelAssetPath: nil
        )

        let editorKey = editorDraft.previewSpec(buddyName: "Sprout").pixelRequestKey
        let sharedKey = BuddyAppearanceRenderContract.pixelRequestKey(
            buddyName: "Sprout",
            archetypeID: "pixel_pet",
            paletteID: "mint_cream",
            expressionTone: "friendly",
            accentLabel: "mint glow"
        )

        XCTAssertEqual(editorKey, sharedKey)
    }

    func testLilBuddyReceiptsPersistLocally() async {
        let parentID = "buddy_1"
        let (created, receipts) = await LilBuddyStore.shared.createLilBuddy(
            parentBuddyInstanceId: parentID,
            parentBuddyDisplayName: "Buddy",
            name: "Scout",
            role: "Scout",
            mission: "Check the local queue"
        )

        let lilBuddy = try? XCTUnwrap(created.first)
        XCTAssertEqual(receipts.first?.action, "spawn")

        let dispatched = await LilBuddyStore.shared.dispatchMission(
            lilBuddyID: lilBuddy?.id ?? "",
            parentBuddyInstanceId: parentID
        )

        XCTAssertEqual(dispatched.0.first?.status, .active)
        XCTAssertEqual(dispatched.1.first?.action, "dispatch")
        XCTAssertTrue(FileManager.default.fileExists(atPath: Paths.stateDirectory.appendingPathComponent("lil-buddies.json").path))
    }

    private var mockSession: URLSession {
        let configuration = URLSessionConfiguration.ephemeral
        configuration.protocolClasses = [MockPixelLabURLProtocol.self]
        return URLSession(configuration: configuration)
    }
}

private final class MockPixelLabURLProtocol: URLProtocol {
    static var handler: ((URLRequest) throws -> (HTTPURLResponse, Data))?
    static var requestCount = 0

    static func reset() {
        handler = nil
        requestCount = 0
    }

    override class func canInit(with request: URLRequest) -> Bool { true }
    override class func canonicalRequest(for request: URLRequest) -> URLRequest { request }

    override func startLoading() {
        guard let handler = Self.handler else {
            client?.urlProtocol(self, didFailWithError: URLError(.badServerResponse))
            return
        }

        do {
            let (response, data) = try handler(request)
            client?.urlProtocol(self, didReceive: response, cacheStoragePolicy: .notAllowed)
            client?.urlProtocol(self, didLoad: data)
            client?.urlProtocolDidFinishLoading(self)
        } catch {
            client?.urlProtocol(self, didFailWithError: error)
        }
    }

    override func stopLoading() {}
}
