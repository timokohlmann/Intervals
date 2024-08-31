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
    var includeTime: Bool
    var status: IntervalStatus = .normal

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
        self.lastCompleted = Date()
        updateNextDue()
        self.status = .normal
    }

    mutating func updateNextDue() {
        print("Updating next due date for \(name)")
        print("Current nextDue: \(nextDue)")
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
        // Use startDate instead of lastCompleted for the initial calculation
        nextDue = calendar.date(byAdding: components, to: startDate) ?? startDate
        // If lastCompleted exists and is after the calculated nextDue, recalculate from lastCompleted
        if let lastCompleted = lastCompleted, lastCompleted > nextDue {
            nextDue = calendar.date(byAdding: components, to: lastCompleted) ?? startDate
        }
        print("Updated nextDue: \(nextDue)")
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
