//
//  HiveTests.swift
//  BeeKeeperTests
//
//  Created by Chaniel Ezzi on 9/10/23.
//

import XCTest
@testable import BeeKeeper

final class HiveTests: XCTestCase {
    
    override func setUpWithError() throws {
        
    }
    
    override func tearDownWithError() throws {
        
    }
    
    func testSelfTransfer() throws {
        let hive = Hive()
        XCTAssertThrowsError(try hive.transfer(to: hive))
    }
    
    func testCommulative() throws {
        let hive = Hive()
        // Assert initial stats
        XCTAssertTrue(hive.containing == Resources(honey: 0) && hive.maximum == Resources(honey: 0))
        
        // Assert maximum correct
        // Compute maximum manually
        var max = Resources()
        for i in 0..<3 {
            try hive.addHoneycomb()
            max =  max.adding(hive.honeycombs[i].maximum)
        }
        XCTAssertTrue(hive.containing == Resources(honey: 0) && hive.maximum == max)
        
        // Fill up to 99 honey, don't accept pollen
        for honeycomb in hive.honeycombs {
            var fill = Resources(honey: 33, pollen: 1)
            try honeycomb.fill(&fill)
            XCTAssertEqual(fill, Resources(pollen: 1))
        }
        XCTAssertTrue(hive.containing == Resources(honey: 99) && hive.maximum == max)
        XCTAssertThrowsError(try hive.addHoneycomb())
    }
    
    func testOverflow() throws {
        let hive = Hive()
        var excess = Resources(honey: 203)
        try hive.addHoneycomb()
        try hive.addHoneycomb()
        
        // Test filling past max
        try hive.fill(&excess)
        XCTAssert(hive.honeycombs[0].containing.honey == 100)
        XCTAssert(hive.honeycombs[1].containing.honey == 100)
        XCTAssert(excess.honey == 3)
        
        // Test removing more than containing
        XCTAssertThrowsError(try hive.remove(Resources(honey: 201)))
        // Test removing less than containing
        try hive.remove(Resources(honey: 150))
        XCTAssert(hive.containing.honey == 50)
        XCTAssert(
            (hive.honeycombs[0].containing.honey == 0 && hive.honeycombs[1].containing.honey == 50) ||
            (hive.honeycombs[0].containing.honey == 50 && hive.honeycombs[1].containing.honey == 0)
        )
        // Test removing containing
        excess = Resources(honey: 200)
        try hive.fill(&excess)
        try hive.remove(Resources(honey: 200))
        XCTAssert(hive.containing.isEmpty())
        XCTAssert(hive.honeycombs.allSatisfy({ $0.containing.isEmpty() }))
        
    }
}
