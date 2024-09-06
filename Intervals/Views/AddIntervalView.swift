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

    private let titlePrefix = "Title: "

    private var isEditMode: Bool {
        intervalId != nil
    }

    init(viewModel: IntervalViewModel, interval: Interval? = nil) {
        self.viewModel = viewModel
        _name = State(initialValue: interval?.name ?? "")
        _startDate = State(initialValue: interval?.startDate.removeTime() ?? Date().removeTime())
        _reminderTime = State(initialValue: interval?.startDate.extractTime() ?? Self.getDefaultReminderTime())
        _frequencyType = State(initialValue: interval?.frequencyType ?? .days)
        _frequencyCount = State(initialValue: interval?.frequencyCount ?? 1)
        _intervalId = State(initialValue: interval?.id)
        
        print("Init AddEditIntervalView:")
        print("Initial startDate: \(interval?.startDate.removeTime() ?? Date().removeTime())")
        print("Initial reminderTime: \(interval?.startDate.extractTime() ?? Self.getDefaultReminderTime())")
    }

    var body: some View {
        NavigationView {
            Form {
                if isEditMode {
                    NextDueSection(interval: viewModel.intervals.first(where: { $0.id == intervalId }))
                }
                
                if isEditMode {
                    HStack {
                        Text(titlePrefix)
                        TextField("", text: $name)
                    }
                } else {
                    TextField("Interval Title", text: $name)
                }
                
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
                
                if isEditMode {
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
            .navigationTitle(isEditMode ? "Edit Interval" : "Add Interval")
            .navigationBarTitleDisplayMode(.inline)
            .navigationBarItems(
                leading: isEditMode ? nil : Button("Cancel") { dismiss() },
                trailing: isEditMode ? nil : Button("Save") {
                    saveNewInterval()
                }.disabled(name.isEmpty || frequencyCount == 0)
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
        print("Saving new interval:")
        print("Start Date before combine: \(startDate)")
        print("Reminder Time before combine: \(reminderTime)")
        
        let finalDate = combineDateAndTime(date: startDate, time: reminderTime)
        
        print("Final Date after combine: \(finalDate)")
        
        viewModel.addInterval(name: name, startDate: finalDate, frequencyType: frequencyType, frequencyCount: frequencyCount)
        dismiss()
    }

    private func updateInterval() {
        guard let id = intervalId else { return }
        
        print("Updating interval:")
        print("Start Date before combine: \(startDate)")
        print("Reminder Time before combine: \(reminderTime)")
        
        let finalDate = combineDateAndTime(date: startDate, time: reminderTime)
        
        print("Final Date after combine: \(finalDate)")
        
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
        
        let result = calendar.date(from: combinedComponents) ?? date
        
        print("Combining date and time:")
        print("Input Date: \(date)")
        print("Input Time: \(time)")
        print("Result: \(result)")
        
        return result
    }

    static func getDefaultReminderTime() -> Date {
        let calendar = Calendar.current
        var components = DateComponents()
        components.hour = 9
        components.minute = 0
        return calendar.date(from: components) ?? Date()
    }
}

struct NextDueSection: View {
    let interval: Interval?
    
    var body: some View {
        if let interval = interval {
            Section {
                VStack(alignment: .leading, spacing: 8) {
                    Text("Next Due")
                        .font(.headline)
                        .foregroundColor(.secondary)
                    Text(interval.nextDue, style: .date)
                        .font(.title2)
                        .fontWeight(.bold)
                    Text(interval.nextDue, style: .time)
                        .font(.title3)
                }
                .padding(.vertical, 8)
            }
        }
    }
}

extension Date {
    func removeTime() -> Date {
        let calendar = Calendar.current
        let components = calendar.dateComponents([.year, .month, .day], from: self)
        return calendar.date(from: components) ?? self
    }
    
    func extractTime() -> Date {
        let calendar = Calendar.current
        let components = calendar.dateComponents([.hour, .minute], from: self)
        return calendar.date(from: components) ?? self
    }
}
