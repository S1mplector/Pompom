import Foundation

struct InputValidator {
    
    static func validateTaskTitle(_ title: String) -> ValidationResult {
        let trimmed = title.trimmingCharacters(in: .whitespacesAndNewlines)
        
        if trimmed.isEmpty {
            return .invalid("Task title cannot be empty")
        }
        
        if trimmed.count > 200 {
            return .invalid("Task title is too long (max 200 characters)")
        }
        
        return .valid
    }
    
    static func validateTaskNotes(_ notes: String) -> ValidationResult {
        if notes.count > 1000 {
            return .invalid("Notes are too long (max 1000 characters)")
        }
        return .valid
    }
    
    static func validatePomodoros(_ count: Int) -> ValidationResult {
        if count < 1 {
            return .invalid("Must have at least 1 pomodoro")
        }
        
        if count > 20 {
            return .invalid("Maximum 20 pomodoros per task")
        }
        
        return .valid
    }
    
    static func validateDuration(_ minutes: Double) -> ValidationResult {
        if minutes < 1 {
            return .invalid("Duration must be at least 1 minute")
        }
        
        if minutes > 120 {
            return .invalid("Duration cannot exceed 120 minutes")
        }
        
        return .valid
    }
    
    static func validateDailyGoal(_ goal: Int) -> ValidationResult {
        if goal < 1 {
            return .invalid("Daily goal must be at least 1")
        }
        
        if goal > 30 {
            return .invalid("Daily goal cannot exceed 30")
        }
        
        return .valid
    }
}

enum ValidationResult: Equatable {
    case valid
    case invalid(String)
    
    var isValid: Bool {
        switch self {
        case .valid: return true
        case .invalid: return false
        }
    }
    
    var errorMessage: String? {
        switch self {
        case .valid: return nil
        case .invalid(let message): return message
        }
    }
}

extension String {
    var isValidTaskTitle: Bool {
        InputValidator.validateTaskTitle(self).isValid
    }
    
    var trimmedOrNil: String? {
        let trimmed = trimmingCharacters(in: .whitespacesAndNewlines)
        return trimmed.isEmpty ? nil : trimmed
    }
    
    func truncated(to length: Int, trailing: String = "…") -> String {
        if count <= length {
            return self
        }
        return String(prefix(length)) + trailing
    }
}

extension Int {
    func clamped(to range: ClosedRange<Int>) -> Int {
        Swift.min(Swift.max(self, range.lowerBound), range.upperBound)
    }
}

extension Double {
    func clamped(to range: ClosedRange<Double>) -> Double {
        Swift.min(Swift.max(self, range.lowerBound), range.upperBound)
    }
}

extension TimeInterval {
    var formattedTimer: String {
        let totalSeconds = Int(self)
        let minutes = totalSeconds / 60
        let seconds = totalSeconds % 60
        return String(format: "%02d:%02d", minutes, seconds)
    }
    
    var formattedDuration: String {
        let totalMinutes = Int(self / 60)
        if totalMinutes < 60 {
            return "\(totalMinutes) min"
        }
        let hours = totalMinutes / 60
        let mins = totalMinutes % 60
        if mins == 0 {
            return "\(hours) hr"
        }
        return "\(hours) hr \(mins) min"
    }
}

extension Date {
    var isToday: Bool {
        Calendar.current.isDateInToday(self)
    }
    
    var isYesterday: Bool {
        Calendar.current.isDateInYesterday(self)
    }
    
    var startOfDay: Date {
        Calendar.current.startOfDay(for: self)
    }
    
    var relativeFormatted: String {
        let formatter = RelativeDateTimeFormatter()
        formatter.unitsStyle = .abbreviated
        return formatter.localizedString(for: self, relativeTo: Date())
    }
}
