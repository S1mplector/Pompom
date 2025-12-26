import SwiftUI

struct EnhancedMenuBarView: View {
    @EnvironmentObject var timerViewModel: TimerViewModel
    @EnvironmentObject var settingsViewModel: SettingsViewModel
    @EnvironmentObject var taskViewModel: TaskViewModel
    
    @State private var selectedTab: MenuTab = .timer
    @State private var showQuickAdd = false
    @State private var showCelebration = false
    @State private var isCompactMode = false
    
    enum MenuTab: CaseIterable {
        case timer
        case tasks
        case stats
        
        var title: String {
            switch self {
            case .timer: return "Timer"
            case .tasks: return "Tasks"
            case .stats: return "Stats"
            }
        }
        
        var icon: String {
            switch self {
            case .timer: return "timer"
            case .tasks: return "checklist"
            case .stats: return "chart.bar.fill"
            }
        }
    }
    
    var body: some View {
        ZStack {
            VStack(spacing: 0) {
                if isCompactMode {
                    MiniModeView(isExpanded: $isCompactMode)
                        .transition(.asymmetric(
                            insertion: .move(edge: .top).combined(with: .opacity),
                            removal: .opacity
                        ))
                } else {
                    // Header with compact toggle
                    HeaderBar(isCompactMode: $isCompactMode, showQuickAdd: $showQuickAdd)
                    
                    // Tab selector
                    TabSelector(selectedTab: $selectedTab)
                        .padding(.horizontal)
                        .padding(.top, 8)
                    
                    Divider()
                        .padding(.vertical, 8)
                    
                    // Content
                    Group {
                        switch selectedTab {
                        case .timer:
                            TimerTabView(showCelebration: $showCelebration)
                        case .tasks:
                            TasksTabView(showQuickAdd: $showQuickAdd)
                        case .stats:
                            StatsTabView()
                        }
                    }
                    .frame(maxWidth: .infinity)
                    .transition(.opacity.combined(with: .scale(scale: 0.98)))
                    
                    Divider()
                        .padding(.vertical, 8)
                    
                    // Bottom controls
                    BottomBar()
                }
            }
            .padding()
            .frame(width: 340)
            .animation(.spring(response: 0.35, dampingFraction: 0.85), value: selectedTab)
            .animation(.spring(response: 0.3), value: isCompactMode)
            
            // Quick add overlay
            if showQuickAdd {
                Color.black.opacity(0.3)
                    .ignoresSafeArea()
                    .onTapGesture {
                        withAnimation(.spring()) {
                            showQuickAdd = false
                        }
                    }
                
                QuickAddTaskView(isPresented: $showQuickAdd)
                    .transition(.scale.combined(with: .opacity))
            }
            
            // Celebration overlay
            if showCelebration {
                GoalCompletedView(
                    isShowing: $showCelebration,
                    completedCount: settingsViewModel.statistics.totalWorkSessions,
                    goalCount: settingsViewModel.dailyGoal
                )
            }
        }
        .animation(.spring(), value: showQuickAdd)
    }
}

struct HeaderBar: View {
    @Binding var isCompactMode: Bool
    @Binding var showQuickAdd: Bool
    
    var body: some View {
        HStack {
            Text("Pompom")
                .font(.headline)
                .fontWeight(.bold)
            
            Spacer()
            
            HStack(spacing: 12) {
                Button {
                    withAnimation(.spring()) {
                        showQuickAdd = true
                    }
                } label: {
                    Image(systemName: "plus.circle")
                        .font(.body)
                        .foregroundColor(.secondary)
                }
                .buttonStyle(.plain)
                .help("Quick Add Task (Natural Language)")
                
                Button {
                    withAnimation(.spring(response: 0.3)) {
                        isCompactMode = true
                    }
                } label: {
                    Image(systemName: "rectangle.compress.vertical")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                .buttonStyle(.plain)
                .help("Compact Mode")
            }
        }
        .padding(.horizontal)
        .padding(.top, 4)
    }
}

struct TabSelector: View {
    @Binding var selectedTab: EnhancedMenuBarView.MenuTab
    
    var body: some View {
        HStack(spacing: 4) {
            TabButton(
                title: "Timer",
                icon: "timer",
                isSelected: selectedTab == .timer
            ) {
                selectedTab = .timer
            }
            
            TabButton(
                title: "Tasks",
                icon: "checklist",
                isSelected: selectedTab == .tasks
            ) {
                selectedTab = .tasks
            }
            
            TabButton(
                title: "Stats",
                icon: "chart.bar.fill",
                isSelected: selectedTab == .stats
            ) {
                selectedTab = .stats
            }
        }
        .padding(4)
        .background(
            RoundedRectangle(cornerRadius: 10)
                .fill(Color(nsColor: .controlBackgroundColor))
        )
    }
}

struct TabButton: View {
    let title: String
    let icon: String
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: 6) {
                Image(systemName: icon)
                    .font(.caption)
                Text(title)
                    .font(.caption)
                    .fontWeight(isSelected ? .semibold : .regular)
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 8)
            .background(
                RoundedRectangle(cornerRadius: 8)
                    .fill(isSelected ? Color.accentColor.opacity(0.2) : Color.clear)
            )
            .foregroundColor(isSelected ? .accentColor : .secondary)
        }
        .buttonStyle(.plain)
    }
}

struct TimerTabView: View {
    @EnvironmentObject var timerViewModel: TimerViewModel
    @EnvironmentObject var taskViewModel: TaskViewModel
    @EnvironmentObject var settingsViewModel: SettingsViewModel
    
    @Binding var showCelebration: Bool
    @State private var showBreakSuggestion = true
    
    var body: some View {
        VStack(spacing: 16) {
            // Smart break suggestion
            if timerViewModel.session.type == .work && !timerViewModel.isRunning {
                SmartBreakSuggestion(
                    consecutiveSessions: settingsViewModel.statistics.currentStreak,
                    totalWorkMinutes: settingsViewModel.statistics.totalWorkMinutes,
                    onTakeBreak: {
                        timerViewModel.skipSession()
                    },
                    onDismiss: {
                        showBreakSuggestion = false
                    }
                )
                .padding(.horizontal, 4)
            }
            
            // Session type indicator
            SessionBadge(
                type: timerViewModel.session.type,
                color: timerViewModel.sessionColor
            )
            
            // Timer circle with pulse effect when running
            ZStack {
                if timerViewModel.isRunning {
                    PulsingCircle(color: timerViewModel.sessionColor)
                        .frame(width: 220, height: 220)
                }
                
                CircularProgressView(
                    progress: timerViewModel.progress,
                    color: timerViewModel.sessionColor,
                    lineWidth: 10
                )
                
                VStack(spacing: 4) {
                    AnimatedTimerText(
                        time: timerViewModel.displayTime,
                        isRunning: timerViewModel.isRunning
                    )
                    
                    if timerViewModel.isPaused {
                        Text("PAUSED")
                            .font(.caption)
                            .fontWeight(.medium)
                            .foregroundColor(.secondary)
                            .transition(.scale.combined(with: .opacity))
                    }
                }
            }
            .frame(width: 200, height: 200)
            .animation(.spring(response: 0.4), value: timerViewModel.isPaused)
            
            // Selected task indicator
            if let task = taskViewModel.selectedTask {
                SelectedTaskBadge(task: task)
                    .transition(.asymmetric(
                        insertion: .move(edge: .bottom).combined(with: .opacity),
                        removal: .opacity
                    ))
            }
            
            // Controls
            TimerControls()
            
            // Daily progress mini bar
            CompactStatsBar(
                completedToday: settingsViewModel.statistics.totalWorkSessions,
                goalToday: settingsViewModel.dailyGoal,
                currentStreak: settingsViewModel.statistics.currentStreak
            )
        }
        .padding(.vertical, 8)
        .animation(.spring(), value: taskViewModel.selectedTask?.id)
    }
}

struct SessionBadge: View {
    let type: SessionType
    let color: Color
    
    var body: some View {
        HStack(spacing: 6) {
            Image(systemName: type.icon)
                .font(.caption)
            
            Text(type.rawValue)
                .font(.subheadline)
                .fontWeight(.semibold)
        }
        .foregroundColor(color)
        .padding(.horizontal, 16)
        .padding(.vertical, 8)
        .background(
            Capsule()
                .fill(color.opacity(0.15))
        )
    }
}

struct SelectedTaskBadge: View {
    let task: PomodoroTask
    
    var body: some View {
        HStack(spacing: 8) {
            Image(systemName: "target")
                .font(.caption)
                .foregroundColor(.accentColor)
            
            Text(task.title)
                .font(.caption)
                .lineLimit(1)
            
            Spacer()
            
            Text("\(task.completedPomodoros)/\(task.estimatedPomodoros)")
                .font(.caption2)
                .foregroundColor(.secondary)
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 8)
        .background(
            RoundedRectangle(cornerRadius: 8)
                .fill(Color(nsColor: .controlBackgroundColor))
        )
        .padding(.horizontal)
    }
}

struct TimerControls: View {
    @EnvironmentObject var timerViewModel: TimerViewModel
    
    var body: some View {
        HStack(spacing: 24) {
            SecondaryControlButton(
                icon: "arrow.counterclockwise",
                isEnabled: !timerViewModel.isIdle
            ) {
                timerViewModel.resetSession()
            }
            
            PrimaryControlButton(
                icon: timerViewModel.isRunning ? "pause.fill" : "play.fill",
                color: timerViewModel.sessionColor
            ) {
                timerViewModel.toggleTimer()
            }
            
            SecondaryControlButton(
                icon: "forward.fill",
                isEnabled: true
            ) {
                timerViewModel.skipSession()
            }
        }
    }
}

struct TasksTabView: View {
    @EnvironmentObject var taskViewModel: TaskViewModel
    @Binding var showQuickAdd: Bool
    
    @State private var editingTask: PomodoroTask?
    @State private var showEditSheet = false
    
    var body: some View {
        VStack(spacing: 12) {
            // Header
            HStack {
                Text("Tasks")
                    .font(.headline)
                
                Spacer()
                
                if taskViewModel.hasCompletedTasks {
                    Button("Clear Done") {
                        withAnimation(.spring()) {
                            taskViewModel.clearCompletedTasks()
                        }
                    }
                    .font(.caption)
                    .buttonStyle(.plain)
                    .foregroundColor(.secondary)
                }
                
                Menu {
                    Button {
                        taskViewModel.isAddingTask = true
                    } label: {
                        Label("Simple Add", systemImage: "plus")
                    }
                    
                    Button {
                        showQuickAdd = true
                    } label: {
                        Label("Quick Add (AI)", systemImage: "sparkles")
                    }
                } label: {
                    Image(systemName: "plus.circle.fill")
                        .font(.title3)
                        .foregroundColor(.accentColor)
                }
                .menuStyle(.borderlessButton)
                .frame(width: 30)
            }
            
            // Task list
            if taskViewModel.tasks.isEmpty && !taskViewModel.isAddingTask {
                EmptyTasksView(onQuickAdd: { showQuickAdd = true })
            } else {
                ScrollView {
                    LazyVStack(spacing: 8) {
                        if taskViewModel.isAddingTask {
                            AddTaskForm()
                                .transition(.asymmetric(
                                    insertion: .move(edge: .top).combined(with: .opacity),
                                    removal: .opacity
                                ))
                        }
                        
                        ForEach(taskViewModel.pendingTasks) { task in
                            TaskRowEnhanced(
                                task: task,
                                isSelected: taskViewModel.selectedTask?.id == task.id,
                                onToggle: {
                                    withAnimation(.spring(response: 0.3)) {
                                        taskViewModel.toggleCompletion(task)
                                    }
                                },
                                onSelect: {
                                    withAnimation(.spring(response: 0.25)) {
                                        taskViewModel.selectTask(taskViewModel.selectedTask?.id == task.id ? nil : task)
                                    }
                                },
                                onDelete: {
                                    withAnimation(.spring()) {
                                        taskViewModel.deleteTask(task)
                                    }
                                },
                                onEdit: {
                                    editingTask = task
                                    showEditSheet = true
                                }
                            )
                            .draggable(task.id.uuidString) {
                                TaskDragPreview(task: task)
                            }
                            .dropDestination(for: String.self) { items, _ in
                                guard let droppedId = items.first,
                                      let droppedUUID = UUID(uuidString: droppedId),
                                      let sourceIndex = taskViewModel.pendingTasks.firstIndex(where: { $0.id == droppedUUID }),
                                      let destIndex = taskViewModel.pendingTasks.firstIndex(where: { $0.id == task.id })
                                else { return false }
                                
                                withAnimation(.spring(response: 0.3)) {
                                    taskViewModel.reorderTasks(
                                        from: IndexSet(integer: sourceIndex),
                                        to: destIndex > sourceIndex ? destIndex + 1 : destIndex
                                    )
                                }
                                return true
                            }
                            .transition(.asymmetric(
                                insertion: .scale.combined(with: .opacity),
                                removal: .move(edge: .leading).combined(with: .opacity)
                            ))
                        }
                        
                        if !taskViewModel.completedTasks.isEmpty {
                            CompletedSection()
                        }
                    }
                }
                .frame(maxHeight: 250)
            }
            
            // Productivity tip
            if taskViewModel.tasks.isEmpty {
                ProductivityTip()
                    .padding(.top, 8)
            }
        }
        .padding(.vertical, 8)
        .animation(.spring(response: 0.35), value: taskViewModel.tasks.count)
        .sheet(isPresented: $showEditSheet) {
            if let task = editingTask {
                TaskEditSheet(
                    task: Binding(
                        get: { task },
                        set: { editingTask = $0 }
                    ),
                    onSave: { updatedTask in
                        taskViewModel.updateTask(updatedTask)
                        showEditSheet = false
                    },
                    onCancel: {
                        showEditSheet = false
                    }
                )
            }
        }
    }
}

struct EmptyTasksView: View {
    var onQuickAdd: (() -> Void)?
    
    var body: some View {
        VStack(spacing: 16) {
            Image(systemName: "checklist")
                .font(.system(size: 44))
                .foregroundStyle(
                    LinearGradient(
                        colors: [.secondary.opacity(0.5), .secondary.opacity(0.3)],
                        startPoint: .top,
                        endPoint: .bottom
                    )
                )
                .symbolEffect(.pulse, options: .repeating.speed(0.5))
            
            VStack(spacing: 4) {
                Text("No tasks yet")
                    .font(.subheadline)
                    .fontWeight(.medium)
                    .foregroundColor(.secondary)
                
                Text("Add a task to track your pomodoros")
                    .font(.caption)
                    .foregroundColor(.secondary.opacity(0.7))
            }
            
            if let onQuickAdd = onQuickAdd {
                Button {
                    onQuickAdd()
                } label: {
                    HStack(spacing: 6) {
                        Image(systemName: "sparkles")
                        Text("Quick Add")
                    }
                    .font(.caption)
                    .fontWeight(.medium)
                }
                .buttonStyle(.borderedProminent)
                .controlSize(.small)
            }
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 32)
    }
}

struct AddTaskForm: View {
    @EnvironmentObject var taskViewModel: TaskViewModel
    @FocusState private var isFocused: Bool
    
    var body: some View {
        VStack(spacing: 10) {
            TextField("What are you working on?", text: $taskViewModel.newTaskTitle)
                .textFieldStyle(.plain)
                .font(.subheadline)
                .padding(10)
                .background(
                    RoundedRectangle(cornerRadius: 8)
                        .fill(Color(nsColor: .textBackgroundColor))
                )
                .focused($isFocused)
                .onSubmit {
                    taskViewModel.addTask()
                }
            
            HStack {
                HStack(spacing: 4) {
                    Text("Est:")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    
                    Stepper(
                        "\(taskViewModel.newTaskPomodoros) 🍅",
                        value: $taskViewModel.newTaskPomodoros,
                        in: 1...10
                    )
                    .labelsHidden()
                    
                    Text("\(taskViewModel.newTaskPomodoros)")
                        .font(.caption)
                        .monospacedDigit()
                }
                
                Spacer()
                
                HStack(spacing: 8) {
                    Button("Cancel") {
                        taskViewModel.cancelAddTask()
                    }
                    .buttonStyle(.plain)
                    .font(.caption)
                    .foregroundColor(.secondary)
                    
                    Button("Add") {
                        taskViewModel.addTask()
                    }
                    .buttonStyle(.borderedProminent)
                    .controlSize(.small)
                    .disabled(taskViewModel.newTaskTitle.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                }
            }
        }
        .padding(12)
        .background(
            RoundedRectangle(cornerRadius: 10)
                .fill(Color(nsColor: .controlBackgroundColor))
        )
        .onAppear {
            isFocused = true
        }
    }
}

struct CompletedSection: View {
    @EnvironmentObject var taskViewModel: TaskViewModel
    @State private var isExpanded = false
    
    var body: some View {
        DisclosureGroup(
            isExpanded: $isExpanded,
            content: {
                ForEach(taskViewModel.completedTasks) { task in
                    TaskRowEnhanced(
                        task: task,
                        isSelected: false,
                        onToggle: { taskViewModel.toggleCompletion(task) },
                        onSelect: {},
                        onDelete: { taskViewModel.deleteTask(task) },
                        onEdit: {}
                    )
                }
            },
            label: {
                HStack {
                    Text("Completed")
                        .font(.caption)
                        .fontWeight(.medium)
                    
                    Text("(\(taskViewModel.completedTasks.count))")
                        .font(.caption)
                }
                .foregroundColor(.secondary)
            }
        )
        .padding(.top, 8)
    }
}

struct StatsTabView: View {
    @EnvironmentObject var settingsViewModel: SettingsViewModel
    
    @State private var showDetailedInsights = false
    
    var body: some View {
        ScrollView {
            VStack(spacing: 16) {
                // Today's progress with animation
                TodayStatsCard()
                    .transition(.scale.combined(with: .opacity))
                
                // Quick stats grid
                HStack(spacing: 12) {
                    StatCard(
                        icon: "flame.fill",
                        value: "\(settingsViewModel.statistics.currentStreak)",
                        label: "Streak",
                        color: .orange
                    )
                    
                    StatCard(
                        icon: "trophy.fill",
                        value: "\(settingsViewModel.statistics.longestStreak)",
                        label: "Best",
                        color: .yellow
                    )
                    
                    StatCard(
                        icon: "clock.fill",
                        value: formatHours(settingsViewModel.statistics.totalWorkMinutes),
                        label: "Total",
                        color: .blue
                    )
                }
                
                // Daily summary message
                DailySummaryMessage(
                    completedSessions: settingsViewModel.history.todayStats.workSessions,
                    goalSessions: settingsViewModel.dailyGoal,
                    streak: settingsViewModel.statistics.currentStreak
                )
                
                // Real weekly heatmap from history
                RealtimeWeeklyHeatmap(
                    history: settingsViewModel.history,
                    dailyGoal: settingsViewModel.dailyGoal
                )
                
                // Streak indicator
                StreakIndicator(
                    currentStreak: settingsViewModel.statistics.currentStreak,
                    longestStreak: settingsViewModel.statistics.longestStreak
                )
            }
        }
        .frame(maxHeight: 380)
        .padding(.vertical, 8)
    }
    
    private func formatHours(_ minutes: Int) -> String {
        if minutes < 60 {
            return "\(minutes)m"
        }
        return "\(minutes / 60)h"
    }
}

struct TodayStatsCard: View {
    @EnvironmentObject var settingsViewModel: SettingsViewModel
    
    var body: some View {
        VStack(spacing: 12) {
            HStack {
                Text("Today")
                    .font(.headline)
                
                Spacer()
                
                Text("\(settingsViewModel.statistics.totalWorkSessions) sessions")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            DailyProgressView(
                completed: settingsViewModel.statistics.totalWorkSessions,
                goal: 8,
                color: .red
            )
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color(nsColor: .controlBackgroundColor))
        )
    }
}

struct StatCard: View {
    let icon: String
    let value: String
    let label: String
    let color: Color
    
    var body: some View {
        VStack(spacing: 8) {
            Image(systemName: icon)
                .font(.title2)
                .foregroundColor(color)
            
            Text(value)
                .font(.headline)
                .monospacedDigit()
            
            Text(label)
                .font(.caption2)
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 12)
        .background(
            RoundedRectangle(cornerRadius: 10)
                .fill(Color(nsColor: .controlBackgroundColor))
        )
    }
}

struct BottomBar: View {
    var body: some View {
        HStack {
            SettingsLink {
                HStack(spacing: 4) {
                    Image(systemName: "gear")
                    Text("Settings")
                        .font(.caption)
                }
            }
            .buttonStyle(.plain)
            .foregroundColor(.secondary)
            
            Spacer()
            
            // Keyboard shortcut hint
            Text("⌃⌘Space")
                .font(.system(size: 10, design: .monospaced))
                .foregroundColor(.secondary.opacity(0.6))
            
            Spacer()
            
            Button {
                NSApplication.shared.terminate(nil)
            } label: {
                HStack(spacing: 4) {
                    Image(systemName: "power")
                    Text("Quit")
                        .font(.caption)
                }
            }
            .buttonStyle(.plain)
            .foregroundColor(.secondary)
        }
    }
}

struct TaskDragPreview: View {
    let task: PomodoroTask
    
    var body: some View {
        HStack(spacing: 8) {
            Image(systemName: "line.3.horizontal")
                .font(.caption)
                .foregroundColor(.secondary)
            
            Text(task.title)
                .font(.caption)
                .fontWeight(.medium)
                .lineLimit(1)
            
            Spacer()
            
            Text("\(task.completedPomodoros)/\(task.estimatedPomodoros)")
                .font(.caption2)
                .foregroundColor(.secondary)
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 8)
        .background(
            RoundedRectangle(cornerRadius: 8)
                .fill(.ultraThinMaterial)
                .shadow(color: .black.opacity(0.15), radius: 8, y: 4)
        )
        .frame(width: 200)
    }
}

#Preview {
    EnhancedMenuBarView()
}
