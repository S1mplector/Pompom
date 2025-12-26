import Foundation
import SwiftUI

@MainActor
final class DependencyContainer: ObservableObject {
    
    // MARK: - Ports (Infrastructure Adapters)
    
    private lazy var timerPort: TimerPort = {
        SystemTimerAdapter()
    }()
    
    private lazy var notificationPort: NotificationPort = {
        UserNotificationAdapter()
    }()
    
    private lazy var soundPort: SoundPort = {
        SystemSoundAdapter()
    }()
    
    private lazy var settingsPersistence: SettingsPersistencePort = {
        UserDefaultsSettingsAdapter()
    }()
    
    private lazy var taskPersistence: TaskPersistencePort = {
        UserDefaultsTaskAdapter()
    }()
    
    private lazy var statisticsPersistence: StatisticsPersistencePort = {
        UserDefaultsStatisticsAdapter()
    }()
    
    // MARK: - Use Cases
    
    private lazy var timerUseCase: TimerUseCaseProtocol = {
        TimerUseCase(
            timerPort: timerPort,
            notificationPort: notificationPort,
            soundPort: soundPort,
            settingsPersistence: settingsPersistence,
            statisticsPersistence: statisticsPersistence
        )
    }()
    
    private lazy var taskUseCase: TaskUseCaseProtocol = {
        TaskUseCase(taskPersistence: taskPersistence)
    }()
    
    private lazy var settingsUseCase: SettingsUseCaseProtocol = {
        SettingsUseCase(
            settingsPersistence: settingsPersistence,
            statisticsPersistence: statisticsPersistence,
            notificationPort: notificationPort
        )
    }()
    
    // MARK: - View Models
    
    lazy var timerViewModel: TimerViewModel = {
        TimerViewModel(timerUseCase: timerUseCase)
    }()
    
    lazy var taskViewModel: TaskViewModel = {
        TaskViewModel(taskUseCase: taskUseCase)
    }()
    
    lazy var settingsViewModel: SettingsViewModel = {
        SettingsViewModel(settingsUseCase: settingsUseCase)
    }()
}
