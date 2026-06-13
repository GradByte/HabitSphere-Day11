import Foundation
import SwiftUI
import UserNotifications

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
    
    func addHabit(name: String, icon: String, frequency: HabitFrequency = .daily, targetCompletionCount: Int = 100, preferredReminderTime: Date? = nil) {
        let newHabit = Habit(
            name: name,
            icon: icon,
            frequency: frequency,
            createdAt: Date(),
            targetCompletionCount: targetCompletionCount,
            preferredReminderTime: preferredReminderTime,
            completionHistory: []
        )
        habits.append(newHabit)
        saveHabits()
        
        if let reminderTime = preferredReminderTime {
            scheduleReminder(for: newHabit, at: reminderTime)
        }
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
        UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: [habit.id.uuidString])
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
    
    // MARK: - Advanced Analytics
    
    func weekdayConsistencyBreakdown(for habit: Habit) -> [(weekday: String, percentage: Double)] {
        let calendar = Calendar.current
        var counts: [Int: Int] = [:] // weekday -> count
        
        for date in habit.completionHistory {
            let weekday = calendar.component(.weekday, from: date)
            counts[weekday, default: 0] += 1
        }
        
        let total = max(1, habit.completionHistory.count)
        let symbols = calendar.shortWeekdaySymbols
        
        return (1...7).map { weekday in
            let percentage = Double(counts[weekday] ?? 0) / Double(total)
            return (weekday: symbols[weekday - 1], percentage: percentage)
        }
    }
    
    /// Returns the global most productive day of the week
    func globalMostProductiveDay() -> String {
        let calendar = Calendar.current
        var counts: [Int: Int] = [:]
        
        for habit in habits {
            for date in habit.completionHistory {
                let weekday = calendar.component(.weekday, from: date)
                counts[weekday, default: 0] += 1
            }
        }
        
        guard let best = counts.max(by: { $0.value < $1.value })?.key else {
            return "N/A"
        }
        
        return calendar.weekdaySymbols[best - 1]
    }
    
    /// Classifies time of day into Morning, Afternoon, Evening
    enum TimeOfDay: String {
        case morning = "Morning"
        case afternoon = "Afternoon"
        case evening = "Evening"
        case night = "Night"
        case unknown = "N/A"
    }
    
    func bestPerformingTimeOfDay(for habit: Habit? = nil) -> TimeOfDay {
        let calendar = Calendar.current
        var counts: [TimeOfDay: Int] = [:]
        
        let targetHabits = habit != nil ? [habit!] : habits
        
        for h in targetHabits {
            for date in h.completionHistory {
                let hour = calendar.component(.hour, from: date)
                let tod: TimeOfDay
                switch hour {
                case 5..<12: tod = .morning
                case 12..<17: tod = .afternoon
                case 17..<22: tod = .evening
                default: tod = .night
                }
                counts[tod, default: 0] += 1
            }
        }
        
        return counts.max(by: { $0.value < $1.value })?.key ?? .unknown
    }
    
    func completionVelocity(for habit: Habit) -> Int? {
        guard habit.completionHistory.count > 1 else { return nil }
        
        let sortedDates = habit.completionHistory.sorted()
        guard let first = sortedDates.first, let last = sortedDates.last else { return nil }
        
        let calendar = Calendar.current
        let daysPassed = max(1, calendar.dateComponents([.day], from: first, to: last).day ?? 1)
        
        let ratePerDay = Double(habit.completionHistory.count) / Double(daysPassed)
        guard ratePerDay > 0 else { return nil }
        
        let remaining = max(0, habit.targetCompletionCount - habit.completionHistory.count)
        return Int(Double(remaining) / ratePerDay)
    }
    
    // MARK: - Notifications
    
    func requestNotificationPermission() {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge]) { granted, error in
            if granted {
                print("Notification permission granted.")
            } else if let error = error {
                print("Notification permission error: \(error.localizedDescription)")
            }
        }
    }
    
    private func scheduleReminder(for habit: Habit, at time: Date) {
        let content = UNMutableNotificationContent()
        content.title = "Time for \(habit.name)!"
        content.body = "Don't forget to complete your habit to keep your streak alive."
        content.sound = .default
        
        let calendar = Calendar.current
        let components = calendar.dateComponents([.hour, .minute], from: time)
        
        let trigger = UNCalendarNotificationTrigger(dateMatching: components, repeats: true)
        let request = UNNotificationRequest(identifier: habit.id.uuidString, content: content, trigger: trigger)
        
        UNUserNotificationCenter.current().add(request) { error in
            if let error = error {
                print("Failed to schedule notification: \(error.localizedDescription)")
            }
        }
    }
}
