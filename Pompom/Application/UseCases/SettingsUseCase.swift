import Foundation
import Combine

protocol SettingsUseCaseProtocol {
    var settingsPublisher: AnyPublisher<TimerSettings, Never> { get }
    var statisticsPublisher: AnyPublisher<SessionStatistics, Never> { get }
    var historyPublisher: AnyPublisher<SessionHistory, Never> { get }
    
    func updateSettings(_ settings: TimerSettings)
    func resetSettings()
    func resetStatistics()
    func resetHistory()
    func requestNotificationPermission() async -> Bool
    func loadHistory() -> SessionHistory
}

final class SettingsUseCase: SettingsUseCaseProtocol {
    private let settingsPersistence: SettingsPersistencePort
    private let statisticsPersistence: StatisticsPersistencePort
    private let historyPersistence: HistoryPersistencePort
    private let notificationPort: NotificationPort
    
    private let statisticsSubject: CurrentValueSubject<SessionStatistics, Never>
    
    var settingsPublisher: AnyPublisher<TimerSettings, Never> {
        settingsPersistence.settingsPublisher
    }
    
    var statisticsPublisher: AnyPublisher<SessionStatistics, Never> {
        statisticsSubject.eraseToAnyPublisher()
    }
    
    var historyPublisher: AnyPublisher<SessionHistory, Never> {
        historyPersistence.historyPublisher
    }
    
    init(
        settingsPersistence: SettingsPersistencePort,
        statisticsPersistence: StatisticsPersistencePort,
        historyPersistence: HistoryPersistencePort,
        notificationPort: NotificationPort
    ) {
        self.settingsPersistence = settingsPersistence
        self.statisticsPersistence = statisticsPersistence
        self.historyPersistence = historyPersistence
        self.notificationPort = notificationPort
        
        let statistics = statisticsPersistence.load()
        self.statisticsSubject = CurrentValueSubject(statistics)
    }
    
    func loadHistory() -> SessionHistory {
        historyPersistence.load()
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
    
    func resetHistory() {
        historyPersistence.save(.empty)
    }
    
    func requestNotificationPermission() async -> Bool {
        await notificationPort.requestAuthorization()
    }
}
