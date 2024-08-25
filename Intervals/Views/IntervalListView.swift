import SwiftUI

struct IntervalListView: View {
    @StateObject private var viewModel = IntervalViewModel()
    @State private var showingAddInterval = false

    var body: some View {
        NavigationView {
            List {
                ForEach(viewModel.intervals) { interval in
                    NavigationLink(
                        destination: AddEditIntervalView(viewModel: viewModel, interval: interval),
                        label: {
                            IntervalRowView(interval: interval)
                        }
                    )
                }
            }
            .navigationTitle("Intervals")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: {
                        showingAddInterval = true
                    }) {
                        Image(systemName: "plus")
                    }
                }
            }
            .sheet(isPresented: $showingAddInterval) {
                AddEditIntervalView(viewModel: viewModel)
            }
        }
    }
}

struct IntervalRowView: View {
    let interval: Interval
    
    var body: some View {
        VStack(alignment: .leading) {
            Text(interval.name)
                .font(.headline)
            Text("Next due: \(formattedNextDue)")
                .font(.subheadline)
                .foregroundColor(.secondary)
        }
    }
    
    private var formattedNextDue: String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .medium
        dateFormatter.timeStyle = interval.includeTime ? .short : .none
        return dateFormatter.string(from: interval.nextDue)
    }
}
