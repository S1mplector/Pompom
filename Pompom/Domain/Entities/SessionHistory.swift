import Foundation

struct CompletedSession: Identifiable, Codable, Equatable {
    let id: UUID
    let type: SessionType
    let duration: TimeInterval
    let completedAt: Date
    let taskId: UUID?
    let taskTitle: String?
    
    init(
        id: UUID = UUID(),
        type: SessionType,
        duration: TimeInterval,
        completedAt: Date = Date(),
        taskId: UUID? = nil,
        taskTitle: String? = nil
    ) {
        self.id = id
        self.type = type
        self.duration = duration
        self.completedAt = completedAt
        self.taskId = taskId
        self.taskTitle = taskTitle
    }
}

struct DailyStatistics: Identifiable, Codable, Equatable {
    var id: Date { date }
    let date: Date
    var workSessions: Int
    var workMinutes: Int
    var breakMinutes: Int
    
    static func forToday() -> DailyStatistics {
        DailyStatistics(
            date: Calendar.current.startOfDay(for: Date()),
            workSessions: 0,
            workMinutes: 0,
            breakMinutes: 0
        )
    }
    
    mutating func addSession(type: SessionType, duration: TimeInterval) {
        let minutes = Int(duration / 60)
        switch type {
        case .work:
            workSessions += 1
            workMinutes += minutes
        case .shortBreak, .longBreak:
            breakMinutes += minutes
        }
    }
}

struct SessionHistory: Codable, Equatable {
    var sessions: [CompletedSession]
    var dailyStats: [DailyStatistics]
    
    static let empty = SessionHistory(sessions: [], dailyStats: [])
    
    var todayStats: DailyStatistics {
        let today = Calendar.current.startOfDay(for: Date())
        return dailyStats.first { Calendar.current.isDate($0.date, inSameDayAs: today) }
            ?? .forToday()
    }
    
    var thisWeekStats: [DailyStatistics] {
        let calendar = Calendar.current
        let today = Date()
        let weekAgo = calendar.date(byAdding: .day, value: -6, to: today)!
        
        return (0...6).map { dayOffset in
            let date = calendar.date(byAdding: .day, value: -dayOffset, to: today)!
            let startOfDay = calendar.startOfDay(for: date)
            return dailyStats.first { calendar.isDate($0.date, inSameDayAs: startOfDay) }
                ?? DailyStatistics(date: startOfDay, workSessions: 0, workMinutes: 0, breakMinutes: 0)
        }.reversed()
    }
    
    mutating func addCompletedSession(_ session: CompletedSession) {
        sessions.insert(session, at: 0)
        
        // Keep only last 1000 sessions
        if sessions.count > 1000 {
            sessions = Array(sessions.prefix(1000))
        }
        
        // Update daily stats
        let today = Calendar.current.startOfDay(for: session.completedAt)
        if let index = dailyStats.firstIndex(where: { Calendar.current.isDate($0.date, inSameDayAs: today) }) {
            dailyStats[index].addSession(type: session.type, duration: session.duration)
        } else {
            var newStats = DailyStatistics(date: today, workSessions: 0, workMinutes: 0, breakMinutes: 0)
            newStats.addSession(type: session.type, duration: session.duration)
            dailyStats.insert(newStats, at: 0)
            
            // Keep only last 365 days
            if dailyStats.count > 365 {
                dailyStats = Array(dailyStats.prefix(365))
            }
        }
    }
}
