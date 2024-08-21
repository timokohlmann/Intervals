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
        self.nextDue = Self.calculateNextDue(from: startDate, frequencyType: frequencyType, frequencyCount: frequencyCount)
    }
    mutating func updateNextDue() {
        let baseDate = lastCompleted ?? startDate
        nextDue = Self.calculateNextDue(from: baseDate, frequencyType: frequencyType, frequencyCount: frequencyCount)
    }
    
    mutating func markAsCompleted() {
        lastCompleted = Date()
        updateNextDue()
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
