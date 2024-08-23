import Foundation
import Combine
import UserNotifications


class IntervalViewModel: ObservableObject {
    @Published var intervals: [Interval] = []
    
    
    func scheduleNotification(for interval: Interval) {
        print("Scheduling notification for interval: \(interval.name)")
        let content = UNMutableNotificationContent()
        content.title = "Task Due: \(interval.name)"
        content.body = "It's time to complete your task."
        content.sound = .default

        let triggerDate = Calendar.current.dateComponents([.year, .month, .day, .hour, .minute], from: interval.nextDue)
        print("Trigger date components: \(triggerDate)")

        let trigger = UNCalendarNotificationTrigger(dateMatching: triggerDate, repeats: false)
        let request = UNNotificationRequest(identifier: interval.id.uuidString, content: content, trigger: trigger)

        UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: [interval.id.uuidString])
        print("Removed any existing notifications for interval ID: \(interval.id.uuidString)")
        
        UNUserNotificationCenter.current().add(request) { error in
            if let error = error {
                print("Failed to schedule notification: \(error.localizedDescription)")
            } else {
                print("Notification scheduled successfully for \(interval.name) at \(interval.nextDue)")
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
        print("Updating interval with ID: \(id)")
        if let index = intervals.firstIndex(where: { $0.id == id }) {
            print("Found interval at index: \(index)")
            print("Old values: \(intervals[index])")
            
            // Update the interval details
            intervals[index].name = name
            intervals[index].startDate = startDate
            intervals[index].frequencyType = frequencyType
            intervals[index].frequencyCount = frequencyCount
            intervals[index].includeTime = includeTime
            
            // Recalculate nextDue date
            intervals[index].updateNextDue()

            print("Updated values: \(intervals[index])")

            // Remove the old notification
            UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: [id.uuidString])
            print("Removed old notification for interval ID: \(id.uuidString)")

            // Schedule the new notification
            scheduleNotification(for: intervals[index])
        } else {
            print("No interval found with ID: \(id)")
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
