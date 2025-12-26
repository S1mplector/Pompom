import Foundation
import Combine

@MainActor
final class TaskViewModel: ObservableObject {
    @Published private(set) var tasks: [PomodoroTask] = []
    @Published private(set) var selectedTask: PomodoroTask?
    @Published var newTaskTitle: String = ""
    @Published var newTaskPomodoros: Int = 1
    @Published var isAddingTask: Bool = false
    
    private let taskUseCase: TaskUseCaseProtocol
    private var cancellables = Set<AnyCancellable>()
    
    var pendingTasks: [PomodoroTask] {
        tasks.filter { !$0.isCompleted }
    }
    
    var completedTasks: [PomodoroTask] {
        tasks.filter { $0.isCompleted }
    }
    
    var hasCompletedTasks: Bool {
        !completedTasks.isEmpty
    }
    
    var totalEstimatedPomodoros: Int {
        pendingTasks.reduce(0) { $0 + $1.estimatedPomodoros }
    }
    
    var totalCompletedPomodoros: Int {
        tasks.reduce(0) { $0 + $1.completedPomodoros }
    }
    
    init(taskUseCase: TaskUseCaseProtocol) {
        self.taskUseCase = taskUseCase
        setupSubscriptions()
    }
    
    private func setupSubscriptions() {
        taskUseCase.tasksPublisher
            .receive(on: DispatchQueue.main)
            .sink { [weak self] tasks in
                self?.tasks = tasks
            }
            .store(in: &cancellables)
        
        taskUseCase.selectedTaskPublisher
            .receive(on: DispatchQueue.main)
            .sink { [weak self] task in
                self?.selectedTask = task
            }
            .store(in: &cancellables)
    }
    
    func addTask() {
        guard !newTaskTitle.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else { return }
        taskUseCase.addTask(title: newTaskTitle, estimatedPomodoros: newTaskPomodoros)
        newTaskTitle = ""
        newTaskPomodoros = 1
        isAddingTask = false
    }
    
    func deleteTask(_ task: PomodoroTask) {
        taskUseCase.deleteTask(task)
    }
    
    func toggleCompletion(_ task: PomodoroTask) {
        taskUseCase.toggleTaskCompletion(task)
    }
    
    func incrementPomodoro(_ task: PomodoroTask) {
        taskUseCase.incrementTaskPomodoro(task)
    }
    
    func selectTask(_ task: PomodoroTask?) {
        taskUseCase.selectTask(task)
    }
    
    func reorderTasks(from source: IndexSet, to destination: Int) {
        taskUseCase.reorderTasks(from: source, to: destination)
    }
    
    func clearCompletedTasks() {
        taskUseCase.clearCompletedTasks()
    }
    
    func cancelAddTask() {
        newTaskTitle = ""
        newTaskPomodoros = 1
        isAddingTask = false
    }
    
    func addTaskDirectly(_ task: PomodoroTask) {
        taskUseCase.addTaskDirectly(task)
    }
    
    func updateTask(_ task: PomodoroTask) {
        taskUseCase.updateTask(task)
    }
}
