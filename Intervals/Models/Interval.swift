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
    
    init(id: UUID = UUID(), name: String, startDate: Date, frequencyType: FrequencyType, frequencyCount: Int) {
        self.id = id
        self.name = name
        self.startDate = startDate
        self.frequencyType = frequencyType
        self.frequencyCount = frequencyCount
        self.nextDue = startDate
    }
    
    mutating func updateNextDue() {
        let calendar = Calendar.current
        let dateToAddTo = lastCompleted ?? startDate
        let dateComponent: Calendar.Component
        switch frequencyType {
        case .days:
            dateComponent = .day
        case .weeks:
            dateComponent = .weekOfYear
        case .months:
            dateComponent = .month
        }
        nextDue = calendar.date(byAdding: dateComponent, value: frequencyCount, to: dateToAddTo) ?? startDate
    }
    
    mutating func markAsCompleted() {
        lastCompleted = Date()
        updateNextDue()
    }
}
