import Foundation

enum HabitFrequency: String, Codable, CaseIterable {
    case daily = "Daily"
    case weekdays = "Weekdays"
    case weekends = "Weekends"
}


/// Represents a single habit to be tracked.
struct Habit: Identifiable, Codable, Hashable {
    var id: UUID = UUID()
    var name: String
    var icon: String // SF Symbol name
    var frequency: HabitFrequency = .daily
    var createdAt: Date
    
    /// Stores the dates when the habit was completed in "yyyy-MM-dd" format
    var completedDates: Set<String> = []
    
    /// Calculate the current streak based on continuous days completed up to today or yesterday
    var currentStreak: Int {
        var streak = 0
        let calendar = Calendar.current
        var checkDate = Date()
        
        // If today is not completed, we should check if yesterday was completed to see if the streak is still alive
        if !isCompleted(on: checkDate) {
            checkDate = calendar.date(byAdding: .day, value: -1, to: checkDate) ?? Date()
        }
        
        while isCompleted(on: checkDate) {
            streak += 1
            checkDate = calendar.date(byAdding: .day, value: -1, to: checkDate) ?? Date()
        }
        
        return streak
    }
    
    var longestStreak: Int {
        // Compute longest consecutive days
        guard !completedDates.isEmpty else { return 0 }
        
        let sortedDates = completedDates.compactMap { DateFormatter.habitDateFormatter.date(from: $0) }.sorted()
        guard !sortedDates.isEmpty else { return 0 }
        
        var maxStreak = 1
        var currentS = 1
        let calendar = Calendar.current
        
        for i in 1..<sortedDates.count {
            let previous = calendar.startOfDay(for: sortedDates[i-1])
            let current = calendar.startOfDay(for: sortedDates[i])
            let daysBetween = calendar.dateComponents([.day], from: previous, to: current).day ?? 0
            
            if daysBetween == 1 {
                currentS += 1
                maxStreak = max(maxStreak, currentS)
            } else if daysBetween > 1 {
                currentS = 1
            }
        }
        
        return maxStreak
    }
    
    func isCompleted(on date: Date) -> Bool {
        let dateString = DateFormatter.habitDateFormatter.string(from: date)
        return completedDates.contains(dateString)
    }
    
    mutating func toggleCompletion(on date: Date) {
        let dateString = DateFormatter.habitDateFormatter.string(from: date)
        if completedDates.contains(dateString) {
            completedDates.remove(dateString)
        } else {
            completedDates.insert(dateString)
        }
    }
}

extension DateFormatter {
    static let habitDateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        return formatter
    }()
}
