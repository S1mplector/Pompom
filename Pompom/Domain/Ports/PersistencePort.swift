import Foundation
import Combine

protocol SettingsPersistencePort {
    func save(_ settings: TimerSettings)
    func load() -> TimerSettings
    var settingsPublisher: AnyPublisher<TimerSettings, Never> { get }
}

protocol TaskPersistencePort {
    func save(_ tasks: [PomodoroTask])
    func load() -> [PomodoroTask]
    var tasksPublisher: AnyPublisher<[PomodoroTask], Never> { get }
}

protocol StatisticsPersistencePort {
    func save(_ statistics: SessionStatistics)
    func load() -> SessionStatistics
}
