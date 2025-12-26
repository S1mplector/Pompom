import SwiftUI

struct TaskListView: View {
    @EnvironmentObject var taskViewModel: TaskViewModel
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            TaskHeaderView()
            
            if taskViewModel.tasks.isEmpty && !taskViewModel.isAddingTask {
                EmptyTaskView()
            } else {
                TaskScrollView()
            }
            
            if taskViewModel.isAddingTask {
                AddTaskFormView()
            }
        }
    }
}

struct TaskHeaderView: View {
    @EnvironmentObject var taskViewModel: TaskViewModel
    
    var body: some View {
        HStack {
            Text("Tasks")
                .font(.headline)
            
            Spacer()
            
            if taskViewModel.hasCompletedTasks {
                Button(action: { taskViewModel.clearCompletedTasks() }) {
                    Text("Clear Done")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                .buttonStyle(.plain)
            }
            
            Button(action: { taskViewModel.isAddingTask = true }) {
                Image(systemName: "plus.circle.fill")
                    .foregroundColor(.accentColor)
            }
            .buttonStyle(.plain)
            .disabled(taskViewModel.isAddingTask)
        }
    }
}

struct EmptyTaskView: View {
    var body: some View {
        VStack(spacing: 8) {
            Image(systemName: "checklist")
                .font(.largeTitle)
                .foregroundColor(.secondary)
            
            Text("No tasks yet")
                .font(.subheadline)
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 20)
    }
}

struct TaskScrollView: View {
    @EnvironmentObject var taskViewModel: TaskViewModel
    
    var body: some View {
        ScrollView {
            LazyVStack(spacing: 8) {
                ForEach(taskViewModel.pendingTasks) { task in
                    TaskRowView(task: task)
                }
                
                if !taskViewModel.completedTasks.isEmpty {
                    CompletedTasksSection()
                }
            }
        }
        .frame(maxHeight: 200)
    }
}

struct CompletedTasksSection: View {
    @EnvironmentObject var taskViewModel: TaskViewModel
    @State private var isExpanded = false
    
    var body: some View {
        DisclosureGroup(
            isExpanded: $isExpanded,
            content: {
                ForEach(taskViewModel.completedTasks) { task in
                    TaskRowView(task: task)
                }
            },
            label: {
                Text("Completed (\(taskViewModel.completedTasks.count))")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
        )
    }
}

struct TaskRowView: View {
    @EnvironmentObject var taskViewModel: TaskViewModel
    let task: PomodoroTask
    
    var isSelected: Bool {
        taskViewModel.selectedTask?.id == task.id
    }
    
    var body: some View {
        HStack(spacing: 12) {
            Button(action: { taskViewModel.toggleCompletion(task) }) {
                Image(systemName: task.isCompleted ? "checkmark.circle.fill" : "circle")
                    .foregroundColor(task.isCompleted ? .green : .secondary)
            }
            .buttonStyle(.plain)
            
            Text(task.title)
                .font(.subheadline)
                .strikethrough(task.isCompleted)
                .foregroundColor(task.isCompleted ? .secondary : .primary)
                .lineLimit(1)
            
            Spacer()
            
            PomodoroCountView(task: task)
            
            Button(action: { taskViewModel.deleteTask(task) }) {
                Image(systemName: "xmark")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            .buttonStyle(.plain)
            .opacity(0.6)
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 8)
        .background(
            RoundedRectangle(cornerRadius: 8)
                .fill(isSelected ? Color.accentColor.opacity(0.1) : Color.clear)
        )
        .contentShape(Rectangle())
        .onTapGesture {
            if !task.isCompleted {
                taskViewModel.selectTask(isSelected ? nil : task)
            }
        }
    }
}

struct PomodoroCountView: View {
    let task: PomodoroTask
    
    var body: some View {
        HStack(spacing: 2) {
            Text("\(task.completedPomodoros)/\(task.estimatedPomodoros)")
                .font(.caption)
                .foregroundColor(.secondary)
            
            Image(systemName: "tomato.fill")
                .font(.caption2)
                .foregroundColor(.red)
        }
    }
}

struct AddTaskFormView: View {
    @EnvironmentObject var taskViewModel: TaskViewModel
    @FocusState private var isFocused: Bool
    
    var body: some View {
        VStack(spacing: 8) {
            TextField("Task name", text: $taskViewModel.newTaskTitle)
                .textFieldStyle(.roundedBorder)
                .focused($isFocused)
                .onSubmit {
                    taskViewModel.addTask()
                }
            
            HStack {
                Stepper(
                    "Est: \(taskViewModel.newTaskPomodoros) 🍅",
                    value: $taskViewModel.newTaskPomodoros,
                    in: 1...10
                )
                .font(.caption)
                
                Spacer()
                
                Button("Cancel") {
                    taskViewModel.cancelAddTask()
                }
                .buttonStyle(.plain)
                .font(.caption)
                
                Button("Add") {
                    taskViewModel.addTask()
                }
                .buttonStyle(.borderedProminent)
                .controlSize(.small)
                .disabled(taskViewModel.newTaskTitle.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
            }
        }
        .padding(12)
        .background(
            RoundedRectangle(cornerRadius: 8)
                .fill(Color(nsColor: .controlBackgroundColor))
        )
        .onAppear {
            isFocused = true
        }
    }
}

#Preview {
    TaskListView()
}
