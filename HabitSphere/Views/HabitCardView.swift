import SwiftUI

struct HabitCardView: View {
    var habit: Habit
    var toggleCompletion: () -> Void
    
    @State private var isAnimating: Bool = false
    
    var isCompletedToday: Bool {
        habit.isCompleted(on: Date())
    }
    
    var body: some View {
        HStack(spacing: 16) {
            ZStack {
                Circle()
                    .fill(isCompletedToday ? Color.indigo.opacity(0.2) : Color.gray.opacity(0.1))
                    .frame(width: 50, height: 50)
                
                Image(systemName: habit.icon)
                    .font(.title2)
                    .foregroundColor(isCompletedToday ? .indigo : .primary)
            }
            
            VStack(alignment: .leading, spacing: 4) {
                Text(habit.name)
                    .font(.headline)
                    .strikethrough(isCompletedToday, color: .secondary)
                    .foregroundColor(isCompletedToday ? .secondary : .primary)
                
                HStack(spacing: 8) {
                    Label("\(habit.currentStreak) Day Streak", systemImage: "flame.fill")
                        .font(.caption)
                        .foregroundColor(habit.currentStreak > 0 ? .orange : .secondary)
                    
                    Text("•")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    
                    Text(habit.frequency.rawValue)
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
            
            Spacer()
            
            Image(systemName: isCompletedToday ? "checkmark.circle.fill" : "circle")
                .resizable()
                .frame(width: 28, height: 28)
                .foregroundColor(isCompletedToday ? .indigo : .gray.opacity(0.5))
                .scaleEffect(isAnimating ? 1.2 : 1.0)
                .onTapGesture {
                    withAnimation(.spring(response: 0.3, dampingFraction: 0.6)) {
                        isAnimating = true
                        toggleCompletion()
                    }
                    
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                        isAnimating = false
                    }
                }
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(16)
        .shadow(color: Color.black.opacity(0.05), radius: 8, x: 0, y: 4)
    }
}
