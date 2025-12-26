import Foundation
import Combine

final class UserDefaultsTaskAdapter: TaskPersistencePort {
    private let defaults: UserDefaults
    private let key = "pompom.tasks"
    private let tasksSubject: CurrentValueSubject<[PomodoroTask], Never>
    
    var tasksPublisher: AnyPublisher<[PomodoroTask], Never> {
        tasksSubject.eraseToAnyPublisher()
    }
    
    init(defaults: UserDefaults = .standard) {
        self.defaults = defaults
        let tasks = Self.loadFromDefaults(defaults, key: key)
        self.tasksSubject = CurrentValueSubject(tasks)
    }
    
    func save(_ tasks: [PomodoroTask]) {
        guard let data = try? JSONEncoder().encode(tasks) else { return }
        defaults.set(data, forKey: key)
        tasksSubject.send(tasks)
    }
    
    func load() -> [PomodoroTask] {
        tasksSubject.value
    }
    
    private static func loadFromDefaults(_ defaults: UserDefaults, key: String) -> [PomodoroTask] {
        guard let data = defaults.data(forKey: key),
              let tasks = try? JSONDecoder().decode([PomodoroTask].self, from: data) else {
            return []
        }
        return tasks
    }
}
