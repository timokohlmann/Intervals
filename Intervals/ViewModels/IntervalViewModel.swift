import Foundation
import Combine
import UserNotifications


class IntervalViewModel: ObservableObject {
    @Published var intervals: [Interval] = []
    
    
    func scheduleNotification(for interval: Interval) {
        let content = UNMutableNotificationContent()
        content.title = "Task Due: \(interval.name)"
        content.body = "It's time to complete your task."
        content.sound = .default

       
        let localDate = convertToLocalTime(date: interval.nextDue)
        
        let triggerDate = Calendar.current.dateComponents([.year, .month, .day, .hour, .minute], from: localDate)
        let trigger = UNCalendarNotificationTrigger(dateMatching: triggerDate, repeats: false)

        let request = UNNotificationRequest(identifier: interval.id.uuidString, content: content, trigger: trigger)

        UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: [interval.id.uuidString])
        
        UNUserNotificationCenter.current().add(request) { error in
            if let error = error {
             
                print("Failed to schedule notification: \(error.localizedDescription)")
            }
        }
    }



    func convertToLocalTime(date: Date) -> Date {
        let timezone = TimeZone.current
        let seconds = TimeInterval(timezone.secondsFromGMT(for: date))
        return Date(timeInterval: seconds, since: date)
    }


    
    func addInterval(name: String, startDate: Date, frequencyType: FrequencyType, frequencyCount: Int, includeTime: Bool) {
        let newInterval = Interval(name: name, startDate: startDate, frequencyType: frequencyType, frequencyCount: frequencyCount, includeTime: includeTime)
        intervals.append(newInterval)
        
        scheduleNotification(for: newInterval)
 
    }
    
    func updateInterval(id: UUID, name: String, startDate: Date, frequencyType: FrequencyType, frequencyCount: Int, includeTime: Bool) {
        if let index = intervals.firstIndex(where: { $0.id == id }) {
            intervals[index].name = name
            intervals[index].startDate = startDate
            intervals[index].frequencyType = frequencyType
            intervals[index].frequencyCount = frequencyCount
            intervals[index].includeTime = includeTime
            intervals[index].updateNextDue()
            
            
            UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: [id.uuidString])
                        scheduleNotification(for: intervals[index])
        }
    }
    
    func deleteInterval(_ interval: Interval) {
        UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: [interval.id.uuidString])
        intervals.removeAll { $0.id == interval.id }
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
