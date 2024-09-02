import SwiftUI

struct AddEditIntervalView: View {
    @Environment(\.dismiss) var dismiss
    @ObservedObject var viewModel: IntervalViewModel
    @State private var name: String
    @State private var startDate: Date
    @State private var reminderTime: Date
    @State private var frequencyType: FrequencyType
    @State private var frequencyCount: Int
    @State private var intervalId: UUID?
    @State private var showingDeleteConfirmation = false

    init(viewModel: IntervalViewModel, interval: Interval? = nil) {
        self.viewModel = viewModel
        _name = State(initialValue: interval?.name ?? "")
        _startDate = State(initialValue: interval?.startDate.removeTime() ?? Date().removeTime())
        _reminderTime = State(initialValue: interval?.startDate ?? Self.getDefaultReminderTime())
        _frequencyType = State(initialValue: interval?.frequencyType ?? .days)
        _frequencyCount = State(initialValue: interval?.frequencyCount ?? 1)
        _intervalId = State(initialValue: interval?.id)
    }

    var body: some View {
        NavigationView {
            Form {
                TextField("Interval Name", text: $name)
                DatePicker("Start Date", selection: $startDate, displayedComponents: .date)
                DatePicker("Reminder Time", selection: $reminderTime, displayedComponents: .hourAndMinute)
                
                Picker("Frequency Type", selection: $frequencyType) {
                    ForEach(FrequencyType.allCases, id: \.self) { type in
                        Text(type.rawValue).tag(type)
                    }
                }
                
                Stepper(value: $frequencyCount, in: 1...365) {
                    HStack(spacing: 0) {
                        Text("Every ")
                        Text("\(frequencyCount)")
                            .fontWeight(.bold)
                        Text(" \(frequencyType.rawValue.lowercased().dropLast(frequencyCount == 1 ? 1 : 0))")
                    }
                }
                
                if intervalId != nil {
                    Section {
                        Button("Save Changes") {
                            updateInterval()
                        }
                        .foregroundColor(.green)
                        
                        Button("Remove Interval") {
                            showingDeleteConfirmation = true
                        }
                        .foregroundColor(.red)
                    }
                }
            }
            .navigationTitle(intervalId == nil ? "Add Interval" : "Edit Interval")
            .navigationBarTitleDisplayMode(.inline)
            .navigationBarItems(
                leading: intervalId == nil ? Button("Cancel") { dismiss() } : nil,
                trailing: intervalId == nil ? Button("Save") {
                    saveNewInterval()
                }.disabled(name.isEmpty || frequencyCount == 0) : nil
            )
            .alert("Are you sure?", isPresented: $showingDeleteConfirmation) {
                Button("Cancel", role: .cancel) { }
                Button("Delete", role: .destructive) {
                    if let id = intervalId {
                        viewModel.deleteInterval(Interval(id: id, name: "", startDate: Date(), frequencyType: .days, frequencyCount: 1))
                    }
                    dismiss()
                }
            } message: {
                Text("This will permanently remove the interval.")
            }
        }
    }

    private func saveNewInterval() {
        let finalDate = combineDateAndTime(date: startDate, time: reminderTime)
        viewModel.addInterval(name: name, startDate: finalDate, frequencyType: frequencyType, frequencyCount: frequencyCount)
        dismiss()
    }

    private func updateInterval() {
        guard let id = intervalId else { return }
        
        let finalDate = combineDateAndTime(date: startDate, time: reminderTime)
        
        viewModel.updateInterval(id: id, name: name, startDate: finalDate, frequencyType: frequencyType, frequencyCount: frequencyCount)
        dismiss()
    }

    private func combineDateAndTime(date: Date, time: Date) -> Date {
        let calendar = Calendar.current
        let dateComponents = calendar.dateComponents([.year, .month, .day], from: date)
        let timeComponents = calendar.dateComponents([.hour, .minute], from: time)
        
        var combinedComponents = DateComponents()
        combinedComponents.year = dateComponents.year
        combinedComponents.month = dateComponents.month
        combinedComponents.day = dateComponents.day
        combinedComponents.hour = timeComponents.hour
        combinedComponents.minute = timeComponents.minute
        
        return calendar.date(from: combinedComponents) ?? date
    }

    static func getDefaultReminderTime() -> Date {
        let calendar = Calendar.current
        let now = Date()
        let defaultHour = 9
        let defaultMinute = 0
        
        var components = calendar.dateComponents([.year, .month, .day, .hour, .minute], from: now)
        components.hour = defaultHour
        components.minute = defaultMinute
        
        return calendar.date(from: components) ?? now
    }
}

extension Date {
    func removeTime() -> Date {
        let calendar = Calendar.current
        let components = calendar.dateComponents([.year, .month, .day], from: self)
        return calendar.date(from: components) ?? self
    }
}
