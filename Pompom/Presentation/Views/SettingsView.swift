import SwiftUI

struct SettingsView: View {
    @EnvironmentObject var settingsViewModel: SettingsViewModel
    
    var body: some View {
        TabView {
            TimerSettingsTab()
                .tabItem {
                    Label("Timer", systemImage: "timer")
                }
            
            BehaviorSettingsTab()
                .tabItem {
                    Label("Behavior", systemImage: "gearshape")
                }
            
            StatisticsTab()
                .tabItem {
                    Label("Statistics", systemImage: "chart.bar")
                }
        }
        .frame(width: 400, height: 300)
    }
}

struct TimerSettingsTab: View {
    @EnvironmentObject var settingsViewModel: SettingsViewModel
    
    var body: some View {
        Form {
            Section("Duration (minutes)") {
                DurationSlider(
                    label: "Work",
                    value: $settingsViewModel.workMinutes,
                    range: 1...60,
                    icon: "brain.head.profile",
                    color: .red
                )
                
                DurationSlider(
                    label: "Short Break",
                    value: $settingsViewModel.shortBreakMinutes,
                    range: 1...30,
                    icon: "cup.and.saucer.fill",
                    color: .green
                )
                
                DurationSlider(
                    label: "Long Break",
                    value: $settingsViewModel.longBreakMinutes,
                    range: 1...60,
                    icon: "moon.fill",
                    color: .blue
                )
            }
            
            Section("Sessions") {
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
            }
        }
        .formStyle(.grouped)
        .padding()
    }
}

struct DurationSlider: View {
    let label: String
    @Binding var value: Double
    let range: ClosedRange<Double>
    let icon: String
    let color: Color
    
    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            HStack {
                Image(systemName: icon)
                    .foregroundColor(color)
                
                Text(label)
                
                Spacer()
                
                Text("\(Int(value)) min")
                    .foregroundColor(.secondary)
                    .monospacedDigit()
            }
            
            Slider(value: $value, in: range, step: 1)
                .tint(color)
        }
    }
}

struct BehaviorSettingsTab: View {
    @EnvironmentObject var settingsViewModel: SettingsViewModel
    
    var body: some View {
        Form {
            Section("Auto-start") {
                Toggle(isOn: $settingsViewModel.autoStartBreaks) {
                    Label("Auto-start breaks", systemImage: "play.circle")
                }
                
                Toggle(isOn: $settingsViewModel.autoStartPomodoros) {
                    Label("Auto-start pomodoros", systemImage: "play.circle.fill")
                }
            }
            
            Section("Notifications") {
                Toggle(isOn: $settingsViewModel.soundEnabled) {
                    Label("Sound alerts", systemImage: "speaker.wave.2.fill")
                }
                
                Toggle(isOn: $settingsViewModel.notificationsEnabled) {
                    Label("System notifications", systemImage: "bell.fill")
                }
                
                Button("Request Notification Permission") {
                    settingsViewModel.requestNotificationPermission()
                }
            }
            
            Section {
                Button("Reset to Defaults") {
                    settingsViewModel.resetSettings()
                }
                .foregroundColor(.orange)
            }
        }
        .formStyle(.grouped)
        .padding()
    }
}

struct StatisticsTab: View {
    @EnvironmentObject var settingsViewModel: SettingsViewModel
    
    var body: some View {
        Form {
            Section("Overview") {
                StatRow(
                    icon: "checkmark.circle.fill",
                    color: .green,
                    label: "Total Work Sessions",
                    value: "\(settingsViewModel.statistics.totalWorkSessions)"
                )
                
                StatRow(
                    icon: "clock.fill",
                    color: .red,
                    label: "Total Work Time",
                    value: formatMinutes(settingsViewModel.statistics.totalWorkMinutes)
                )
                
                StatRow(
                    icon: "cup.and.saucer.fill",
                    color: .blue,
                    label: "Total Break Time",
                    value: formatMinutes(settingsViewModel.statistics.totalBreakMinutes)
                )
            }
            
            Section("Streaks") {
                StatRow(
                    icon: "flame.fill",
                    color: .orange,
                    label: "Current Streak",
                    value: "\(settingsViewModel.statistics.currentStreak) sessions"
                )
                
                StatRow(
                    icon: "trophy.fill",
                    color: .yellow,
                    label: "Longest Streak",
                    value: "\(settingsViewModel.statistics.longestStreak) sessions"
                )
            }
            
            Section {
                Button("Reset Statistics") {
                    settingsViewModel.resetStatistics()
                }
                .foregroundColor(.red)
            }
        }
        .formStyle(.grouped)
        .padding()
    }
    
    private func formatMinutes(_ minutes: Int) -> String {
        if minutes < 60 {
            return "\(minutes) min"
        }
        let hours = minutes / 60
        let remainingMinutes = minutes % 60
        return "\(hours)h \(remainingMinutes)m"
    }
}

struct StatRow: View {
    let icon: String
    let color: Color
    let label: String
    let value: String
    
    var body: some View {
        HStack {
            Image(systemName: icon)
                .foregroundColor(color)
            
            Text(label)
            
            Spacer()
            
            Text(value)
                .foregroundColor(.secondary)
        }
    }
}

#Preview {
    SettingsView()
}
