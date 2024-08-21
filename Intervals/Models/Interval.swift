import Foundation

enum FrequencyType: String, CaseIterable, Codable {
    case days = "Days"
    case weeks = "Weeks"
    case months = "Months"
}

struct Interval: Identifiable, Codable {
    let id: UUID
    var name: String
    var startDate: Date
    var frequencyType: FrequencyType
    var frequencyCount: Int
    var lastCompleted: Date?
    var nextDue: Date
    var includeTime: Bool

    init(id: UUID = UUID(), name: String, startDate: Date, frequencyType: FrequencyType, frequencyCount: Int, includeTime: Bool) {
        self.id = id
        self.name = name
        self.startDate = startDate
        self.frequencyType = frequencyType
        self.frequencyCount = frequencyCount
        self.includeTime = includeTime
        self.nextDue = startDate // Initial calculation of nextDue
    }

    mutating func markAsCompleted() {
        // Mark the interval as completed
        self.lastCompleted = Date()
        updateNextDue()
    }

    mutating func updateNextDue() {
        let baseDate = lastCompleted ?? startDate
        self.nextDue = Self.calculateNextDue(from: baseDate, frequencyType: frequencyType, frequencyCount: frequencyCount)
    }

    static func calculateNextDue(from date: Date, frequencyType: FrequencyType, frequencyCount: Int) -> Date {
        let calendar = Calendar.current
        let components: DateComponents
        
        switch frequencyType {
        case .days:
            components = DateComponents(day: frequencyCount)
        case .weeks:
            components = DateComponents(day: frequencyCount * 7)
        case .months:
            components = DateComponents(month: frequencyCount)
        }

        return calendar.date(byAdding: components, to: date) ?? date
    }
}
