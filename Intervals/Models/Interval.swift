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
        
        print("Interval initialized:")
        print("Start Date: \(startDate)")
        print("Next Due: \(nextDue)")
    }

    mutating func markAsCompleted() {
        self.lastCompleted = Date()
        updateNextDue()
        self.status = .normal
    }

    mutating func updateNextDue() {
        let now = Date()
        let calendar = Calendar.current
        
        // If the start date is in the past, use it as a reference to calculate the next due date
        if startDate < now {
            var nextDueCandidate = startDate
            while nextDueCandidate <= now {
                nextDueCandidate = Self.calculateNextDue(from: nextDueCandidate, frequencyType: frequencyType, frequencyCount: frequencyCount)
            }
            nextDue = nextDueCandidate
        } else {
            // If the start date is in the future, use it directly
            nextDue = Self.calculateNextDue(from: startDate, frequencyType: frequencyType, frequencyCount: frequencyCount)
        }
        
        print("Next due updated:")
        print("Start Date: \(startDate)")
        print("New Next Due: \(nextDue)")
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
        
        let nextDate = calendar.date(byAdding: components, to: date) ?? date
        
        print("Calculated next due:")
        print("From Date: \(date)")
        print("Next Date: \(nextDate)")
        
        return nextDate
    }
}
