import Foundation
import Combine

protocol TaskUseCaseProtocol {
    var tasksPublisher: AnyPublisher<[PomodoroTask], Never> { get }
    var selectedTaskPublisher: AnyPublisher<PomodoroTask?, Never> { get }
    
    func addTask(title: String, estimatedPomodoros: Int)
    func addTaskDirectly(_ task: PomodoroTask)
    func updateTask(_ task: PomodoroTask)
    func deleteTask(_ task: PomodoroTask)
    func toggleTaskCompletion(_ task: PomodoroTask)
    func incrementTaskPomodoro(_ task: PomodoroTask)
    func selectTask(_ task: PomodoroTask?)
    func reorderTasks(from: IndexSet, to: Int)
    func clearCompletedTasks()
}

final class TaskUseCase: TaskUseCaseProtocol {
    private let taskPersistence: TaskPersistencePort
    
    private let tasksSubject: CurrentValueSubject<[PomodoroTask], Never>
    private let selectedTaskSubject: CurrentValueSubject<PomodoroTask?, Never>
    private var cancellables = Set<AnyCancellable>()
    
    var tasksPublisher: AnyPublisher<[PomodoroTask], Never> {
        tasksSubject.eraseToAnyPublisher()
    }
    
    var selectedTaskPublisher: AnyPublisher<PomodoroTask?, Never> {
        selectedTaskSubject.eraseToAnyPublisher()
    }
    
    init(taskPersistence: TaskPersistencePort) {
        self.taskPersistence = taskPersistence
        
        let tasks = taskPersistence.load()
        self.tasksSubject = CurrentValueSubject(tasks)
        self.selectedTaskSubject = CurrentValueSubject(nil)
        
        setupPersistenceSubscription()
    }
    
    private func setupPersistenceSubscription() {
        tasksSubject
            .dropFirst()
            .sink { [weak self] tasks in
                self?.taskPersistence.save(tasks)
            }
            .store(in: &cancellables)
    }
    
    func addTask(title: String, estimatedPomodoros: Int) {
        let trimmedTitle = title.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmedTitle.isEmpty else { return }
        
        let task = PomodoroTask(title: trimmedTitle, estimatedPomodoros: estimatedPomodoros)
        var tasks = tasksSubject.value
        tasks.append(task)
        tasksSubject.send(tasks)
    }
    
    func addTaskDirectly(_ task: PomodoroTask) {
        var tasks = tasksSubject.value
        tasks.append(task)
        tasksSubject.send(tasks)
    }
    
    func updateTask(_ task: PomodoroTask) {
        var tasks = tasksSubject.value
        guard let index = tasks.firstIndex(where: { $0.id == task.id }) else { return }
        tasks[index] = task
        tasksSubject.send(tasks)
        
        if selectedTaskSubject.value?.id == task.id {
            selectedTaskSubject.send(task)
        }
    }
    
    func deleteTask(_ task: PomodoroTask) {
        var tasks = tasksSubject.value
        tasks.removeAll { $0.id == task.id }
        tasksSubject.send(tasks)
        
        if selectedTaskSubject.value?.id == task.id {
            selectedTaskSubject.send(nil)
        }
    }
    
    func toggleTaskCompletion(_ task: PomodoroTask) {
        let updatedTask = task.withCompletion(!task.isCompleted)
        updateTask(updatedTask)
    }
    
    func incrementTaskPomodoro(_ task: PomodoroTask) {
        let updatedTask = task.withIncrementedPomodoro()
        updateTask(updatedTask)
    }
    
    func selectTask(_ task: PomodoroTask?) {
        selectedTaskSubject.send(task)
    }
    
    func reorderTasks(from source: IndexSet, to destination: Int) {
        var tasks = tasksSubject.value
        tasks.move(fromOffsets: source, toOffset: destination)
        tasksSubject.send(tasks)
    }
    
    func clearCompletedTasks() {
        var tasks = tasksSubject.value
        let completedIds = tasks.filter { $0.isCompleted }.map { $0.id }
        tasks.removeAll { $0.isCompleted }
        tasksSubject.send(tasks)
        
        if let selectedId = selectedTaskSubject.value?.id,
           completedIds.contains(selectedId) {
            selectedTaskSubject.send(nil)
        }
    }
}
