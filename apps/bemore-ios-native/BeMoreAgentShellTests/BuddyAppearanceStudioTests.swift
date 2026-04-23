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
        let frames = BuddyAsciiRenderer.frames(
            archetypeID: "dino",
            mood: .idle,
            expressionTone: "friendly",
            asciiVariantID: "starter_a",
            customization: .init(
                subtype: "trex",
                bodyStyle: "chunky",
                accessory: "none",
                accentDetail: "spike_tail",
                pose: "proud_stance",
                personalityVibe: "cute",
                animationFlavor: "tail_swish",
                promptModifiers: ""
            )
        )
        XCTAssertEqual(frames.count, 3)
        XCTAssertTrue(frames.joined(separator: "\n").contains("___/{"))
        XCTAssertTrue(frames.joined(separator: "\n").contains(">"))
        XCTAssertFalse(frames.joined(separator: "\n").localizedCaseInsensitiveContains("rawr"))
    }

    func testAsciiDinoSubtypeOutputDiffersBySubtype() {
        let trex = BuddyAsciiRenderer.frames(
            archetypeID: "dino",
            mood: .idle,
            expressionTone: "friendly",
            asciiVariantID: "starter_a",
            customization: .init(subtype: "trex", bodyStyle: "chunky", accessory: "none", accentDetail: "spike_tail", pose: "proud_stance", personalityVibe: "cute", animationFlavor: "tail_swish", promptModifiers: "")
        )
        let trike = BuddyAsciiRenderer.frames(
            archetypeID: "dino",
            mood: .idle,
            expressionTone: "friendly",
            asciiVariantID: "starter_a",
            customization: .init(subtype: "triceratops", bodyStyle: "armored", accessory: "none", accentDetail: "plate_ridges", pose: "idle", personalityVibe: "friendly", animationFlavor: "gentle_bob", promptModifiers: "")
        )

        XCTAssertNotEqual(trex.first, trike.first)
        XCTAssertTrue(trike.joined(separator: "\n").contains("^"))
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
            XCTAssertTrue(payload.description.contains("T-Rex"))
            XCTAssertTrue(payload.description.contains("body style chunky"))
            XCTAssertTrue(payload.description.contains("accessory satchel"))

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
            customization: .init(subtype: "trex", bodyStyle: "chunky", accessory: "satchel", accentDetail: "spike_tail", pose: "proud_stance", personalityVibe: "cute", animationFlavor: "tail_swish", promptModifiers: "retro green sprite"),
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
            customization: BuddyAppearanceRenderContract.defaultCustomization(for: "pixel_pet"),
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
            customization: BuddyAppearanceRenderContract.defaultCustomization(for: "pixel_pet"),
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
            customization: .init(subtype: "pet", bodyStyle: "round", accessory: "bell_collar", accentDetail: "cheek_sparks", pose: "bounce", personalityVibe: "friendly", animationFlavor: "tiny_bounce", promptModifiers: "retro pet"),
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
            accentLabel: "mint glow",
            customization: editorDraft.customization
        )

        XCTAssertEqual(editorKey, sharedKey)
    }

    func testPreviewSpecChangesWhenDinoSubtypeChanges() {
        let trexDraft = BuddyAppearanceEditorDraft(
            profileName: "Dino Look",
            archetype: "dino",
            palette: "forest_moss",
            asciiVariantID: "starter_a",
            expressionTone: "friendly",
            accentLabel: "leaf scarf",
            customization: .init(subtype: "trex", bodyStyle: "chunky", accessory: "satchel", accentDetail: "spike_tail", pose: "proud_stance", personalityVibe: "cute", animationFlavor: "tail_swish", promptModifiers: "retro buddy"),
            renderStyle: .pixel,
            pixelVariantID: "",
            pixelAssetPath: nil
        )
        let stegoDraft = BuddyAppearanceEditorDraft(
            profileName: "Dino Look",
            archetype: "dino",
            palette: "forest_moss",
            asciiVariantID: "starter_a",
            expressionTone: "friendly",
            accentLabel: "leaf scarf",
            customization: .init(subtype: "stegosaurus", bodyStyle: "armored", accessory: "satchel", accentDetail: "plate_ridges", pose: "proud_stance", personalityVibe: "cute", animationFlavor: "tail_swish", promptModifiers: "retro buddy"),
            renderStyle: .pixel,
            pixelVariantID: "",
            pixelAssetPath: nil
        )

        XCTAssertNotEqual(trexDraft.previewSpec(buddyName: "Mossy").pixelRequestKey, stegoDraft.previewSpec(buddyName: "Mossy").pixelRequestKey)
        XCTAssertNotEqual(trexDraft.previewSpec(buddyName: "Mossy").customization.subtype, stegoDraft.previewSpec(buddyName: "Mossy").customization.subtype)
    }

    func testDinoSubtypePersistsInAppearanceProfile() throws {
        let now = Date(timeIntervalSince1970: 1_744_315_000)
        let contracts = try BuddyContractLoader.loadCanonicalResources()
        let engine = BuddyEventEngine(contracts: contracts)
        let installed = try engine.install(templateID: "bmo", currentState: BuddyLibraryState(), currentEvents: BuddyRuntimeEventLog(), now: now)
        let customization = BuddyAppearanceCustomization(
            subtype: "stegosaurus",
            bodyStyle: "armored",
            accessory: "scarf",
            accentDetail: "plate_ridges",
            pose: "proud_stance",
            personalityVibe: "friendly",
            animationFlavor: "tail_swish",
            promptModifiers: "cute retro green buddy"
        )

        let saved = try engine.saveAppearanceProfile(
            instanceID: try XCTUnwrap(installed.libraryState.activeBuddy?.instanceId),
            profileName: "Forest Stego",
            archetype: "dino",
            palette: "forest_moss",
            asciiVariantID: "starter_a",
            pixelVariantID: nil,
            expressionTone: "friendly",
            accentLabel: "leaf scarf",
            customization: customization,
            setActive: true,
            currentState: installed.libraryState,
            currentEvents: installed.eventLog,
            now: now.addingTimeInterval(10)
        )

        let profile = try XCTUnwrap(saved.libraryState.activeBuddy?.appearanceProfiles?.first)
        XCTAssertEqual(profile.customization.subtype, "stegosaurus")
        XCTAssertEqual(saved.libraryState.activeBuddy?.visual?.appearance.subtype, "stegosaurus")
    }

    func testSavedLookPreservesAdvancedCustomizationFields() throws {
        let now = Date(timeIntervalSince1970: 1_744_315_100)
        let contracts = try BuddyContractLoader.loadCanonicalResources()
        let engine = BuddyEventEngine(contracts: contracts)
        let installed = try engine.install(templateID: "bmo", currentState: BuddyLibraryState(), currentEvents: BuddyRuntimeEventLog(), now: now)
        let customization = BuddyAppearanceCustomization(
            subtype: "raptor",
            bodyStyle: "lean",
            accessory: "leaf_bandana",
            accentDetail: "spike_tail",
            pose: "peek",
            personalityVibe: "playful",
            animationFlavor: "blink_blink",
            promptModifiers: "cute sprite pet"
        )

        let saved = try engine.saveAppearanceProfile(
            instanceID: try XCTUnwrap(installed.libraryState.activeBuddy?.instanceId),
            profileName: "Scout Raptor",
            archetype: "dino",
            palette: "forest_moss",
            asciiVariantID: "starter_b",
            pixelVariantID: "pixellab:test",
            expressionTone: "curious",
            accentLabel: "leaf bandana",
            customization: customization,
            setActive: true,
            currentState: installed.libraryState,
            currentEvents: installed.eventLog,
            now: now.addingTimeInterval(20)
        )

        let profile = try XCTUnwrap(saved.libraryState.activeBuddy?.appearanceProfiles?.first)
        XCTAssertEqual(profile.customization.bodyStyle, "lean")
        XCTAssertEqual(profile.customization.accessory, "leaf_bandana")
        XCTAssertEqual(profile.customization.pose, "peek")
        XCTAssertEqual(profile.customization.personalityVibe, "playful")
        XCTAssertEqual(profile.customization.animationFlavor, "blink_blink")
        XCTAssertEqual(profile.customization.promptModifiers, "cute sprite pet")
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
