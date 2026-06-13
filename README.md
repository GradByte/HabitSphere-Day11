# HabitSphere

HabitSphere is a modern, local-first, privacy-focused iOS habit tracking application built with Swift and SwiftUI. Designed to help users build and maintain daily routines, the app provides visual streak insights to keep you motivated.

## Features

- **Local-First & Privacy-Focused**: All your habit data is stored locally on your device using JSON persistence. No cloud sync, no data harvesting—pure privacy.
- **Modern UI/UX**: Built with standard iOS 17+ best practices, leveraging clean SwiftUI components and a polished aesthetic.
- **Dashboard**: Quickly view today's habits and track your overall daily progress with an animated completion ring.
- **Insights**: Dive deep into your habit-building journey with statistics on your total habits, overall longest streak, and an interactive 30-day contribution graph.
- **Habit Customization**: Add new routines by choosing a custom name, an SF Symbol icon, and a frequency (e.g., Daily, Weekdays, Weekends).

## Architecture

The project is structured cleanly into logical layers mimicking a production-ready application:

- **Data Layer (`Models/`, `Storage/`)**: Features the `Habit` model, conforming to `Codable` and `Identifiable` with computed properties for tracking current and longest streaks. Data persistence is managed via `HabitStorage` using `FileManager`.
- **ViewModel Layer (`ViewModels/`)**: The `HabitViewModel` utilizes the modern `@Observable` macro to act as the single source of truth, managing interactions with the storage layer and updating the views responsively.
- **UI Layer (`Views/`)**: A modular suite of SwiftUI views, including `MainTabView`, `DashboardView`, `HabitCardView`, `AddHabitView`, and `InsightsView`.

## Requirements

- iOS 17.0+
- Xcode 15.0+
- Swift 5.9+

## Getting Started

1. Clone or download the repository.
2. Open `HabitSphere.xcodeproj` in Xcode.
3. Select an iOS 17+ Simulator or connected device.
4. Press Build and Run (`Cmd + R`).
