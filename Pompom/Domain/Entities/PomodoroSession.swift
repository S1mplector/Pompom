import Foundation

enum SessionType: String, Codable, CaseIterable {
    case work = "Work"
    case shortBreak = "Short Break"
    case longBreak = "Long Break"
    
    var icon: String {
        switch self {
        case .work: return "brain.head.profile"
        case .shortBreak: return "cup.and.saucer.fill"
        case .longBreak: return "moon.fill"
        }
    }
}

enum SessionState: Equatable {
    case idle
    case running
    case paused
    case completed
}

struct PomodoroSession: Identifiable, Equatable {
    let id: UUID
    let type: SessionType
    let duration: TimeInterval
    var remainingTime: TimeInterval
    var state: SessionState
    let startedAt: Date?
    
    init(
        id: UUID = UUID(),
        type: SessionType,
        duration: TimeInterval,
        remainingTime: TimeInterval? = nil,
        state: SessionState = .idle,
        startedAt: Date? = nil
    ) {
        self.id = id
        self.type = type
        self.duration = duration
        self.remainingTime = remainingTime ?? duration
        self.state = state
        self.startedAt = startedAt
    }
    
    var progress: Double {
        guard duration > 0 else { return 0 }
        return 1 - (remainingTime / duration)
    }
    
    var isActive: Bool {
        state == .running || state == .paused
    }
    
    func withRemainingTime(_ time: TimeInterval) -> PomodoroSession {
        PomodoroSession(
            id: id,
            type: type,
            duration: duration,
            remainingTime: max(0, time),
            state: state,
            startedAt: startedAt
        )
    }
    
    func withState(_ newState: SessionState) -> PomodoroSession {
        PomodoroSession(
            id: id,
            type: type,
            duration: duration,
            remainingTime: remainingTime,
            state: newState,
            startedAt: newState == .running ? Date() : startedAt
        )
    }
}
