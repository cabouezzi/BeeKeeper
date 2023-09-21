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
        for _ in 0..<3 {
            let honeycomb = Honeycomb(hive: hive)
            hive.honeycombs.append(honeycomb)
            max =  max.adding(honeycomb.maximum)
        }
        XCTAssertTrue(hive.containing == Resources(honey: 0) && hive.maximum == max)
        
        for honeycomb in hive.honeycombs {
            let excess = try honeycomb.fill(Resources(honey: 33, pollen: 1))
            XCTAssertEqual(excess, Resources(pollen: 1))
        }
        XCTAssertTrue(hive.containing == Resources(honey: 99) && hive.maximum == max)
    }
    
}
