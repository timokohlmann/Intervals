import SwiftUI

struct IntervalListView: View {
    @StateObject private var viewModel = IntervalViewModel()
    @State private var showingAddInterval = false
    @State private var selectedInterval: Interval?

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
                    .swipeActions(edge: .trailing) {
                        Button(role: .destructive) {
                            viewModel.deleteInterval(interval)
                        } label: {
                            Label("Delete", systemImage: "trash")
                        }
                        
                        Button {
                            viewModel.markIntervalAsCompleted(interval.id)
                        } label: {
                            Label("Complete", systemImage: "checkmark")
                        }
                        .tint(.green)
                    }
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
        
        if interval.includeTime {
            dateFormatter.timeStyle = .short
            return dateFormatter.string(from: interval.nextDue)
        } else {
            return dateFormatter.string(from: interval.nextDue)
        }
    }
}

