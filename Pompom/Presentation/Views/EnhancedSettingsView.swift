import SwiftUI

struct EnhancedSettingsView: View {
    @EnvironmentObject var settingsViewModel: SettingsViewModel
    
    var body: some View {
        TabView {
            TimerSettingsPane()
                .tabItem {
                    Label("Timer", systemImage: "timer")
                }
            
            BehaviorSettingsPane()
                .tabItem {
                    Label("Behavior", systemImage: "gearshape.2")
                }
            
            AppearanceSettingsPane()
                .tabItem {
                    Label("Appearance", systemImage: "paintbrush")
                }
            
            SoundSettingsPane()
                .tabItem {
                    Label("Sound", systemImage: "speaker.wave.2")
                }
            
            StatisticsPane()
                .tabItem {
                    Label("Statistics", systemImage: "chart.bar.xaxis")
                }
            
            AboutPane()
                .tabItem {
                    Label("About", systemImage: "info.circle")
                }
        }
        .frame(width: 500, height: 400)
    }
}

// MARK: - Timer Settings

struct TimerSettingsPane: View {
    @EnvironmentObject var settingsViewModel: SettingsViewModel
    
    var body: some View {
        Form {
            Section {
                VStack(alignment: .leading, spacing: 16) {
                    TimerDurationRow(
                        title: "Work Duration",
                        value: $settingsViewModel.workMinutes,
                        range: 5...90,
                        icon: "brain.head.profile",
                        color: .red
                    )
                    
                    TimerDurationRow(
                        title: "Short Break",
                        value: $settingsViewModel.shortBreakMinutes,
                        range: 5...30,
                        icon: "cup.and.saucer.fill",
                        color: .green
                    )
                    
                    TimerDurationRow(
                        title: "Long Break",
                        value: $settingsViewModel.longBreakMinutes,
                        range: 5...60,
                        icon: "moon.fill",
                        color: .blue
                    )
                }
            } header: {
                Text("Duration (minutes)")
            }
            
            Section {
                HStack {
                    Label("Sessions until long break", systemImage: "repeat")
                    Spacer()
                    Picker("", selection: Binding(
                        get: { Int(settingsViewModel.sessionsUntilLongBreak) },
                        set: { settingsViewModel.sessionsUntilLongBreak = Double($0) }
                    )) {
                        ForEach(2...8, id: \.self) { count in
                            Text("\(count)").tag(count)
                        }
                    }
                    .frame(width: 80)
                }
                
                HStack {
                    Label("Daily goal", systemImage: "target")
                    Spacer()
                    Stepper("\(settingsViewModel.dailyGoal) pomodoros", value: $settingsViewModel.dailyGoal, in: 1...20)
                }
            } header: {
                Text("Goals")
            }
        }
        .formStyle(.grouped)
        .scrollContentBackground(.hidden)
    }
}

struct TimerDurationRow: View {
    let title: String
    @Binding var value: Double
    let range: ClosedRange<Double>
    let icon: String
    let color: Color
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Image(systemName: icon)
                    .foregroundColor(color)
                    .frame(width: 20)
                
                Text(title)
                    .font(.subheadline)
                
                Spacer()
                
                Text("\(Int(value)) min")
                    .font(.subheadline)
                    .fontWeight(.medium)
                    .foregroundColor(color)
                    .monospacedDigit()
                    .frame(width: 60, alignment: .trailing)
            }
            
            Slider(value: $value, in: range, step: 5)
                .tint(color)
        }
    }
}

// MARK: - Behavior Settings

struct BehaviorSettingsPane: View {
    @EnvironmentObject var settingsViewModel: SettingsViewModel
    
    var body: some View {
        Form {
            Section {
                Toggle(isOn: $settingsViewModel.autoStartBreaks) {
                    Label {
                        VStack(alignment: .leading) {
                            Text("Auto-start breaks")
                            Text("Automatically start break timer after work session")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                    } icon: {
                        Image(systemName: "play.circle")
                    }
                }
                
                Toggle(isOn: $settingsViewModel.autoStartPomodoros) {
                    Label {
                        VStack(alignment: .leading) {
                            Text("Auto-start pomodoros")
                            Text("Automatically start work session after break")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                    } icon: {
                        Image(systemName: "play.circle.fill")
                    }
                }
            } header: {
                Text("Auto-start")
            }
            
            Section {
                Toggle(isOn: $settingsViewModel.focusModeEnabled) {
                    Label {
                        VStack(alignment: .leading) {
                            Text("Focus Mode")
                            Text("Enable Do Not Disturb during work sessions")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                    } icon: {
                        Image(systemName: "moon.circle.fill")
                    }
                }
            } header: {
                Text("Focus")
            }
            
            Section {
                Toggle(isOn: $settingsViewModel.showTimeInMenuBar) {
                    Label("Show time in menu bar", systemImage: "menubar.rectangle")
                }
            } header: {
                Text("Menu Bar")
            }
            
            Section {
                Button(role: .destructive) {
                    settingsViewModel.resetSettings()
                } label: {
                    Label("Reset All Settings", systemImage: "arrow.counterclockwise")
                }
            }
        }
        .formStyle(.grouped)
        .scrollContentBackground(.hidden)
    }
}

// MARK: - Appearance Settings

struct AppearanceSettingsPane: View {
    @EnvironmentObject var settingsViewModel: SettingsViewModel
    
    var body: some View {
        Form {
            Section {
                Picker("Theme", selection: $settingsViewModel.selectedTheme) {
                    ForEach(AppTheme.allCases, id: \.self) { theme in
                        HStack {
                            ThemePreview(theme: theme)
                            Text(theme.rawValue)
                        }
                        .tag(theme)
                    }
                }
                .pickerStyle(.radioGroup)
            } header: {
                Text("Theme")
            }
            
            Section {
                ThemePreviewCard(theme: settingsViewModel.selectedTheme)
            } header: {
                Text("Preview")
            }
        }
        .formStyle(.grouped)
        .scrollContentBackground(.hidden)
    }
}

struct ThemePreview: View {
    let theme: AppTheme
    
    var body: some View {
        let colors = ThemeColors.colors(for: theme)
        HStack(spacing: 2) {
            Circle().fill(colors.work).frame(width: 12, height: 12)
            Circle().fill(colors.shortBreak).frame(width: 12, height: 12)
            Circle().fill(colors.longBreak).frame(width: 12, height: 12)
        }
    }
}

struct ThemePreviewCard: View {
    let theme: AppTheme
    
    var body: some View {
        let colors = ThemeColors.colors(for: theme)
        
        HStack(spacing: 20) {
            VStack(spacing: 8) {
                Circle()
                    .stroke(colors.work, lineWidth: 4)
                    .frame(width: 50, height: 50)
                    .overlay(
                        Text("25:00")
                            .font(.caption2)
                            .fontWeight(.medium)
                    )
                Text("Work")
                    .font(.caption2)
                    .foregroundColor(.secondary)
            }
            
            VStack(spacing: 8) {
                Circle()
                    .stroke(colors.shortBreak, lineWidth: 4)
                    .frame(width: 50, height: 50)
                    .overlay(
                        Text("5:00")
                            .font(.caption2)
                            .fontWeight(.medium)
                    )
                Text("Short")
                    .font(.caption2)
                    .foregroundColor(.secondary)
            }
            
            VStack(spacing: 8) {
                Circle()
                    .stroke(colors.longBreak, lineWidth: 4)
                    .frame(width: 50, height: 50)
                    .overlay(
                        Text("15:00")
                            .font(.caption2)
                            .fontWeight(.medium)
                    )
                Text("Long")
                    .font(.caption2)
                    .foregroundColor(.secondary)
            }
        }
        .frame(maxWidth: .infinity)
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(colors.surface)
        )
    }
}

// MARK: - Sound Settings

struct SoundSettingsPane: View {
    @EnvironmentObject var settingsViewModel: SettingsViewModel
    
    var body: some View {
        Form {
            Section {
                Toggle(isOn: $settingsViewModel.soundEnabled) {
                    Label {
                        VStack(alignment: .leading) {
                            Text("Completion sounds")
                            Text("Play sound when session completes")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                    } icon: {
                        Image(systemName: "speaker.wave.2.fill")
                    }
                }
                
                Toggle(isOn: $settingsViewModel.tickingSoundEnabled) {
                    Label {
                        VStack(alignment: .leading) {
                            Text("Ticking sound")
                            Text("Play subtle tick sound during sessions")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                    } icon: {
                        Image(systemName: "metronome.fill")
                    }
                }
            } header: {
                Text("Sounds")
            }
            
            Section {
                Toggle(isOn: $settingsViewModel.notificationsEnabled) {
                    Label {
                        VStack(alignment: .leading) {
                            Text("System notifications")
                            Text("Show notification when session completes")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                    } icon: {
                        Image(systemName: "bell.fill")
                    }
                }
                
                Button {
                    settingsViewModel.requestNotificationPermission()
                } label: {
                    Label("Request Notification Permission", systemImage: "bell.badge")
                }
            } header: {
                Text("Notifications")
            }
        }
        .formStyle(.grouped)
        .scrollContentBackground(.hidden)
    }
}

// MARK: - Statistics Pane

struct StatisticsPane: View {
    @EnvironmentObject var settingsViewModel: SettingsViewModel
    
    var body: some View {
        Form {
            Section {
                StatisticRow(
                    icon: "checkmark.circle.fill",
                    iconColor: .green,
                    title: "Total Work Sessions",
                    value: "\(settingsViewModel.statistics.totalWorkSessions)"
                )
                
                StatisticRow(
                    icon: "clock.fill",
                    iconColor: .red,
                    title: "Total Work Time",
                    value: formatTime(settingsViewModel.statistics.totalWorkMinutes)
                )
                
                StatisticRow(
                    icon: "cup.and.saucer.fill",
                    iconColor: .blue,
                    title: "Total Break Time",
                    value: formatTime(settingsViewModel.statistics.totalBreakMinutes)
                )
            } header: {
                Text("All Time")
            }
            
            Section {
                StatisticRow(
                    icon: "flame.fill",
                    iconColor: .orange,
                    title: "Current Streak",
                    value: "\(settingsViewModel.statistics.currentStreak) sessions"
                )
                
                StatisticRow(
                    icon: "trophy.fill",
                    iconColor: .yellow,
                    title: "Best Streak",
                    value: "\(settingsViewModel.statistics.longestStreak) sessions"
                )
                
                if let lastDate = settingsViewModel.statistics.lastSessionDate {
                    StatisticRow(
                        icon: "calendar",
                        iconColor: .purple,
                        title: "Last Session",
                        value: formatDate(lastDate)
                    )
                }
            } header: {
                Text("Streaks")
            }
            
            Section {
                ProductivityChartsView(
                    history: settingsViewModel.history,
                    dailyGoal: settingsViewModel.dailyGoal
                )
                .frame(height: 320)
            } header: {
                Text("Weekly Progress")
            }
            
            Section {
                Button(role: .destructive) {
                    settingsViewModel.resetStatistics()
                } label: {
                    Label("Reset All Statistics", systemImage: "trash")
                }
            }
        }
        .formStyle(.grouped)
        .scrollContentBackground(.hidden)
    }
    
    private func formatTime(_ minutes: Int) -> String {
        if minutes < 60 {
            return "\(minutes) minutes"
        }
        let hours = minutes / 60
        let mins = minutes % 60
        if mins == 0 {
            return "\(hours) hours"
        }
        return "\(hours)h \(mins)m"
    }
    
    private func formatDate(_ date: Date) -> String {
        let formatter = RelativeDateTimeFormatter()
        formatter.unitsStyle = .abbreviated
        return formatter.localizedString(for: date, relativeTo: Date())
    }
}

struct StatisticRow: View {
    let icon: String
    let iconColor: Color
    let title: String
    let value: String
    
    var body: some View {
        HStack {
            Image(systemName: icon)
                .foregroundColor(iconColor)
                .frame(width: 24)
            
            Text(title)
            
            Spacer()
            
            Text(value)
                .foregroundColor(.secondary)
                .fontWeight(.medium)
        }
    }
}

// MARK: - About Pane

struct AboutPane: View {
    @StateObject private var lifecycleManager = AppLifecycleManager.shared
    @EnvironmentObject var settingsViewModel: SettingsViewModel
    @EnvironmentObject var taskViewModel: TaskViewModel
    
    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                // App icon
                ZStack {
                    RoundedRectangle(cornerRadius: 24)
                        .fill(
                            LinearGradient(
                                colors: [.red, .orange],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .frame(width: 80, height: 80)
                        .shadow(color: .red.opacity(0.3), radius: 10, y: 5)
                    
                    Image(systemName: "timer")
                        .font(.system(size: 40))
                        .foregroundColor(.white)
                }
                
                VStack(spacing: 4) {
                    Text("Pompom")
                        .font(.title2)
                        .fontWeight(.bold)
                    
                    Text("Version \(Bundle.main.fullVersion)")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                
                // Launch at login
                Form {
                    Section {
                        Toggle(isOn: $lifecycleManager.isLaunchAtLoginEnabled) {
                            Label("Launch at Login", systemImage: "power")
                        }
                    } header: {
                        Text("Startup")
                    }
                    
                    Section {
                        Button {
                            DataExportService.shared.exportData(
                                statistics: settingsViewModel.statistics,
                                tasks: taskViewModel.tasks,
                                settings: currentSettings
                            )
                        } label: {
                            Label("Export Data (JSON)", systemImage: "square.and.arrow.up")
                        }
                        
                        Button {
                            DataExportService.shared.exportToCSV(
                                statistics: settingsViewModel.statistics,
                                tasks: taskViewModel.tasks
                            )
                        } label: {
                            Label("Export to CSV", systemImage: "tablecells")
                        }
                        
                        Button {
                            DataExportService.shared.importData { data in
                                if data != nil {
                                    ErrorHandler.shared.showInfo(
                                        title: "Import Complete",
                                        message: "Your data has been restored. Please restart the app."
                                    )
                                }
                            }
                        } label: {
                            Label("Import Backup", systemImage: "square.and.arrow.down")
                        }
                    } header: {
                        Text("Data")
                    }
                    
                    Section {
                        VStack(alignment: .leading, spacing: 8) {
                            ShortcutRow(shortcut: "⌃⌘Space", description: "Start/Pause timer")
                            ShortcutRow(shortcut: "⌃⌘→", description: "Skip session")
                            ShortcutRow(shortcut: "⌃⌘R", description: "Reset session")
                        }
                        .padding(.vertical, 4)
                    } header: {
                        Text("Keyboard Shortcuts")
                    }
                }
                .formStyle(.grouped)
                .scrollContentBackground(.hidden)
                .frame(height: 280)
                
                Text("Made with ❤️ using SwiftUI")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            .padding(.top)
        }
    }
    
    private var currentSettings: TimerSettings {
        TimerSettings(
            workDuration: settingsViewModel.workMinutes * 60,
            shortBreakDuration: settingsViewModel.shortBreakMinutes * 60,
            longBreakDuration: settingsViewModel.longBreakMinutes * 60,
            sessionsUntilLongBreak: Int(settingsViewModel.sessionsUntilLongBreak),
            autoStartBreaks: settingsViewModel.autoStartBreaks,
            autoStartPomodoros: settingsViewModel.autoStartPomodoros,
            soundEnabled: settingsViewModel.soundEnabled,
            notificationsEnabled: settingsViewModel.notificationsEnabled,
            theme: settingsViewModel.selectedTheme,
            focusModeEnabled: settingsViewModel.focusModeEnabled,
            tickingSoundEnabled: settingsViewModel.tickingSoundEnabled,
            showTimeInMenuBar: settingsViewModel.showTimeInMenuBar,
            dailyGoal: settingsViewModel.dailyGoal
        )
    }
}

struct ShortcutRow: View {
    let shortcut: String
    let description: String
    
    var body: some View {
        HStack {
            Text(shortcut)
                .font(.system(.caption, design: .monospaced))
                .padding(.horizontal, 8)
                .padding(.vertical, 4)
                .background(
                    RoundedRectangle(cornerRadius: 6)
                        .fill(Color(nsColor: .controlBackgroundColor))
                )
            
            Text(description)
                .font(.caption)
                .foregroundColor(.secondary)
        }
    }
}

#Preview {
    EnhancedSettingsView()
}
