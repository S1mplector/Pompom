import SwiftUI

extension View {
    func timerAccessibility(
        time: String,
        sessionType: String,
        isRunning: Bool,
        progress: Double
    ) -> some View {
        self
            .accessibilityElement(children: .combine)
            .accessibilityLabel("\(sessionType) timer")
            .accessibilityValue("\(time) remaining, \(Int(progress * 100))% complete")
            .accessibilityHint(isRunning ? "Double tap to pause" : "Double tap to start")
            .accessibilityAddTraits(isRunning ? .updatesFrequently : [])
    }
    
    func taskAccessibility(
        task: PomodoroTask,
        isSelected: Bool
    ) -> some View {
        self
            .accessibilityElement(children: .combine)
            .accessibilityLabel(task.title)
            .accessibilityValue(taskAccessibilityValue(task: task, isSelected: isSelected))
            .accessibilityHint("Double tap to select. Swipe left to delete.")
            .accessibilityAddTraits(isSelected ? .isSelected : [])
    }
    
    private func taskAccessibilityValue(task: PomodoroTask, isSelected: Bool) -> String {
        var parts: [String] = []
        
        if task.isCompleted {
            parts.append("Completed")
        } else {
            parts.append("\(task.completedPomodoros) of \(task.estimatedPomodoros) pomodoros")
        }
        
        parts.append("\(task.priority.title) priority")
        
        if isSelected {
            parts.append("Currently selected")
        }
        
        return parts.joined(separator: ", ")
    }
    
    func buttonAccessibility(
        label: String,
        hint: String? = nil,
        isEnabled: Bool = true
    ) -> some View {
        self
            .accessibilityLabel(label)
            .accessibilityHint(hint ?? "")
            .accessibilityAddTraits(.isButton)
            .accessibilityRemoveTraits(isEnabled ? [] : .isEnabled)
    }
    
    func statisticAccessibility(
        label: String,
        value: String
    ) -> some View {
        self
            .accessibilityElement(children: .combine)
            .accessibilityLabel(label)
            .accessibilityValue(value)
    }
}

struct AccessibilityAnnouncement {
    static func announce(_ message: String) {
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            NSAccessibility.post(
                element: NSApp.mainWindow as Any,
                notification: .announcementRequested,
                userInfo: [.announcement: message, .priority: NSAccessibilityPriorityLevel.high]
            )
        }
    }
    
    static func timerStarted(sessionType: String) {
        announce("\(sessionType) session started")
    }
    
    static func timerPaused() {
        announce("Timer paused")
    }
    
    static func timerCompleted(sessionType: String) {
        announce("\(sessionType) session completed")
    }
    
    static func goalAchieved(count: Int) {
        announce("Congratulations! You've completed \(count) pomodoros today")
    }
    
    static func taskAdded(title: String) {
        announce("Task added: \(title)")
    }
    
    static func taskCompleted(title: String) {
        announce("Task completed: \(title)")
    }
}
