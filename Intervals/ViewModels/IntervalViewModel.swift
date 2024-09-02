import Foundation
import Combine
import UserNotifications
import os

class IntervalViewModel: ObservableObject {
    @Published var intervals: [Interval] = [] {
        didSet {
            saveIntervals()
        }
    }
    @Published var errorMessage: String?

    private let saveKey = "savedIntervals"
    private let logger = Logger(subsystem: "com.timokohlmann.Intervals", category: "IntervalViewModel")
    private var cancellables = Set<AnyCancellable>()

    init() {
        loadIntervals()
        setupPublishers()
    }

    private func setupPublishers() {
        Timer.publish(every: 3, on: .main, in: .common)
            .autoconnect()
            .sink { [weak self] _ in
                self?.checkOverdueIntervals()
            }
            .store(in: &cancellables)
    }

    private func checkOverdueIntervals() {
        let now = Date()
        for index in intervals.indices {
            let interval = intervals[index]
            if interval.nextDue <= now && interval.status == .normal {
                DispatchQueue.main.async {
                    self.intervals[index].status = .overdue
                    self.scheduleNotification(for: self.intervals[index])
                    
                    DispatchQueue.main.asyncAfter(deadline: .now() + 43200) { // 12 hours
                        if self.intervals[index].status == .overdue {
                            self.updateNextDueDate(for: self.intervals[index])
                        }
                    }
                }
            }
        }
    }

    private func updateNextDueDate(for interval: Interval) {
        if let index = intervals.firstIndex(where: { $0.id == interval.id }) {
            intervals[index].updateNextDue()
            scheduleNotification(for: intervals[index])
        }
    }

    private func saveIntervals() {
        do {
            let data = try JSONEncoder().encode(intervals)
            if let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first {
                let fileURL = documentsDirectory.appendingPathComponent(saveKey)
                try data.write(to: fileURL)
            }
        } catch {
            logger.error("Failed to save intervals: \(error.localizedDescription)")
            self.errorMessage = "Failed to save your intervals. Please try again."
        }
    }

    private func loadIntervals() {
        if let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first {
            let fileURL = documentsDirectory.appendingPathComponent(saveKey)
            do {
                let data = try Data(contentsOf: fileURL)
                intervals = try JSONDecoder().decode([Interval].self, from: data)
                checkOverdueIntervals()
            } catch {
                logger.error("Failed to load intervals: \(error.localizedDescription)")
                self.errorMessage = "Failed to load your intervals. Please try restarting the app."
                intervals = []
            }
        }
    }

    func scheduleNotification(for interval: Interval) {
        UNUserNotificationCenter.current().getNotificationSettings { settings in
            switch settings.authorizationStatus {
            case .authorized, .provisional:
                self.createAndScheduleNotification(for: interval)
            case .notDetermined:
                self.requestNotificationPermission { granted in
                    if granted {
                        self.createAndScheduleNotification(for: interval)
                    } else {
                        self.handleNotificationPermissionDenied()
                    }
                }
            case .denied:
                self.handleNotificationPermissionDenied()
            case .ephemeral:
                self.logger.warning("Ephemeral notification authorization status")
                self.createAndScheduleNotification(for: interval)
            @unknown default:
                self.logger.warning("Unknown notification authorization status")
                self.errorMessage = "Unknown notification settings. Please check your device settings."
            }
        }
    }

    private func createAndScheduleNotification(for interval: Interval) {
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
                self.logger.error("Failed to schedule notification: \(error.localizedDescription)")
                self.errorMessage = "Failed to schedule notification. Please check your device settings."
            } else {
                self.logger.info("Successfully scheduled notification for interval: \(interval.name)")
            }
        }
    }

    private func requestNotificationPermission(completion: @escaping (Bool) -> Void) {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge]) { granted, error in
            if let error = error {
                self.logger.error("Error requesting notification permission: \(error.localizedDescription)")
                self.errorMessage = "Failed to request notification permission. Please try again."
                completion(false)
            } else {
                completion(granted)
            }
        }
    }

    private func handleNotificationPermissionDenied() {
        logger.warning("Notification permission denied")
        self.errorMessage = "Notifications are disabled. Please enable them in Settings to receive reminders."
    }

    func addInterval(name: String, startDate: Date, frequencyType: FrequencyType, frequencyCount: Int) {
        let newInterval = Interval(name: name, startDate: startDate, frequencyType: frequencyType, frequencyCount: frequencyCount)
        intervals.append(newInterval)
        scheduleNotification(for: newInterval)
    }

    func updateInterval(id: UUID, name: String, startDate: Date, frequencyType: FrequencyType, frequencyCount: Int) {
        if let index = intervals.firstIndex(where: { $0.id == id }) {
            intervals[index].name = name
            intervals[index].startDate = startDate
            intervals[index].frequencyType = frequencyType
            intervals[index].frequencyCount = frequencyCount
            intervals[index].updateNextDue()

            scheduleNotification(for: intervals[index])
        }
    }

    func deleteInterval(_ interval: Interval) {
        UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: [interval.id.uuidString])
        intervals.removeAll { $0.id == interval.id }
    }

    func markIntervalAsCompleted(_ intervalId: UUID) {
        if let index = intervals.firstIndex(where: { $0.id == intervalId }) {
            intervals[index].status = .completing
            DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                self.intervals[index].markAsCompleted()
                self.updateNextDueDate(for: self.intervals[index])
            }
        }
    }

    func updateAllDueDates() {
        for interval in intervals where interval.status != .overdue {
            updateNextDueDate(for: interval)
        }
    }

    func getOverdueIntervals() -> [Interval] {
        let now = Date()
        return intervals.filter { $0.nextDue < now }
    }
}
