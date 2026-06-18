import SwiftUI
import Charts

struct HabitDetailedAnalyticsView: View {
    @Environment(HabitViewModel.self) private var viewModel
    var habit: Habit
    
    // Derived state for the specific habit inside the view model
    var latestHabit: Habit {
        viewModel.habits.first(where: { $0.id == habit.id }) ?? habit
    }
    
    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                
                // Progress to Goal
                VStack(alignment: .leading, spacing: 8) {
                    Text("Goal Progress")
                        .font(.headline)
                    
                    ProgressView(
                        value: Double(latestHabit.completionHistory.count),
                        total: Double(latestHabit.targetCompletionCount)
                    )
                    .tint(.indigo)
                    .scaleEffect(x: 1, y: 2, anchor: .center)
                    .padding(.vertical, 8)
                    
                    HStack {
                        Text("\(latestHabit.completionHistory.count) Completions")
                        Spacer()
                        Text("Target: \(latestHabit.targetCompletionCount)")
                    }
                    .font(.caption)
                    .foregroundColor(.secondary)
                    
                    if let velocity = viewModel.completionVelocity(for: latestHabit) {
                        Text("At your current rate, you'll reach your goal in **\(velocity) days**.")
                            .font(.subheadline)
                            .padding(.top, 4)
                    }
                }
                .padding()
                .background(Color(.systemBackground))
                .cornerRadius(16)
                .shadow(color: Color.black.opacity(0.05), radius: 8)
                
                // Weekday Consistency Chart
                VStack(alignment: .leading, spacing: 16) {
                    Text("Weekday Consistency")
                        .font(.headline)
                    
                    let breakdown = viewModel.weekdayConsistencyBreakdown(for: latestHabit)
                    
                    Chart(breakdown, id: \.weekday) { item in
                        BarMark(
                            x: .value("Day", item.weekday),
                            y: .value("Percentage", item.percentage * 100)
                        )
                        .foregroundStyle(Color.indigo.gradient)
                        .cornerRadius(4)
                    }
                    .frame(height: 200)
                    .chartYAxis {
                        AxisMarks(position: .leading, values: [0, 25, 50, 75, 100]) { value in
                            AxisValueLabel {
                                if let intValue = value.as(Int.self) {
                                    Text("\(intValue)%")
                                }
                            }
                        }
                    }
                }
                .padding()
                .background(Color(.systemBackground))
                .cornerRadius(16)
                .shadow(color: Color.black.opacity(0.05), radius: 8)
                
                // Time of Day
                VStack(alignment: .leading, spacing: 8) {
                    Text("Optimal Time")
                        .font(.headline)
                    
                    HStack {
                        Image(systemName: "clock.fill")
                            .foregroundColor(.indigo)
                            .font(.title2)
                        
                        Text(viewModel.bestPerformingTimeOfDay(for: latestHabit).rawValue)
                            .font(.title3)
                            .fontWeight(.semibold)
                        
                        Spacer()
                    }
                    
                    Text("You tend to complete this habit most frequently during the \(viewModel.bestPerformingTimeOfDay(for: latestHabit).rawValue.lowercased()).")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
                .padding()
                .background(Color(.systemBackground))
                .cornerRadius(16)
                .shadow(color: Color.black.opacity(0.05), radius: 8)
                
            }
            .padding()
        }
        .background(Color(.systemGroupedBackground).ignoresSafeArea())
        .navigationTitle(latestHabit.name)
        .navigationBarTitleDisplayMode(.inline)
    }
}
