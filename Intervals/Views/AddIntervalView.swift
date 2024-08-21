import SwiftUI

struct AddIntervalView: View {
    @Environment(\.dismiss) var dismiss
    @ObservedObject var viewModel: IntervalViewModel
    
    @State private var name = ""
    @State private var startDate = Date()
    @State private var frequency = 1
    
    var body: some View {
        NavigationView {
            Form {
                TextField("Interval Name", text: $name)
                DatePicker("Start Date", selection: $startDate, displayedComponents: .date)
                Stepper("Frequency: \(frequency) day(s)", value: $frequency, in: 1...365)
            }
            .navigationTitle("Add Interval")
            .navigationBarItems(
                leading: Button("Cancel") { dismiss() },
                trailing: Button("Save") {
                    viewModel.addInterval(name: name, startDate: startDate, frequency: frequency)
                    dismiss()
                }
                .disabled(name.isEmpty)
            )
        }
    }
}
