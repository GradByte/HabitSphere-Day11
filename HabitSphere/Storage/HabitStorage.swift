import Foundation

/// Manages local persistence of Habit data using JSON and FileManager
class HabitStorage {
    private let fileName = "habits.json"
    
    private var fileURL: URL {
        let documentDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        return documentDirectory.appendingPathComponent(fileName)
    }
    
    func save(habits: [Habit]) {
        do {
            let data = try JSONEncoder().encode(habits)
            try data.write(to: fileURL, options: [.atomic, .completeFileProtection])
        } catch {
            print("Failed to save habits: \(error.localizedDescription)")
        }
    }
    
    func load() -> [Habit] {
        guard FileManager.default.fileExists(atPath: fileURL.path) else {
            return [] // Return empty array if file doesn't exist yet
        }
        
        do {
            let data = try Data(contentsOf: fileURL)
            let habits = try JSONDecoder().decode([Habit].self, from: data)
            return habits
        } catch {
            print("Failed to load habits: \(error.localizedDescription)")
            return []
        }
    }
    
    func getHabits(byFrequency frequency: HabitFrequency) -> [Habit] {
        return load().filter { $0.frequency == frequency }
    }
    
    func getHabitsNearingGoal() -> [Habit] {
        let habits = load()
        return habits.filter {
            guard $0.targetCompletionCount > 0 else { return false }
            let ratio = Double($0.completionHistory.count) / Double($0.targetCompletionCount)
            return ratio >= 0.8 && ratio < 1.0
        }
    }
}
