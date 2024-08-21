import SwiftUI

struct AddIntervalView: View {
    @Environment(\.dismiss) var dismiss
    @ObservedObject var viewModel: IntervalViewModel
    
    @State private var name = ""
    @State private var startDate = Date()
    @State private var frequencyType = FrequencyType.days
    @State private var frequencyCount = 1
    
    var body: some View {
        NavigationView {
            Form {
                TextField("Interval Name", text: $name)
                
                DatePicker("Start Date", selection: $startDate, in: ...Date(), displayedComponents: .date)
                
                Picker("Frequency Type", selection: $frequencyType) {
                    ForEach(FrequencyType.allCases, id: \.self) { type in
                        Text(type.rawValue).tag(type)
                    }
                }
                
                Stepper("Every \(frequencyCount) \(frequencyType.rawValue.lowercased())", value: $frequencyCount, in: 1...365)
            }
            .navigationTitle("Add Interval")
            .navigationBarItems(
                leading: Button("Cancel") { dismiss() },
                trailing: Button("Save") {
                    viewModel.addInterval(name: name, startDate: startDate, frequencyType: frequencyType, frequencyCount: frequencyCount)
                    dismiss()
                }
                .disabled(name.isEmpty)
            )
        }
    }
}
