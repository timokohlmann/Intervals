import SwiftUI

struct IntervalListView: View {
    @StateObject private var viewModel = IntervalViewModel()
    @State private var showingAddEditInterval = false
    @State private var selectedInterval: Interval?

    var body: some View {
        NavigationView {
            List {
                ForEach(viewModel.intervals) { interval in
                    IntervalRowView(interval: interval)
                        .onTapGesture {
                            selectedInterval = interval
                            showingAddEditInterval = true
                        }
                        .swipeActions {
                            Button("Complete") {
                                viewModel.markIntervalAsCompleted(interval.id)
                            }
                            .tint(.green)
                            
                            Button("Delete", role: .destructive) {
                                viewModel.deleteInterval(interval)
                            }
                        }
                }
            }
            .navigationTitle("Intervals")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: {
                        selectedInterval = nil
                        showingAddEditInterval = true
                    }) {
                        Image(systemName: "plus")
                    }
                }
            }
            .sheet(isPresented: $showingAddEditInterval) {
                AddEditIntervalView(viewModel: viewModel, interval: selectedInterval)
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
            Text("Next due: \(interval.nextDue, formatter: itemFormatter)")
                .font(.subheadline)
                .foregroundColor(.secondary)
        }
    }
}

private let itemFormatter: DateFormatter = {
    let formatter = DateFormatter()
    formatter.dateStyle = .medium
    formatter.timeStyle = .short
    return formatter
}()
