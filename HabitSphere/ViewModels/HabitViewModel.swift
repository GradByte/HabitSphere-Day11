import Foundation
import SwiftUI

@Observable
class HabitViewModel {
    var habits: [Habit] = []
    private let storage = HabitStorage()
    
    init() {
        loadHabits()
    }
    
    func loadHabits() {
        habits = storage.load()
    }
    
    private func saveHabits() {
        storage.save(habits: habits)
    }
    
    func addHabit(name: String, icon: String, frequency: HabitFrequency = .daily) {
        let newHabit = Habit(name: name, icon: icon, frequency: frequency, createdAt: Date())
        habits.append(newHabit)
        saveHabits()
    }
    
    func toggleHabit(_ habit: Habit, on date: Date = Date()) {
        if let index = habits.firstIndex(where: { $0.id == habit.id }) {
            habits[index].toggleCompletion(on: date)
            saveHabits()
        }
    }
    
    func deleteHabit(_ habit: Habit) {
        habits.removeAll { $0.id == habit.id }
        saveHabits()
    }
    
    /// Returns the percentage of habits completed today (0.0 to 1.0)
    var todayProgress: Double {
        guard !habits.isEmpty else { return 0 }
        let completedToday = habits.filter { $0.isCompleted(on: Date()) }.count
        return Double(completedToday) / Double(habits.count)
    }
    
    var totalHabits: Int {
        habits.count
    }
    
    var longestStreakOverall: Int {
        habits.map { $0.longestStreak }.max() ?? 0
    }
    
    /// Returns the number of completed habits on a specific date
    func completionCount(for date: Date) -> Int {
        habits.filter { $0.isCompleted(on: date) }.count
    }
}
