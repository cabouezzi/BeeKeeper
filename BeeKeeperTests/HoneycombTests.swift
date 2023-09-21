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
        let honeycomb = Honeycomb(hive: hive)
        XCTAssert(honeycomb.containing == Resources() && honeycomb.maximum == Resources(honey: 100))
        var excess = try honeycomb.fill(Resources(honey: 50))
        XCTAssert(excess == Resources())
        XCTAssert(honeycomb.containing == Resources(honey: 50) && honeycomb.maximum == Resources(honey: 100))
        excess = try honeycomb.fill(Resources(honey: 51))
        XCTAssert(excess == Resources(honey: 1))
        XCTAssert(honeycomb.containing == Resources(honey: 100) && honeycomb.maximum == Resources(honey: 100))
        
        let collected = honeycomb.collect()
        XCTAssert(collected == Resources(honey: 100))
        XCTAssert(honeycomb.containing == Resources() && honeycomb.maximum == Resources(honey: 100))
    }

}
