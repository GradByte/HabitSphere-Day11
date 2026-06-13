import SwiftUI

struct AddHabitView: View {
    @Environment(HabitViewModel.self) private var viewModel
    @Environment(\.dismiss) private var dismiss
    
    @State private var habitName: String = ""
    @State private var selectedIcon: String = "star.fill"
    @State private var selectedFrequency: HabitFrequency = .daily
    
    // New feature states
    @State private var targetCompletionCount: Int = 100
    @State private var enableReminder: Bool = false
    @State private var reminderTime: Date = Date()
    
    let icons = [
        "star.fill", "heart.fill", "drop.fill", "flame.fill",
        "book.fill", "bicycle", "figure.walk", "moon.stars.fill",
        "cup.and.saucer.fill", "applelogo", "music.note", "pencil"
    ]
    
    var body: some View {
        NavigationStack {
            Form {
                Section(header: Text("Habit Details")) {
                    TextField("Habit Name", text: $habitName)
                }
                
                Section(header: Text("Goals & Reminders")) {
                    Stepper("Target Completions: \(targetCompletionCount)", value: $targetCompletionCount, in: 10...1000, step: 10)
                    
                    Toggle("Daily Reminder", isOn: $enableReminder)
                        .onChange(of: enableReminder) { oldValue, newValue in
                            if newValue {
                                viewModel.requestNotificationPermission()
                            }
                        }
                    
                    if enableReminder {
                        DatePicker("Reminder Time", selection: $reminderTime, displayedComponents: .hourAndMinute)
                    }
                }
                
                Section(header: Text("Frequency")) {
                    Picker("Frequency", selection: $selectedFrequency) {
                        ForEach(HabitFrequency.allCases, id: \.self) { freq in
                            Text(freq.rawValue).tag(freq)
                        }
                    }
                    .pickerStyle(SegmentedPickerStyle())
                }
                
                Section(header: Text("Icon")) {
                    LazyVGrid(columns: [GridItem(.adaptive(minimum: 50))], spacing: 20) {
                        ForEach(icons, id: \.self) { icon in
                            ZStack {
                                Circle()
                                    .fill(selectedIcon == icon ? Color.indigo.opacity(0.2) : Color.clear)
                                    .frame(width: 50, height: 50)
                                
                                Image(systemName: icon)
                                    .font(.title2)
                                    .foregroundColor(selectedIcon == icon ? .indigo : .primary)
                            }
                            .onTapGesture {
                                withAnimation {
                                    selectedIcon = icon
                                }
                            }
                        }
                    }
                    .padding(.vertical, 8)
                }
            }
            .navigationTitle("New Habit")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        if !habitName.trimmingCharacters(in: .whitespaces).isEmpty {
                            viewModel.addHabit(
                                name: habitName,
                                icon: selectedIcon,
                                frequency: selectedFrequency,
                                targetCompletionCount: targetCompletionCount,
                                preferredReminderTime: enableReminder ? reminderTime : nil
                            )
                            dismiss()
                        }
                    }
                    .disabled(habitName.trimmingCharacters(in: .whitespaces).isEmpty)
                }
            }
        }
    }
}
