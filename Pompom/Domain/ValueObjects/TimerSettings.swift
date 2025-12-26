import Foundation

struct TimerSettings: Equatable, Codable {
    var workDuration: TimeInterval
    var shortBreakDuration: TimeInterval
    var longBreakDuration: TimeInterval
    var sessionsUntilLongBreak: Int
    var autoStartBreaks: Bool
    var autoStartPomodoros: Bool
    var soundEnabled: Bool
    var notificationsEnabled: Bool
    var theme: AppTheme
    var focusModeEnabled: Bool
    var tickingSoundEnabled: Bool
    var showTimeInMenuBar: Bool
    var dailyGoal: Int
    
    static let `default` = TimerSettings(
        workDuration: 25 * 60,
        shortBreakDuration: 5 * 60,
        longBreakDuration: 15 * 60,
        sessionsUntilLongBreak: 4,
        autoStartBreaks: false,
        autoStartPomodoros: false,
        soundEnabled: true,
        notificationsEnabled: true,
        theme: .system,
        focusModeEnabled: false,
        tickingSoundEnabled: false,
        showTimeInMenuBar: true,
        dailyGoal: 8
    )
    
    func duration(for sessionType: SessionType) -> TimeInterval {
        switch sessionType {
        case .work: return workDuration
        case .shortBreak: return shortBreakDuration
        case .longBreak: return longBreakDuration
        }
    }
}
