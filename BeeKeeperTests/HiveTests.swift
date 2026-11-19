import XCTest
@testable import BeeKeeper

final class HiveTests: XCTestCase {
    func testSelfTransfer() throws {
        let hive = Hive()
        XCTAssertThrowsError(try hive.transfer(to: hive))
    }

    func testCumulativeCapacityAndConstructionLimit() throws {
        try withFundedHive { hive in
            XCTAssertEqual(hive.containing, Resources())
            XCTAssertEqual(hive.maximum, Resources())

            for _ in 0..<3 {
                try constructHoneycomb(in: hive)
            }

            XCTAssertEqual(hive.maximum, Resources(honey: 3_000))
            XCTAssertEqual(hive.maximumAssignedBees, 4)

            for honeycomb in hive.honeycombs {
                var fill = Resources(honey: 33, pollen: 1)
                try honeycomb.fill(&fill)
                XCTAssertEqual(fill, Resources(pollen: 1))
            }

            XCTAssertEqual(hive.containing, Resources(honey: 99))
            XCTAssertThrowsError(try hive.startHoneycombConstruction())
        }
    }

    func testOverflowAndRemoval() throws {
        try withFundedHive { hive in
            try constructHoneycomb(in: hive)
            try constructHoneycomb(in: hive)

            var excess = Resources(honey: 2_003)
            XCTAssertThrowsError(try hive.fill(&excess))
            XCTAssertEqual(hive.honeycombs.map(\.containing.honey), [1_000, 1_000])
            XCTAssertEqual(excess, Resources(honey: 3))

            XCTAssertThrowsError(try hive.remove(Resources(honey: 2_001)))
            try hive.remove(Resources(honey: 150))
            XCTAssertEqual(hive.containing, Resources(honey: 1_850))

            var refill = Resources(honey: 150)
            try hive.fill(&refill)
            XCTAssertTrue(refill.isEmpty())
            try hive.remove(Resources(honey: 2_000))
            XCTAssertTrue(hive.containing.isEmpty())
            XCTAssertTrue(hive.honeycombs.allSatisfy { $0.containing.isEmpty() })
        }
    }

    private func withFundedHive(_ body: (Hive) throws -> Void) throws {
        let storage = try XCTUnwrap(GameManager.shared.apiary.structures.compactMap { $0 as? HoneyStorage }.first)
        let original = storage.containing
        defer { storage.containing = original }
        storage.containing = Resources(honey: 6_000)
        try body(Hive())
    }

    private func constructHoneycomb(in hive: Hive) throws {
        try hive.startHoneycombConstruction()
        try hive.forceCompleteConstruction()
        try hive.claimHoneycombConstruction()
    }
}
