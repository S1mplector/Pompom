import Foundation

enum TaskPriority: Int, Codable, CaseIterable {
    case low = 0
    case medium = 1
    case high = 2
    
    var title: String {
        switch self {
        case .low: return "Low"
        case .medium: return "Medium"
        case .high: return "High"
        }
    }
    
    var icon: String {
        switch self {
        case .low: return "flag"
        case .medium: return "flag.fill"
        case .high: return "exclamationmark.triangle.fill"
        }
    }
    
    var color: String {
        switch self {
        case .low: return "gray"
        case .medium: return "orange"
        case .high: return "red"
        }
    }
}

struct PomodoroTask: Identifiable, Equatable, Codable {
    let id: UUID
    var title: String
    var notes: String
    var estimatedPomodoros: Int
    var completedPomodoros: Int
    var isCompleted: Bool
    var priority: TaskPriority
    let createdAt: Date
    var completedAt: Date?
    
    init(
        id: UUID = UUID(),
        title: String,
        notes: String = "",
        estimatedPomodoros: Int = 1,
        completedPomodoros: Int = 0,
        isCompleted: Bool = false,
        priority: TaskPriority = .medium,
        createdAt: Date = Date(),
        completedAt: Date? = nil
    ) {
        self.id = id
        self.title = title
        self.notes = notes
        self.estimatedPomodoros = max(1, estimatedPomodoros)
        self.completedPomodoros = completedPomodoros
        self.isCompleted = isCompleted
        self.priority = priority
        self.createdAt = createdAt
        self.completedAt = completedAt
    }
    
    func withUpdates(title: String? = nil, notes: String? = nil, estimatedPomodoros: Int? = nil, priority: TaskPriority? = nil) -> PomodoroTask {
        PomodoroTask(
            id: id,
            title: title ?? self.title,
            notes: notes ?? self.notes,
            estimatedPomodoros: estimatedPomodoros ?? self.estimatedPomodoros,
            completedPomodoros: completedPomodoros,
            isCompleted: isCompleted,
            priority: priority ?? self.priority,
            createdAt: createdAt,
            completedAt: completedAt
        )
    }
    
    var progress: Double {
        guard estimatedPomodoros > 0 else { return 0 }
        return Double(completedPomodoros) / Double(estimatedPomodoros)
    }
    
    func withIncrementedPomodoro() -> PomodoroTask {
        PomodoroTask(
            id: id,
            title: title,
            notes: notes,
            estimatedPomodoros: estimatedPomodoros,
            completedPomodoros: completedPomodoros + 1,
            isCompleted: isCompleted,
            priority: priority,
            createdAt: createdAt,
            completedAt: completedAt
        )
    }
    
    func withCompletion(_ completed: Bool) -> PomodoroTask {
        PomodoroTask(
            id: id,
            title: title,
            notes: notes,
            estimatedPomodoros: estimatedPomodoros,
            completedPomodoros: completedPomodoros,
            isCompleted: completed,
            priority: priority,
            createdAt: createdAt,
            completedAt: completed ? Date() : nil
        )
    }
}
