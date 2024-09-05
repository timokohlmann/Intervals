import SwiftUI

struct IntervalListView: View {
    @StateObject private var viewModel = IntervalViewModel()
    @State private var showingAddInterval = false
    @State private var currentTime = Date()

    let timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()

    var body: some View {
        NavigationView {
            List {
                ForEach(viewModel.intervals) { interval in
                    NavigationLink(
                        destination: AddEditIntervalView(viewModel: viewModel, interval: interval),
                        label: {
                            IntervalRowView(interval: interval, viewModel: viewModel, currentTime: currentTime)
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
        .onReceive(timer) { _ in
            self.currentTime = Date()
        }
    }
}

struct IntervalRowView: View {
    let interval: Interval
    @ObservedObject var viewModel: IntervalViewModel
    let currentTime: Date

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
            IntervalStatusView(interval: interval, viewModel: viewModel, currentTime: currentTime)
        }
    }

    private var formattedNextDue: String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .medium
        dateFormatter.timeStyle = .short
        return dateFormatter.string(from: interval.nextDue)
    }
}

struct IntervalStatusView: View {
    let interval: Interval
    @ObservedObject var viewModel: IntervalViewModel
    let currentTime: Date
    
    @State private var animationAmount: CGFloat = 1

    var body: some View {
        Group {
            if shouldShowOverdueIcon {
                Image(systemName: "clock.badge.exclamationmark")
                    .foregroundColor(.orange)
                    .onTapGesture {
                        withAnimation(.easeInOut(duration: 0.5)) {
                            animationAmount = 1.5
                            viewModel.markIntervalAsCompleted(interval.id)
                        }
                    }
            } else if interval.status == .completing {
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
    
    private var shouldShowOverdueIcon: Bool {
        guard interval.status == .overdue else { return false }
        guard let becameOverdueAt = interval.becameOverdueAt else { return true }
        return currentTime.timeIntervalSince(becameOverdueAt) < viewModel.autoUpdateDelay
    }
}
