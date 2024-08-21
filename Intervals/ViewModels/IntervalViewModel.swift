import Foundation
import Combine

class IntervalViewModel: ObservableObject {
    @Published var intervals: [Interval] = []
    
    func addInterval(name: String, startDate: Date, frequencyType: FrequencyType, frequencyCount: Int) {
        let newInterval = Interval(name: name, startDate: startDate, frequencyType: frequencyType, frequencyCount: frequencyCount)
        intervals.append(newInterval)
    }
    
    func updateInterval(id: UUID, name: String, startDate: Date, frequencyType: FrequencyType, frequencyCount: Int) {
        if let index = intervals.firstIndex(where: { $0.id == id }) {
            intervals[index].name = name
            intervals[index].startDate = startDate
            intervals[index].frequencyType = frequencyType
            intervals[index].frequencyCount = frequencyCount
            intervals[index].updateNextDue()
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
