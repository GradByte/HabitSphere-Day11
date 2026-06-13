import SwiftUI

struct InsightsView: View {
    @Environment(HabitViewModel.self) private var viewModel
    
    // Create an array of the last 30 days
    var last30Days: [Date] {
        let calendar = Calendar.current
        let today = Date()
        return (0..<30).reversed().compactMap {
            calendar.date(byAdding: .day, value: -$0, to: today)
        }
    }
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 24) {
                    
                    // Stats Grid
                    LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 16) {
                        StatCard(title: "Total Habits", value: "\(viewModel.totalHabits)", icon: "list.bullet.clipboard")
                        StatCard(title: "Longest Streak", value: "\(viewModel.longestStreakOverall)", icon: "flame.fill", color: .orange)
                    }
                    .padding(.horizontal)
                    
                    // Contribution Graph
                    VStack(alignment: .leading, spacing: 12) {
                        Text("30-Day Activity")
                            .font(.headline)
                        
                        LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 4), count: 7), spacing: 8) {
                            ForEach(last30Days, id: \.self) { date in
                                let count = viewModel.completionCount(for: date)
                                // Adjust intensity based on number of habits completed
                                let intensity = count > 0 ? min(Double(count) / max(1.0, Double(viewModel.totalHabits)), 1.0) : 0
                                
                                RoundedRectangle(cornerRadius: 4)
                                    .fill(count > 0 ? Color.indigo.opacity(intensity * 0.8 + 0.2) : Color.gray.opacity(0.15))
                                    .aspectRatio(1, contentMode: .fit)
                            }
                        }
                    }
                    .padding()
                    .background(Color(.systemBackground))
                    .cornerRadius(16)
                    .shadow(color: Color.black.opacity(0.05), radius: 8, x: 0, y: 4)
                    .padding(.horizontal)
                }
                .padding(.vertical)
            }
            .background(Color(.systemGroupedBackground).ignoresSafeArea())
            .navigationTitle("Insights")
        }
    }
}

struct StatCard: View {
    var title: String
    var value: String
    var icon: String
    var color: Color = .indigo
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Image(systemName: icon)
                    .foregroundColor(color)
                    .font(.title3)
                Spacer()
            }
            
            VStack(alignment: .leading, spacing: 4) {
                Text(value)
                    .font(.system(size: 32, weight: .bold, design: .rounded))
                Text(title)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(16)
        .shadow(color: Color.black.opacity(0.05), radius: 8, x: 0, y: 4)
    }
}
