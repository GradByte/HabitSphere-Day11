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
    
    // New Goals & Reminders fields
    var targetCompletionCount: Int = 100
    var preferredReminderTime: Date? = nil
    
    /// Full log of every timestamp this habit was completed
    var completionHistory: [Date] = []
    
    /// Legacy field used only during decoding for migration
    private var legacyCompletedDates: Set<String>? = nil
    
    // Custom coding keys to handle the migration
    enum CodingKeys: String, CodingKey {
        case id, name, icon, frequency, createdAt, targetCompletionCount, preferredReminderTime, completionHistory
        case legacyCompletedDates = "completedDates"
    }
    
    init(id: UUID = UUID(), name: String, icon: String, frequency: HabitFrequency = .daily, createdAt: Date = Date(), targetCompletionCount: Int = 100, preferredReminderTime: Date? = nil, completionHistory: [Date] = []) {
        self.id = id
        self.name = name
        self.icon = icon
        self.frequency = frequency
        self.createdAt = createdAt
        self.targetCompletionCount = targetCompletionCount
        self.preferredReminderTime = preferredReminderTime
        self.completionHistory = completionHistory
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        id = try container.decodeIfPresent(UUID.self, forKey: .id) ?? UUID()
        name = try container.decode(String.self, forKey: .name)
        icon = try container.decode(String.self, forKey: .icon)
        frequency = try container.decodeIfPresent(HabitFrequency.self, forKey: .frequency) ?? .daily
        createdAt = try container.decode(Date.self, forKey: .createdAt)
        
        targetCompletionCount = try container.decodeIfPresent(Int.self, forKey: .targetCompletionCount) ?? 100
        preferredReminderTime = try container.decodeIfPresent(Date.self, forKey: .preferredReminderTime)
        
        if let history = try container.decodeIfPresent([Date].self, forKey: .completionHistory) {
            completionHistory = history
        } else if let legacyDates = try container.decodeIfPresent(Set<String>.self, forKey: .legacyCompletedDates) {
            // Migrate legacy data by parsing old string formats
            completionHistory = legacyDates.compactMap { DateFormatter.habitDateFormatter.date(from: $0) }
        } else {
            completionHistory = []
        }
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(id, forKey: .id)
        try container.encode(name, forKey: .name)
        try container.encode(icon, forKey: .icon)
        try container.encode(frequency, forKey: .frequency)
        try container.encode(createdAt, forKey: .createdAt)
        try container.encode(targetCompletionCount, forKey: .targetCompletionCount)
        try container.encodeIfPresent(preferredReminderTime, forKey: .preferredReminderTime)
        try container.encode(completionHistory, forKey: .completionHistory)
    }
    
    /// Calculate the current streak based on continuous days completed up to today or yesterday
    var currentStreak: Int {
        var streak = 0
        let calendar = Calendar.current
        var checkDate = Date()
        
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
        let calendar = Calendar.current
        let uniqueDays = Set(completionHistory.map { calendar.startOfDay(for: $0) }).sorted()
        
        guard !uniqueDays.isEmpty else { return 0 }
        
        var maxStreak = 1
        var currentS = 1
        
        for i in 1..<uniqueDays.count {
            let previous = uniqueDays[i-1]
            let current = uniqueDays[i]
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
        let calendar = Calendar.current
        return completionHistory.contains { calendar.isDate($0, inSameDayAs: date) }
    }
    
    mutating func toggleCompletion(on date: Date) {
        let calendar = Calendar.current
        if let index = completionHistory.firstIndex(where: { calendar.isDate($0, inSameDayAs: date) }) {
            completionHistory.remove(at: index)
        } else {
            completionHistory.append(date)
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
