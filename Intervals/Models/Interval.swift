import Foundation

struct Interval: Identifiable, Codable {
    let id: UUID
    var name: String
    var startDate: Date
    var frequency: Int
    var lastCompleted: Date?
    var nextDue: Date
    
    init(id: UUID = UUID(), name: String, startDate: Date, frequency: Int) {
        self.id = id
        self.name = name
        self.startDate = startDate
        self.frequency = frequency
        self.nextDue = startDate
    }
    
    mutating func updateNextDue() {
        if let lastCompleted = lastCompleted {
            nextDue = Calendar.current.date(byAdding: .day, value: frequency, to: lastCompleted) ?? startDate
        } else {
            nextDue = Calendar.current.date(byAdding: .day, value: frequency, to: startDate) ?? startDate
        }
    }
    
    mutating func markAsCompleted() {
        lastCompleted = Date()
        updateNextDue()
    }
}
