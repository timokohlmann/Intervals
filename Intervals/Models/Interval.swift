import Foundation

enum FrequencyType: String, CaseIterable, Codable {
    case days = "Days"
    case weeks = "Weeks"
    case months = "Months"
}

enum IntervalStatus: Codable {
    case normal
    case overdue
    case completing
}

struct Interval: Identifiable, Codable {
    let id: UUID
    var name: String
    var startDate: Date
    var frequencyType: FrequencyType
    var frequencyCount: Int
    var lastCompleted: Date?
    var nextDue: Date
    var status: IntervalStatus = .normal

    init(id: UUID = UUID(), name: String, startDate: Date, frequencyType: FrequencyType, frequencyCount: Int) {
        self.id = id
        self.name = name
        self.startDate = startDate
        self.frequencyType = frequencyType
        self.frequencyCount = frequencyCount
        self.nextDue = Self.calculateNextDue(from: startDate, frequencyType: frequencyType, frequencyCount: frequencyCount)
    }

    mutating func markAsCompleted() {
        self.lastCompleted = Date()
        updateNextDue()
        self.status = .normal
    }

    mutating func updateNextDue() {
        let baseDate = max(lastCompleted ?? startDate, Date())
        nextDue = Self.calculateNextDue(from: baseDate, frequencyType: frequencyType, frequencyCount: frequencyCount)
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
        
        var nextDate = calendar.date(byAdding: components, to: date) ?? date
        
        // Ensure the next due date is in the future
        if nextDate <= Date() {
            while nextDate <= Date() {
                nextDate = calendar.date(byAdding: components, to: nextDate) ?? nextDate
            }
        }
        
        return nextDate
    }
}
