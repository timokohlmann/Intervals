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
    
    func testUpdateInterval() {
        viewModel.addInterval(name: "Original", startDate: Date(), frequencyType: .days, frequencyCount: 1, includeTime: false)
        let addedInterval = viewModel.intervals.last!
        
        viewModel.updateInterval(id: addedInterval.id, name: "Updated", startDate: addedInterval.startDate, frequencyType: .weeks, frequencyCount: 2, includeTime: true)
        
        let updatedInterval = viewModel.intervals.last!
        XCTAssertEqual(updatedInterval.name, "Updated")
        XCTAssertEqual(updatedInterval.frequencyType, .weeks)
        XCTAssertEqual(updatedInterval.frequencyCount, 2)
        XCTAssertTrue(updatedInterval.includeTime)
    }
    
    func testDeleteInterval() {
        viewModel.addInterval(name: "To Delete", startDate: Date(), frequencyType: .days, frequencyCount: 1, includeTime: false)
        let initialCount = viewModel.intervals.count
        let intervalToDelete = viewModel.intervals.last!
        
        viewModel.deleteInterval(intervalToDelete)
        
        XCTAssertEqual(viewModel.intervals.count, initialCount - 1)
        XCTAssertNil(viewModel.intervals.first(where: { $0.id == intervalToDelete.id }))
    }
    
    func testMarkIntervalAsCompleted() {
        viewModel.addInterval(name: "To Complete", startDate: Date(), frequencyType: .days, frequencyCount: 1, includeTime: false)
        let intervalToComplete = viewModel.intervals.last!
        
        viewModel.markIntervalAsCompleted(intervalToComplete.id)
        
        let completedInterval = viewModel.intervals.last!
        XCTAssertNotNil(completedInterval.lastCompleted)
        XCTAssertGreaterThan(completedInterval.nextDue, intervalToComplete.nextDue)
    }
    
    func testGetOverdueIntervals() {
        let pastDate = Calendar.current.date(byAdding: .day, value: -2, to: Date())!
        viewModel.addInterval(name: "Overdue", startDate: pastDate, frequencyType: .days, frequencyCount: 1, includeTime: false)
        viewModel.addInterval(name: "Not Overdue", startDate: Date(), frequencyType: .days, frequencyCount: 1, includeTime: false)
        
        let overdueIntervals = viewModel.getOverdueIntervals()
        
        XCTAssertEqual(overdueIntervals.count, 1)
        XCTAssertEqual(overdueIntervals.first?.name, "Overdue")
    }
}
