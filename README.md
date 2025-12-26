# Pompom - macOS Pomodoro Timer

A beautiful native macOS menu bar Pomodoro timer app built with SwiftUI using **Hexagonal Architecture**.

![macOS 14.0+](https://img.shields.io/badge/macOS-14.0+-blue)
![Swift 5.9+](https://img.shields.io/badge/Swift-5.9+-orange)
![SwiftUI](https://img.shields.io/badge/SwiftUI-✓-green)

## ✨ Features

### Timer
- **Pomodoro Timer** - Work sessions (25 min), short breaks (5 min), long breaks (15 min)
- **Menu Bar Integration** - Always accessible from your menu bar with live countdown
- **Visual Progress** - Beautiful circular progress indicator with glow and pulse animations
- **Session Transitions** - Automatic progression through work/break cycles
- **Compact Mode** - Minimalist floating timer view for distraction-free focus
- **Smart Break Suggestions** - AI-powered reminders based on your work patterns

### Tasks
- **Task Management** - Create, edit, and organize tasks with estimated pomodoros
- **Quick Add with Natural Language** - Add tasks like "Write report 3 pomodoros high priority"
- **Drag & Drop Reordering** - Easily reorganize your task list
- **Task Notes** - Add detailed notes to each task
- **Priority Levels** - Mark tasks as low, medium, or high priority
- **Progress Tracking** - Visual progress pills show completed vs estimated pomodoros

### Customization
- **Multiple Themes** - System, Light, Dark, Pomodoro Red, Forest Green, Ocean Blue
- **Adjustable Durations** - Customize work, short break, and long break durations
- **Auto-start Options** - Automatically start breaks or work sessions
- **Daily Goals** - Set and track daily pomodoro goals

### Productivity
- **Focus Mode** - Do Not Disturb integration during work sessions
- **Statistics** - Track total sessions, work time, streaks, and more
- **Productivity Insights** - Daily summaries and motivational messages
- **Weekly Heatmap** - Visual overview of your weekly productivity
- **Session History** - View completed session history with daily/weekly stats
- **Goal Celebrations** - Confetti animations when you hit your daily goals 🎉
- **Productivity Tips** - Rotating tips to help you stay focused

### Sound & Feedback
- **System Notifications** - Get notified when sessions complete
- **Sound Alerts** - Audio feedback with optional ticking sound
- **Haptic Feedback** - Subtle haptic feedback for interactions
- **Start/Pause/Skip Sounds** - Audio cues for all timer actions

### Keyboard Shortcuts
| Shortcut | Action |
|----------|--------|
| `⌃⌘Space` | Start/Pause timer |
| `⌃⌘→` | Skip to next session |
| `⌃⌘R` | Reset current session |

## 🏗 Architecture

This project follows **Hexagonal Architecture** (Ports & Adapters) with a highly layered approach honoring the **Single Responsibility Principle**.

```
Pompom/
├── Domain/                          # Core business logic (innermost layer)
│   ├── Entities/                    # Business entities
│   │   ├── PomodoroSession.swift
│   │   ├── Task.swift
│   │   └── SessionHistory.swift
│   ├── ValueObjects/                # Immutable value types
│   │   ├── TimerSettings.swift
│   │   ├── SessionStatistics.swift
│   │   └── AppTheme.swift
│   └── Ports/                       # Interfaces (abstractions)
│       ├── TimerPort.swift
│       ├── NotificationPort.swift
│       ├── SoundPort.swift
│       ├── PersistencePort.swift
│       ├── FocusModePort.swift
│       └── HistoryPersistencePort.swift
│
├── Application/                     # Use cases / Application services
│   └── UseCases/
│       ├── TimerUseCase.swift
│       ├── TaskUseCase.swift
│       └── SettingsUseCase.swift
│
├── Infrastructure/                  # External adapters (outermost layer)
│   ├── DependencyContainer.swift
│   └── Adapters/
│       ├── SystemTimerAdapter.swift
│       ├── UserNotificationAdapter.swift
│       ├── SystemSoundAdapter.swift
│       ├── UserDefaultsSettingsAdapter.swift
│       ├── UserDefaultsTaskAdapter.swift
│       ├── UserDefaultsStatisticsAdapter.swift
│       ├── UserDefaultsHistoryAdapter.swift
│       ├── FocusModeAdapter.swift
│       └── KeyboardShortcutService.swift
│
└── Presentation/                    # UI Layer
    ├── ViewModels/
    │   ├── TimerViewModel.swift
    │   ├── SettingsViewModel.swift
    │   └── TaskViewModel.swift
    └── Views/
        ├── EnhancedMenuBarView.swift
        ├── EnhancedSettingsView.swift
        └── Components/
            ├── CircularProgressView.swift
            ├── ControlButton.swift
            ├── DailyProgressView.swift
            ├── SessionTypeSelector.swift
            ├── TaskRowEnhanced.swift
            └── TaskEditSheet.swift
```

### Layer Responsibilities

| Layer | Responsibility |
|-------|---------------|
| **Domain** | Pure business logic, entities, value objects, and port interfaces. No external dependencies. |
| **Application** | Orchestrates use cases by coordinating domain objects and ports. |
| **Infrastructure** | Implements ports with concrete adapters (Timer, Notifications, Persistence). |
| **Presentation** | SwiftUI views and ViewModels that consume use cases. |

### Key Design Principles

1. **Dependency Inversion** - High-level modules (Domain, Application) don't depend on low-level modules (Infrastructure). Both depend on abstractions (Ports).

2. **Single Responsibility** - Each class has one reason to change:
   - `TimerUseCase` - Timer orchestration only
   - `TaskUseCase` - Task management only
   - `SystemTimerAdapter` - System timer mechanics only

3. **Interface Segregation** - Ports are small and focused:
   - `TimerPort` - Start/stop and tick publishing
   - `SoundPort` - Sound playback
   - `NotificationPort` - System notifications
   - `FocusModePort` - Focus/DND control

4. **Dependency Injection** - `DependencyContainer` wires everything together, making testing and swapping implementations easy.

## 📋 Requirements

- macOS 14.0+
- Xcode 15.0+
- Swift 5.9+

## 🚀 Building

### Option 1: Xcode (Recommended)
```bash
# Open in Xcode
open Pompom.xcodeproj

# Or build from terminal
xcodebuild -project Pompom.xcodeproj \
  -scheme Pompom \
  -configuration Release \
  -destination "platform=macOS" \
  -derivedDataPath .build \
  build

# Run the app
open .build/Build/Products/Release/Pompom.app
```

### Option 2: Archive for Distribution
```bash
xcodebuild -project Pompom.xcodeproj \
  -scheme Pompom \
  -configuration Release \
  -archivePath .build/Pompom.xcarchive \
  archive
```

## 📖 Usage

1. **Launch** - The app appears in your menu bar
2. **Start Timer** - Click the menu bar icon and press play
3. **Add Tasks** - Switch to Tasks tab and add your work items
4. **Track Progress** - Monitor your daily goal and statistics
5. **Customize** - Open Settings (⌘,) to personalize your experience

## 🎨 Themes

| Theme | Description |
|-------|-------------|
| System | Follows macOS appearance |
| Light | Always light mode |
| Dark | Always dark mode |
| Pomodoro Red | Warm red tones |
| Forest Green | Calming green palette |
| Ocean Blue | Cool blue aesthetics |

## 📄 License

MIT License

---

Made with ❤️ using SwiftUI
