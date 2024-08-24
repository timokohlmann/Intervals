//
//  IntervalTests.swift
//  IntervalTests
//
//  Created by Timo Kohlmann on 24.08.24.
//

import XCTest
@testable import Intervals

class IntervalViewModelTests: XCTestCase {
    var viewModel: IntervalViewModel!
    
    override func setUp() {
        super.setUp()
        viewModel = IntervalViewModel()
    }
    
    func testAddInterval() {
        let initialCount = viewModel.intervals.count
        viewModel.addInterval(name: "Test Interval", startDate: Date(), frequencyType: .days, frequencyCount: 1, includeTime: false)
        XCTAssertEqual(viewModel.intervals.count, initialCount + 1)
        XCTAssertEqual(viewModel.intervals.last?.name, "Test Interval")
    }
}
