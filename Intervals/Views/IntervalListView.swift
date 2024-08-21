import SwiftUI

struct IntervalListView: View {
    @StateObject private var viewModel = IntervalViewModel()
    @State private var showingAddInterval = false
    
    
    var body: some View {
        NavigationView {
            List {
                ForEach(viewModel.intervals) { interval in
                    IntervalRowView(interval: interval)
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
                        showingAddInterval = true
                    }) {
                        Image(systemName: "plus")
                    }
                }
            }
            .sheet(isPresented: $showingAddInterval) {
                AddIntervalView(viewModel: viewModel)
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
    formatter.dateStyle = .short
    formatter.timeStyle = .short
    return formatter
}()
