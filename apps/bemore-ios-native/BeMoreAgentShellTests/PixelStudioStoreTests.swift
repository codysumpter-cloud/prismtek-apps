import XCTest
@testable import BeMoreAgent

@MainActor
final class PixelStudioStoreTests: XCTestCase {
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
        PixelStudioStore.shared.load()
    }

    override func tearDown() {
        if let appSupport = Paths.applicationSupportOverride {
            try? FileManager.default.removeItem(at: appSupport.deletingLastPathComponent())
        }
        Paths.applicationSupportOverride = nil
        Paths.documentsOverride = nil
        super.tearDown()
    }

    func testLegacyProjectLoadsIntoEditableFrameState() throws {
        let legacyJSON = """
        {
          "title": "Legacy Sprite",
          "author": "Cody",
          "concept": "Old project",
          "canvasSize": 16,
          "frameCount": 2,
          "palette": "#FFFFFF, #000000",
          "polishGoal": "Clean it up",
          "animationGoal": "Idle",
          "notes": "",
          "lastUpdatedAt": "2026-04-21T00:00:00Z"
        }
        """
        let data = try XCTUnwrap(legacyJSON.data(using: .utf8))
        try data.write(to: Paths.pixelStudioProjectFile)

        PixelStudioStore.shared.load()
        let project = PixelStudioStore.shared.project

        XCTAssertEqual(project.title, "Legacy Sprite")
        XCTAssertEqual(project.canvasSize, 16)
        XCTAssertEqual(project.frames.count, 2)
        XCTAssertEqual(project.frameCount, 2)
        XCTAssertEqual(project.activeFrameIndex, 0)
        XCTAssertEqual(project.frames.first?.pixels.count, 256)
        XCTAssertEqual(project.selectedHex, "#FFFFFF")
    }

    func testPaintingAndFrameActionsPersist() {
        PixelStudioStore.shared.load()
        PixelStudioStore.shared.selectColor("#FEF6E8")
        PixelStudioStore.shared.paint(row: 0, column: 0, hex: "#FEF6E8")
        PixelStudioStore.shared.duplicateActiveFrame()
        PixelStudioStore.shared.mirrorActiveFrame()

        let project = PixelStudioStore.shared.project
        XCTAssertEqual(project.frames.count, 4)
        XCTAssertEqual(project.frameCount, 4)
        XCTAssertEqual(project.frames[0].pixels[0], "#FEF6E8")
        XCTAssertTrue(FileManager.default.fileExists(atPath: Paths.pixelStudioProjectFile.path))

        PixelStudioStore.shared.load()
        XCTAssertEqual(PixelStudioStore.shared.project.frames.count, 4)
        XCTAssertEqual(PixelStudioStore.shared.project.frames[0].pixels[0], "#FEF6E8")
    }
}
