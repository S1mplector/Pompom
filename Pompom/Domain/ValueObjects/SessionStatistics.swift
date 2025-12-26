import Foundation

struct SessionStatistics: Equatable, Codable {
    var totalWorkSessions: Int
    var totalWorkMinutes: Int
    var totalBreakMinutes: Int
    var currentStreak: Int
    var longestStreak: Int
    var lastSessionDate: Date?
    
    static let empty = SessionStatistics(
        totalWorkSessions: 0,
        totalWorkMinutes: 0,
        totalBreakMinutes: 0,
        currentStreak: 0,
        longestStreak: 0,
        lastSessionDate: nil
    )
    
    func withCompletedSession(type: SessionType, duration: TimeInterval) -> SessionStatistics {
        let minutes = Int(duration / 60)
        var updated = self
        
        switch type {
        case .work:
            updated.totalWorkSessions += 1
            updated.totalWorkMinutes += minutes
            updated.currentStreak += 1
            updated.longestStreak = max(updated.longestStreak, updated.currentStreak)
        case .shortBreak, .longBreak:
            updated.totalBreakMinutes += minutes
        }
        
        updated.lastSessionDate = Date()
        return updated
    }
}
