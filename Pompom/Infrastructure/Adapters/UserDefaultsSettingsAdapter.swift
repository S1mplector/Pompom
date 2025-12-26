import Foundation
import Combine

final class UserDefaultsSettingsAdapter: SettingsPersistencePort {
    private let defaults: UserDefaults
    private let key = "pompom.settings"
    private let settingsSubject: CurrentValueSubject<TimerSettings, Never>
    
    var settingsPublisher: AnyPublisher<TimerSettings, Never> {
        settingsSubject.eraseToAnyPublisher()
    }
    
    init(defaults: UserDefaults = .standard) {
        self.defaults = defaults
        let settings = Self.loadFromDefaults(defaults, key: key)
        self.settingsSubject = CurrentValueSubject(settings)
    }
    
    func save(_ settings: TimerSettings) {
        guard let data = try? JSONEncoder().encode(settings) else { return }
        defaults.set(data, forKey: key)
        settingsSubject.send(settings)
    }
    
    func load() -> TimerSettings {
        settingsSubject.value
    }
    
    private static func loadFromDefaults(_ defaults: UserDefaults, key: String) -> TimerSettings {
        guard let data = defaults.data(forKey: key),
              let settings = try? JSONDecoder().decode(TimerSettings.self, from: data) else {
            return .default
        }
        return settings
    }
}
