import SwiftUI

struct TaskEditSheet: View {
    @Binding var task: PomodoroTask
    let onSave: (PomodoroTask) -> Void
    let onCancel: () -> Void
    
    @State private var editedTitle: String
    @State private var editedNotes: String
    @State private var editedPomodoros: Int
    @State private var editedPriority: TaskPriority
    
    init(task: Binding<PomodoroTask>, onSave: @escaping (PomodoroTask) -> Void, onCancel: @escaping () -> Void) {
        self._task = task
        self.onSave = onSave
        self.onCancel = onCancel
        self._editedTitle = State(initialValue: task.wrappedValue.title)
        self._editedNotes = State(initialValue: task.wrappedValue.notes)
        self._editedPomodoros = State(initialValue: task.wrappedValue.estimatedPomodoros)
        self._editedPriority = State(initialValue: task.wrappedValue.priority)
    }
    
    var body: some View {
        VStack(spacing: 0) {
            // Header
            HStack {
                Text("Edit Task")
                    .font(.headline)
                
                Spacer()
                
                Button(action: onCancel) {
                    Image(systemName: "xmark.circle.fill")
                        .foregroundColor(.secondary)
                        .font(.title2)
                }
                .buttonStyle(.plain)
            }
            .padding()
            
            Divider()
            
            // Form
            VStack(alignment: .leading, spacing: 16) {
                // Title
                VStack(alignment: .leading, spacing: 6) {
                    Text("Title")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    
                    TextField("Task title", text: $editedTitle)
                        .textFieldStyle(.plain)
                        .font(.body)
                        .padding(10)
                        .background(
                            RoundedRectangle(cornerRadius: 8)
                                .fill(Color(nsColor: .textBackgroundColor))
                        )
                }
                
                // Notes
                VStack(alignment: .leading, spacing: 6) {
                    Text("Notes")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    
                    TextEditor(text: $editedNotes)
                        .font(.body)
                        .frame(height: 80)
                        .padding(6)
                        .background(
                            RoundedRectangle(cornerRadius: 8)
                                .fill(Color(nsColor: .textBackgroundColor))
                        )
                }
                
                // Estimated Pomodoros
                HStack {
                    VStack(alignment: .leading, spacing: 6) {
                        Text("Estimated Pomodoros")
                            .font(.caption)
                            .foregroundColor(.secondary)
                        
                        HStack(spacing: 8) {
                            ForEach(1...5, id: \.self) { count in
                                PomodoroButton(
                                    count: count,
                                    isSelected: editedPomodoros >= count
                                ) {
                                    editedPomodoros = count
                                }
                            }
                            
                            if editedPomodoros > 5 {
                                Text("+\(editedPomodoros - 5)")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            }
                            
                            Stepper("", value: $editedPomodoros, in: 1...10)
                                .labelsHidden()
                        }
                    }
                    
                    Spacer()
                }
                
                // Priority
                VStack(alignment: .leading, spacing: 6) {
                    Text("Priority")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    
                    HStack(spacing: 8) {
                        ForEach(TaskPriority.allCases, id: \.self) { priority in
                            PriorityButton(
                                priority: priority,
                                isSelected: editedPriority == priority
                            ) {
                                editedPriority = priority
                            }
                        }
                    }
                }
                
                // Progress indicator
                if task.completedPomodoros > 0 {
                    VStack(alignment: .leading, spacing: 6) {
                        Text("Progress")
                            .font(.caption)
                            .foregroundColor(.secondary)
                        
                        HStack(spacing: 4) {
                            ForEach(0..<max(editedPomodoros, task.completedPomodoros), id: \.self) { index in
                                Circle()
                                    .fill(index < task.completedPomodoros ? Color.red : Color.secondary.opacity(0.2))
                                    .frame(width: 12, height: 12)
                            }
                            
                            Text("\(task.completedPomodoros) completed")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                    }
                }
            }
            .padding()
            
            Divider()
            
            // Actions
            HStack {
                Button("Cancel", action: onCancel)
                    .buttonStyle(.plain)
                    .foregroundColor(.secondary)
                
                Spacer()
                
                Button("Save") {
                    let updatedTask = task.withUpdates(
                        title: editedTitle,
                        notes: editedNotes,
                        estimatedPomodoros: editedPomodoros,
                        priority: editedPriority
                    )
                    onSave(updatedTask)
                }
                .buttonStyle(.borderedProminent)
                .disabled(editedTitle.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
            }
            .padding()
        }
        .frame(width: 350)
        .background(Color(nsColor: .windowBackgroundColor))
    }
}

struct PomodoroButton: View {
    let count: Int
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Image(systemName: isSelected ? "circle.fill" : "circle")
                .font(.system(size: 16))
                .foregroundColor(isSelected ? .red : .secondary.opacity(0.3))
        }
        .buttonStyle(.plain)
    }
}

struct PriorityButton: View {
    let priority: TaskPriority
    let isSelected: Bool
    let action: () -> Void
    
    private var color: Color {
        switch priority {
        case .low: return .gray
        case .medium: return .orange
        case .high: return .red
        }
    }
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: 4) {
                Image(systemName: priority.icon)
                    .font(.caption)
                Text(priority.title)
                    .font(.caption)
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 6)
            .background(
                RoundedRectangle(cornerRadius: 6)
                    .fill(isSelected ? color.opacity(0.2) : Color.clear)
            )
            .foregroundColor(isSelected ? color : .secondary)
            .overlay(
                RoundedRectangle(cornerRadius: 6)
                    .stroke(isSelected ? color : Color.clear, lineWidth: 1)
            )
        }
        .buttonStyle(.plain)
    }
}

#Preview {
    TaskEditSheet(
        task: .constant(PomodoroTask(title: "Sample Task", notes: "Some notes", estimatedPomodoros: 3)),
        onSave: { _ in },
        onCancel: {}
    )
}
