//
//  IncubatorTests.swift
//  BeeKeeperTests
//
//  Created by Chaniel Ezzi on 9/15/23.
//

import XCTest
@testable import BeeKeeper

final class IncubatorTests: XCTestCase {
    var incubator = Incubator()
    
    override func setUpWithError() throws {
        
    }

    override func tearDownWithError() throws {
        // reset period because accessor is inaccessible
        incubator = Incubator()
    }
    
    func testIncubationStart() throws {
        XCTAssertEqual(incubator.state, .idle)
        try incubator.startIncubating(10)
        XCTAssertEqual(incubator.state, .incubating)
        sleep(10)
        XCTAssertEqual(incubator.state, .finished)
    }
}
