import XCTest
@testable import BeMoreAgent

final class BuddyMonTests: XCTestCase {
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

    func testOfflineTickHatchesStarterEgg() {
        let start = Date(timeIntervalSince1970: 1_800_000_000)
        let pet = BuddyMonPet.starterEgg(now: start)

        let hatched = BuddyMonEngine.tick(
            pet,
            now: start.addingTimeInterval(BuddyMonEngine.hatchAgeMinutes * 60 + 1)
        )

        XCTAssertEqual(hatched.formID, "sproutbyte")
        XCTAssertTrue(hatched.evolutionLog.contains("Sproutbyte hatched from the Prism Egg."))
        XCTAssertEqual(hatched.mood, .happy)
    }

    func testCareActionsCanGrowSproutbyteIntoBravebyte() {
        let start = Date(timeIntervalSince1970: 1_800_000_000)
        var pet = BuddyMonPet.starterEgg(now: start)
        pet.formID = "sproutbyte"
        pet.stats.ageMinutes = BuddyMonEngine.evolutionAgeMinutes
        pet.stats.strength = 54
        pet.stats.bond = 39
        pet.stats.energy = 80
        pet.stats.hunger = 90
        pet.stats.stress = 5

        let evolved = BuddyMonEngine.perform(.train, on: pet, now: start.addingTimeInterval(60))

        XCTAssertEqual(evolved.formID, "bravebyte")
        XCTAssertTrue(evolved.evolutionLog.contains("Sproutbyte grew into Bravebyte."))
    }

    func testNeglectPathCanCreateGlitchlingVariant() {
        let start = Date(timeIntervalSince1970: 1_800_000_000)
        var pet = BuddyMonPet.starterEgg(now: start)
        pet.formID = "sproutbyte"
        pet.stats.ageMinutes = BuddyMonEngine.evolutionAgeMinutes
        pet.stats.stress = 70
        pet.stats.careMistakes = 4

        let evolved = BuddyMonEngine.tick(pet, now: start.addingTimeInterval(60))

        XCTAssertEqual(evolved.formID, "glitchling")
        XCTAssertTrue(evolved.evolutionLog.contains("Sproutbyte grew into Glitchling."))
    }

    func testBuddyMonStatePersistsAsLocalJSON() throws {
        let start = Date(timeIntervalSince1970: 1_800_000_000)
        var state = BuddyMonGameState.newGame(now: start)
        state.activePet.nickname = "Pocket Prism"
        state.lastReceipt = "test receipt"

        let store = BuddyMonPersistenceStore()
        try store.persist(state)

        let loaded = try XCTUnwrap(store.load())
        XCTAssertEqual(loaded.activePet.nickname, "Pocket Prism")
        XCTAssertEqual(loaded.lastReceipt, "test receipt")
        XCTAssertTrue(FileManager.default.fileExists(atPath: store.stateURL.path))
    }

    @MainActor
    func testBuddyMonStoreBattleWritesBattleLogAndCollection() {
        let start = Date(timeIntervalSince1970: 1_800_000_000)
        let store = BuddyMonStore(now: start)

        store.perform(.feed, now: start.addingTimeInterval(60))
        store.perform(.play, now: start.addingTimeInterval(120))
        store.runBattle(now: start.addingTimeInterval(BuddyMonEngine.hatchAgeMinutes * 60 + 180))

        XCTAssertEqual(store.state.battleLog.count, 1)
        XCTAssertEqual(store.state.collection.first?.id, store.activePet.id)
        XCTAssertNotNil(store.state.lastReceipt)
    }
}
