import Foundation
import Combine

class IntervalViewModel: ObservableObject {
    @Published var intervals: [Interval] = []
    
    func addInterval(name: String, startDate: Date, frequency: Int) {
        let newInterval = Interval(name: name, startDate: startDate, frequency: frequency)
        intervals.append(newInterval)
    }
    
    func updateInterval(_ updatedInterval: Interval) {
        if let index = intervals.firstIndex(where: { $0.id == updatedInterval.id }) {
            intervals[index] = updatedInterval
        }
    }
    
    func deleteInterval(_ interval: Interval) {
        intervals.removeAll { $0.id == interval.id}
    }
    
    func markIntervalAsCompleted(_ intervalId: UUID) {
          if let index = intervals.firstIndex(where: { $0.id == intervalId }) {
              intervals[index].markAsCompleted()
          }
      }
      
      func updateAllDueDates() {
          for index in intervals.indices {
              intervals[index].updateNextDue()
          }
      }
      
      func getOverdueIntervals() -> [Interval] {
          let now = Date()
          return intervals.filter { $0.nextDue < now }
      }
}
