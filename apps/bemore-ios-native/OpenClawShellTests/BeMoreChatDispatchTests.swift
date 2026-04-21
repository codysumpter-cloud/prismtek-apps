import XCTest
@testable import BeMoreAgent

@MainActor
final class BeMoreChatDispatchTests: XCTestCase {
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

    func testResponseGuardRemovesAnalysisBlocksAndPlanningScaffolding() {
        let raw = """
        <analysis>
        the user is asking for a status update
        i should talk about the internal plan
        </analysis>

        Here is what Buddy can do right now.
        """

        let cleaned = BeMoreResponseGuard.userVisibleAnswer(from: raw)

        XCTAssertEqual(cleaned, "Here is what Buddy can do right now.")
        XCTAssertFalse(cleaned.localizedCaseInsensitiveContains("the user is asking"))
        XCTAssertFalse(cleaned.localizedCaseInsensitiveContains("internal plan"))
    }

    func testResponseGuardFallsBackWhenOnlyAnalysisMarkupRemains() {
        let raw = """
        <analysis>
        hidden reasoning only
        </analysis>
        """

        let cleaned = BeMoreResponseGuard.userVisibleAnswer(from: raw)
        XCTAssertFalse(cleaned.isEmpty)
        XCTAssertTrue(cleaned.localizedCaseInsensitiveContains("Buddy is ready"))
    }

    func testCommandParserRecognizesTeachReviewRefineValidateApproveAndPixelHelp() {
        XCTAssertEqual(BeMoreChatCommandParser.parse("teach yourself how to triage my bug inbox"), .teach("triage my bug inbox"))
        XCTAssertEqual(BeMoreChatCommandParser.parse("review skill user-taught-demo"), .review("user-taught-demo"))
        XCTAssertEqual(BeMoreChatCommandParser.parse("validate skill user-taught-demo"), .validate("user-taught-demo"))
        XCTAssertEqual(BeMoreChatCommandParser.parse("approve skill user-taught-demo"), .approve("user-taught-demo"))
        XCTAssertEqual(BeMoreChatCommandParser.parse("finish this pixel art"), .pixelAssist(.finish, ""))
        XCTAssertEqual(BeMoreChatCommandParser.parse("improve this sprite for mobile readability"), .pixelAssist(.improve, "for mobile readability"))
        XCTAssertEqual(BeMoreChatCommandParser.parse("animate this sprite with a stronger idle loop"), .pixelAssist(.animate, "with a stronger idle loop"))

        guard case let .refine(id, instruction)? = BeMoreChatCommandParser.parse("refine skill user-taught-demo: add an approval prompt") else {
            return XCTFail("Expected refine command")
        }
        XCTAssertEqual(id, "user-taught-demo")
        XCTAssertEqual(instruction, "add an approval prompt")
    }

    func testCommandParserDoesNotTreatEmbeddedTeachPhraseAsCommand() {
        XCTAssertNil(BeMoreChatCommandParser.parse("Can you explain how to teach yourself how to triage my bug inbox?"))
    }

    func testValidateAndApproveChatSkillDraftProducesManifestAndValidationArtifacts() throws {
        let runtime = BeMoreWorkspaceRuntime()
        runtime.bootstrap(config: .default, preferences: .default, routeSummary: "Direct cloud model route")

        let draftReceipt = runtime.draftSkillFromChat(request: "build daily standup notes from my check-ins", requestedBy: "Prism")
        let skillID = try XCTUnwrap(draftReceipt.output["skillId"])

        let refineReceipt = runtime.refineChatSkillDraft(id: skillID, instruction: "ask before overwriting an existing note")
        XCTAssertEqual(refineReceipt.status, .persisted)

        let validateReceipt = runtime.validateChatSkillDraft(id: skillID)
        XCTAssertEqual(validateReceipt.status, .persisted)
        XCTAssertTrue(validateReceipt.artifacts.contains("skills/\(skillID)/validation.json"))
        XCTAssertTrue(validateReceipt.artifacts.contains("skills/\(skillID)/draft-manifest.json"))

        let approveReceipt = runtime.approveChatSkillDraft(id: skillID)
        XCTAssertEqual(approveReceipt.status, .persisted)
        XCTAssertTrue(runtime.skills.contains(where: { $0.id == skillID }))
        XCTAssertTrue(FileManager.default.fileExists(atPath: Paths.beMoreRuntimeDirectory.appendingPathComponent("skills/\(skillID)/manifest.json").path))
    }
}
