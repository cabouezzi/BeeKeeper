import XCTest
@testable import BeeKeeper

final class HoneycombTests: XCTestCase {
    func testFillAndTransfer() throws {
        let storage = try XCTUnwrap(GameManager.shared.apiary.structures.compactMap { $0 as? HoneyStorage }.first)
        let original = storage.containing
        defer { storage.containing = original }
        storage.containing = Resources(honey: 1_000)

        let hive = Hive()
        try hive.startHoneycombConstruction()
        try hive.forceCompleteConstruction()
        let honeycomb = try hive.claimHoneycombConstruction()

        XCTAssertEqual(honeycomb.containing, Resources())
        XCTAssertEqual(honeycomb.maximum, Resources(honey: 1_000))

        var excess = Resources(honey: 500)
        try honeycomb.fill(&excess)
        XCTAssertTrue(excess.isEmpty())
        XCTAssertEqual(honeycomb.containing, Resources(honey: 500))

        excess = Resources(honey: 501)
        try honeycomb.fill(&excess)
        XCTAssertEqual(excess, Resources(honey: 1))
        XCTAssertEqual(hive.containing, Resources(honey: 1_000))

        let destination = HoneyStorage()
        try hive.transfer(to: destination)
        XCTAssertEqual(destination.containing, Resources(honey: 1_000))
        XCTAssertEqual(honeycomb.containing, Resources())
    }
}
