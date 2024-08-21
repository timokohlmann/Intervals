import SwiftUI


struct AddEditIntervalView: View {
    @Environment(\.dismiss) var dismiss
    @ObservedObject var viewModel: IntervalViewModel
    @State private var name: String
    @State private var startDate: Date
    @State private var includeTime: Bool
    @State private var startTime: Date
    @State private var frequencyType: FrequencyType
    @State private var frequencyCount: Int
    @State private var intervalId: UUID?
    @State private var showingDeleteConfirmation = false

    init(viewModel: IntervalViewModel, interval: Interval? = nil) {
        self.viewModel = viewModel
        _name = State(initialValue: interval?.name ?? "")
        _startDate = State(initialValue: interval?.startDate.removeTimeIfMidnight() ?? Date())
        _includeTime = State(initialValue: {
            if let interval = interval {
                let midnightDate = interval.startDate.removeTimeIfMidnight()
                return !midnightDate.timeIntervalSince(interval.startDate).isZero
            }
            return false
        }())
        _startTime = State(initialValue: interval?.startDate ?? Date())
        _frequencyType = State(initialValue: interval?.frequencyType ?? .days)
        _frequencyCount = State(initialValue: interval?.frequencyCount ?? 1)
        _intervalId = State(initialValue: interval?.id)
    }

    var body: some View {
        NavigationView {
            Form {
                TextField("Interval Name", text: $name)
                
                DatePicker("Start Date", selection: $startDate, displayedComponents: .date)
                
                Toggle("Include Time", isOn: $includeTime)
                
                if includeTime {
                    DatePicker("Start Time", selection: $startTime, displayedComponents: .hourAndMinute)
                }
                
                Picker("Frequency Type", selection: $frequencyType) {
                    ForEach(FrequencyType.allCases, id: \.self) { type in
                        Text(type.rawValue).tag(type)
                    }
                }
                
                Stepper("Every \(frequencyCount) \(frequencyType.rawValue.lowercased())", value: $frequencyCount, in: 1...365)
                
                if intervalId != nil {
                    Section {
                        Button("Remove Interval") {
                            showingDeleteConfirmation = true
                        }
                        .foregroundColor(.red)
                    }
                }
            }
            .navigationTitle(intervalId == nil ? "Add Interval" : "Edit Interval")
            .navigationBarItems(
                leading: Button("Cancel") { dismiss() },
                trailing: Button("Save") {
                    let finalDate = includeTime ? startDate.setting(time: startTime) : startDate
                    if let id = intervalId {
                        viewModel.updateInterval(id: id, name: name, startDate: finalDate, frequencyType: frequencyType, frequencyCount: frequencyCount)
                    } else {
                        viewModel.addInterval(name: name, startDate: finalDate, frequencyType: frequencyType, frequencyCount: frequencyCount)
                    }
                    dismiss()
                }
                .disabled(name.isEmpty || frequencyCount == 0)
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
}

extension Date {
    func removeTimeIfMidnight() -> Date {
        let components = Calendar.current.dateComponents([.hour, .minute, .second], from: self)
        if components.hour == 0 && components.minute == 0 && components.second == 0 {
            return Calendar.current.startOfDay(for: self)
        }
        return self
    }
    
    func setting(time: Date) -> Date {
        let calendar = Calendar.current
        let timeComponents = calendar.dateComponents([.hour, .minute], from: time)
        var components = calendar.dateComponents([.year, .month, .day], from: self)
        components.hour = timeComponents.hour
        components.minute = timeComponents.minute
        return calendar.date(from: components) ?? self
    }
}
