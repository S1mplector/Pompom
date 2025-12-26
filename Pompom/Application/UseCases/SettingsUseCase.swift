import Foundation
import Combine

protocol SettingsUseCaseProtocol {
    var settingsPublisher: AnyPublisher<TimerSettings, Never> { get }
    var statisticsPublisher: AnyPublisher<SessionStatistics, Never> { get }
    
    func updateSettings(_ settings: TimerSettings)
    func resetSettings()
    func resetStatistics()
    func requestNotificationPermission() async -> Bool
}

final class SettingsUseCase: SettingsUseCaseProtocol {
    private let settingsPersistence: SettingsPersistencePort
    private let statisticsPersistence: StatisticsPersistencePort
    private let notificationPort: NotificationPort
    
    private let statisticsSubject: CurrentValueSubject<SessionStatistics, Never>
    
    var settingsPublisher: AnyPublisher<TimerSettings, Never> {
        settingsPersistence.settingsPublisher
    }
    
    var statisticsPublisher: AnyPublisher<SessionStatistics, Never> {
        statisticsSubject.eraseToAnyPublisher()
    }
    
    init(
        settingsPersistence: SettingsPersistencePort,
        statisticsPersistence: StatisticsPersistencePort,
        notificationPort: NotificationPort
    ) {
        self.settingsPersistence = settingsPersistence
        self.statisticsPersistence = statisticsPersistence
        self.notificationPort = notificationPort
        
        let statistics = statisticsPersistence.load()
        self.statisticsSubject = CurrentValueSubject(statistics)
    }
    
    func updateSettings(_ settings: TimerSettings) {
        settingsPersistence.save(settings)
    }
    
    func resetSettings() {
        settingsPersistence.save(.default)
    }
    
    func resetStatistics() {
        statisticsPersistence.save(.empty)
        statisticsSubject.send(.empty)
    }
    
    func requestNotificationPermission() async -> Bool {
        await notificationPort.requestAuthorization()
    }
}
