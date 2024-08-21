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

    init(viewModel: IntervalViewModel, interval: Interval? = nil) {
        self.viewModel = viewModel
        _name = State(initialValue: interval?.name ?? "")
        _startDate = State(initialValue: interval?.startDate.dateComponents ?? Date())
        _includeTime = State(initialValue: interval?.startDate.hasTimeComponents ?? false)
        _startTime = State(initialValue: interval?.startDate.timeComponents ?? Date())
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
            }
            .navigationTitle(intervalId == nil ? "Add Interval" : "Edit Interval")
            .navigationBarItems(
                leading: Button("Cancel") { dismiss() },
                trailing: Button("Save") {
                    let finalDate = includeTime ? startDate.setting(time: startTime) : startDate.removingTimeComponents
                    if let id = intervalId {
                        viewModel.updateInterval(id: id, name: name, startDate: finalDate, frequencyType: frequencyType, frequencyCount: frequencyCount)
                    } else {
                        viewModel.addInterval(name: name, startDate: finalDate, frequencyType: frequencyType, frequencyCount: frequencyCount)
                    }
                    dismiss()
                }
                .disabled(name.isEmpty || frequencyCount == 0)
            )
        }
    }
}

extension Date {
    var dateComponents: Date {
        let components = Calendar.current.dateComponents([.year, .month, .day], from: self)
        return Calendar.current.date(from: components) ?? self
    }
    
    var timeComponents: Date {
        let components = Calendar.current.dateComponents([.hour, .minute], from: self)
        return Calendar.current.date(from: components) ?? self
    }
    
    var hasTimeComponents: Bool {
        let components = Calendar.current.dateComponents([.hour, .minute], from: self)
        return components.hour != 0 || components.minute != 0
    }
    
    var removingTimeComponents: Date {
        let components = Calendar.current.dateComponents([.year, .month, .day], from: self)
        return Calendar.current.date(from: components) ?? self
    }
    
    func setting(time: Date) -> Date {
        let timeComponents = Calendar.current.dateComponents([.hour, .minute], from: time)
        var selfComponents = Calendar.current.dateComponents([.year, .month, .day], from: self)
        selfComponents.hour = timeComponents.hour
        selfComponents.minute = timeComponents.minute
        return Calendar.current.date(from: selfComponents) ?? self
    }
}
