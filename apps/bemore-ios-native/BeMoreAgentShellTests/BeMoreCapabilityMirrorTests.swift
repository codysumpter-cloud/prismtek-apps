import XCTest
@testable import BeMoreAgent

@MainActor
final class BeMoreCapabilityMirrorTests: XCTestCase {
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
    }

    override func tearDown() {
        if let appSupport = Paths.applicationSupportOverride {
            try? FileManager.default.removeItem(at: appSupport.deletingLastPathComponent())
        }
        Paths.applicationSupportOverride = nil
        Paths.documentsOverride = nil
        super.tearDown()
    }

    func testCapabilityMirrorMarksNativeAndLinkedCapabilitiesHonestly() {
        let state = AppState(engine: MLCBridgeEngine())
        state.stackConfig = .default

        let statuses = state.beMoreCapabilityStatuses

        XCTAssertTrue(statuses.contains(where: { $0.capability.id == "buddy.chat" && $0.availability == .available }))
        XCTAssertTrue(statuses.contains(where: { $0.capability.id == "studio.pixel" && $0.availability == .available }))
        XCTAssertTrue(statuses.contains(where: { $0.capability.id == "github.read.private" && $0.availability == .requiresLinkedAccount }))
        XCTAssertTrue(statuses.contains(where: { $0.capability.id == "runtime.exec.safe" && $0.availability == .requiresLinkedRuntime }))
    }
}
