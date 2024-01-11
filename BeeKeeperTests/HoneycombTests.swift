//
//  HoneycombTests.swift
//  BeeKeeperTests
//
//  Created by Chaniel Ezzi on 9/15/23.
//

import XCTest
@testable import BeeKeeper

final class HoneycombTests: XCTestCase {
    
    override func setUpWithError() throws {
        
    }
    
    override func tearDownWithError() throws {
        
    }
    
    func testFill() throws {
        let hive = Hive()
        let honeycomb = try hive.addHoneycomb()
        // Assert initial stats
        XCTAssert(honeycomb.containing == Resources() && honeycomb.maximum == Resources(honey: 100))
        // Fill with 50, none left over
        var excess = Resources(honey: 50)
        try honeycomb.fill(&excess)
        XCTAssert(excess.isEmpty())
        XCTAssert(honeycomb.containing == Resources(honey: 50) && honeycomb.maximum == Resources(honey: 100))
        // Fill with 51, 1 left over
        excess = Resources(honey: 51)
        try honeycomb.fill(&excess)
        XCTAssert(excess == Resources(honey: 1))
        XCTAssert(honeycomb.containing == Resources(honey: 100) && honeycomb.maximum == Resources(honey: 100))
        // Hive matches honeycomb
        XCTAssert(hive.containing == honeycomb.containing)
        
        XCTAssertThrowsError(try hive.transfer(to: hive))
        
        let storage = HoneyStorage()
        try hive.transfer(to: storage)
        XCTAssert(storage.containing == Resources(honey: 100))
        XCTAssert(honeycomb.containing == Resources() && honeycomb.maximum == Resources(honey: 100))
    }
}
