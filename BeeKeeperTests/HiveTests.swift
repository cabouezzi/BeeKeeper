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
    
    func testCommulative() throws {
        let hive = Hive()
        XCTAssertTrue(hive.containing == Resources(honey: 0) && hive.maximum == Resources(honey: 0))
        var max = Resources()
        for i in 0..<3 {
            try hive.addHoneycomb()
            max =  max.adding(hive.honeycombs[i].maximum)
        }
        XCTAssertTrue(hive.containing == Resources(honey: 0) && hive.maximum == max)
        
        for honeycomb in hive.honeycombs {
            var fill = Resources(honey: 33, pollen: 1)
            try honeycomb.fill(&fill)
            XCTAssertEqual(fill, Resources(pollen: 1))
        }
        XCTAssertTrue(hive.containing == Resources(honey: 99) && hive.maximum == max)
        XCTAssertThrowsError(try hive.addHoneycomb())
    }
    
}
