//
//  DiscreteRectTests.swift
//  BeeKeeperTests
//
//  Created by Chaniel Ezzi on 9/9/23.
//

import XCTest
@testable import BeeKeeper

final class DiscreteRectTests: XCTestCase {

    override func setUpWithError() throws {
        
    }

    override func tearDownWithError() throws {
        
    }

    func testIntersect() throws {
        var rect1 = DiscreteRect(x: 0, y: 0, width: 1, height: 1)
        var rect2 = DiscreteRect(x: 1, y: 1, width: 1, height: 1)
        XCTAssertFalse(rect1.intersets(rect2))
        XCTAssertFalse(rect2.intersets(rect1))
        
        rect1 = DiscreteRect(x: 0, y: 0, width: 2, height: 2)
        XCTAssertTrue(rect1.intersets(rect2))
        XCTAssertTrue(rect2.intersets(rect1))
        
        rect2 = DiscreteRect(x: 1, y: 1, width: 2, height: 2)
        XCTAssertTrue(rect1.intersets(rect2))
        XCTAssertTrue(rect2.intersets(rect1))
    }

}
