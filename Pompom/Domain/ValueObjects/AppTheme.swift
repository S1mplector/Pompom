import SwiftUI

enum AppTheme: String, Codable, CaseIterable {
    case system = "System"
    case light = "Light"
    case dark = "Dark"
    case pomodoro = "Pomodoro Red"
    case forest = "Forest Green"
    case ocean = "Ocean Blue"
    
    var colorScheme: ColorScheme? {
        switch self {
        case .system: return nil
        case .light: return .light
        case .dark, .pomodoro, .forest, .ocean: return .dark
        }
    }
}

struct ThemeColors {
    let primary: Color
    let secondary: Color
    let background: Color
    let surface: Color
    let work: Color
    let shortBreak: Color
    let longBreak: Color
    
    static let standard = ThemeColors(
        primary: .accentColor,
        secondary: .secondary,
        background: Color(nsColor: .windowBackgroundColor),
        surface: Color(nsColor: .controlBackgroundColor),
        work: .red,
        shortBreak: .green,
        longBreak: .blue
    )
    
    static let pomodoro = ThemeColors(
        primary: Color(red: 0.85, green: 0.2, blue: 0.2),
        secondary: Color(red: 0.6, green: 0.15, blue: 0.15),
        background: Color(red: 0.12, green: 0.08, blue: 0.08),
        surface: Color(red: 0.18, green: 0.12, blue: 0.12),
        work: Color(red: 0.85, green: 0.2, blue: 0.2),
        shortBreak: Color(red: 0.2, green: 0.7, blue: 0.5),
        longBreak: Color(red: 0.3, green: 0.5, blue: 0.8)
    )
    
    static let forest = ThemeColors(
        primary: Color(red: 0.2, green: 0.6, blue: 0.4),
        secondary: Color(red: 0.15, green: 0.45, blue: 0.3),
        background: Color(red: 0.08, green: 0.12, blue: 0.1),
        surface: Color(red: 0.12, green: 0.18, blue: 0.15),
        work: Color(red: 0.8, green: 0.4, blue: 0.2),
        shortBreak: Color(red: 0.3, green: 0.7, blue: 0.5),
        longBreak: Color(red: 0.2, green: 0.5, blue: 0.6)
    )
    
    static let ocean = ThemeColors(
        primary: Color(red: 0.2, green: 0.5, blue: 0.8),
        secondary: Color(red: 0.15, green: 0.35, blue: 0.6),
        background: Color(red: 0.06, green: 0.1, blue: 0.15),
        surface: Color(red: 0.1, green: 0.15, blue: 0.22),
        work: Color(red: 0.9, green: 0.5, blue: 0.3),
        shortBreak: Color(red: 0.3, green: 0.7, blue: 0.7),
        longBreak: Color(red: 0.4, green: 0.6, blue: 0.9)
    )
    
    static func colors(for theme: AppTheme) -> ThemeColors {
        switch theme {
        case .system, .light, .dark: return .standard
        case .pomodoro: return .pomodoro
        case .forest: return .forest
        case .ocean: return .ocean
        }
    }
}
