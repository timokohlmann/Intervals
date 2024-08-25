import Foundation
import Combine
import UserNotifications

class IntervalViewModel: ObservableObject {
    @Published var intervals: [Interval] = [] {
        didSet {
            saveIntervals()
        }
    }
    
    private let saveKey = "savedIntervals"
    
    init() {
        loadIntervals()
    }
    
    private func saveIntervals() {
        do {
            let data = try JSONEncoder().encode(intervals)
            if let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first {
                let fileURL = documentsDirectory.appendingPathComponent(saveKey)
                try data.write(to: fileURL)
            }
        } catch {
            print("Failed to save intervals: \(error)")
        }
    }
    
    private func loadIntervals() {
        if let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first {
            let fileURL = documentsDirectory.appendingPathComponent(saveKey)
            do {
                let data = try Data(contentsOf: fileURL)
                intervals = try JSONDecoder().decode([Interval].self, from: data)
            } catch {
                print("Failed to load intervals: \(error)")
                intervals = []
            }
        }
    }
    
    func scheduleNotification(for interval: Interval) {
        let content = UNMutableNotificationContent()
        content.title = "Task Due: \(interval.name)"
        content.body = "It's time to complete your task."
        content.sound = .default

        let triggerDate = Calendar.current.dateComponents([.year, .month, .day, .hour, .minute], from: interval.nextDue)
        let trigger = UNCalendarNotificationTrigger(dateMatching: triggerDate, repeats: false)
        let request = UNNotificationRequest(identifier: interval.id.uuidString, content: content, trigger: trigger)

        UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: [interval.id.uuidString])
        
        UNUserNotificationCenter.current().add(request) { error in
            if let error = error {
                print("Failed to schedule notification: \(error.localizedDescription)")
            }
        }
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
