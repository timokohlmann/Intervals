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
                            IntervalRowView(interval: interval, viewModel: viewModel)
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
    @ObservedObject var viewModel: IntervalViewModel

    var body: some View {
        HStack {
            VStack(alignment: .leading) {
                Text(interval.name)
                    .font(.headline)
                Text("Next due: \(formattedNextDue)")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }
            Spacer()
            IntervalStatusView(interval: interval, viewModel: viewModel)
        }
    }

    private var formattedNextDue: String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .medium
        dateFormatter.timeStyle = interval.includeTime ? .short : .none
        return dateFormatter.string(from: interval.nextDue)
    }
}

struct IntervalStatusView: View {
    let interval: Interval
    @ObservedObject var viewModel: IntervalViewModel
    
    @State private var animationAmount: CGFloat = 1

    var body: some View {
        Group {
            switch interval.status {
            case .normal:
                EmptyView()
            case .overdue:
                Image(systemName: "clock.badge.exclamationmark")
                    .foregroundColor(.orange)
                    .onTapGesture {
                        withAnimation(.easeInOut(duration: 0.5)) {
                            animationAmount = 1.5
                            viewModel.markIntervalAsCompleted(interval.id)
                        }
                    }
            case .completing:
                Image(systemName: "checkmark.circle.fill")
                    .foregroundColor(.green)
                    .scaleEffect(animationAmount)
                    .animation(.easeOut(duration: 1), value: animationAmount)
                    .onAppear {
                        animationAmount = 0
                    }
            }
        }
        .font(.title2)
    }
}
