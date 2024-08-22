import SwiftUI

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
        _startDate = State(initialValue: interval?.startDate.removeTime() ?? Date())
        _includeTime = State(initialValue: interval?.includeTime ?? false)
        _startTime = State(initialValue: interval?.startDate ?? Date())
        _frequencyType = State(initialValue: interval?.frequencyType ?? .days)
        _frequencyCount = State(initialValue: interval?.frequencyCount ?? 1)
        _intervalId = State(initialValue: interval?.id)
        
        print("Initializing AddEditIntervalView with interval: \(interval?.name ?? "New Interval")")
    }

    var body: some View {
        NavigationView {
            Form {
                TextField("Interval Name", text: $name)
                
                DatePicker("Start Date", selection: $startDate, displayedComponents: .date)
                
                Toggle("Include Time", isOn: $includeTime)
                
                if includeTime {
                    DatePicker("Start Time", selection: $startTime, displayedComponents: .hourAndMinute)
                        .onChange(of: startTime) { newValue in
                            print("Start time changed to: \(newValue)")
                        }
                }
                
                Picker("Frequency Type", selection: $frequencyType) {
                    ForEach(FrequencyType.allCases, id: \.self) { type in
                        Text(type.rawValue).tag(type)
                    }
                }
                
                Stepper("Every \(frequencyCount) \(frequencyType.rawValue.lowercased())", value: $frequencyCount, in: 1...365)
                
                if intervalId != nil {
                    Section {
                        Button("Update Interval") {
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
                        viewModel.deleteInterval(Interval(id: id, name: "", startDate: Date(), frequencyType: .days, frequencyCount: 1, includeTime: false))
                    }
                    dismiss()
                }
            } message: {
                Text("This will permanently remove the interval.")
            }
        }
    }

    private func saveNewInterval() {
        print("saveNewInterval called")
        
        let finalDate = includeTime ? startDate.setting(time: startTime) : startDate.removeTime()

        let dateFormatter = DateFormatter()
        dateFormatter.timeZone = TimeZone.current
        dateFormatter.dateStyle = .medium
        dateFormatter.timeStyle = .short
        let localDateString = dateFormatter.string(from: finalDate)
        print("Final local date to be saved: \(localDateString)")
        
        viewModel.addInterval(name: name, startDate: finalDate, frequencyType: frequencyType, frequencyCount: frequencyCount, includeTime: includeTime)
        print("New interval added: \(name), Next due: \(finalDate)")
        dismiss()
    }

    private func updateInterval() {
        print("updateInterval called")
        guard let id = intervalId else {
            print("Error: No interval ID found for update")
            return
        }
        let finalDate = includeTime ? startDate.setting(time: startTime) : startDate.removeTime()
        
        let dateFormatter = DateFormatter()
        dateFormatter.timeZone = TimeZone.current
        dateFormatter.dateStyle = .medium
        dateFormatter.timeStyle = .short
        let localDateString = dateFormatter.string(from: finalDate)
        print("Updating interval: \(name)")
        print("New start date: \(localDateString)")
        print("Frequency: Every \(frequencyCount) \(frequencyType.rawValue.lowercased())")
        print("Include time: \(includeTime)")
        
        viewModel.updateInterval(id: id, name: name, startDate: finalDate, frequencyType: frequencyType, frequencyCount: frequencyCount, includeTime: includeTime)
        dismiss()
    }
}

extension Date {
    func removeTime() -> Date {
        let components = Calendar.current.dateComponents([.year, .month, .day], from: self)
        return Calendar.current.date(from: components) ?? self
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
