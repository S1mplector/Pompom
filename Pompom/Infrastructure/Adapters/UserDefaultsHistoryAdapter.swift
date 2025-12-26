import Foundation
import Combine

final class UserDefaultsHistoryAdapter: HistoryPersistencePort {
    private let defaults: UserDefaults
    private let key = "pompom.history"
    private let historySubject: CurrentValueSubject<SessionHistory, Never>
    
    var historyPublisher: AnyPublisher<SessionHistory, Never> {
        historySubject.eraseToAnyPublisher()
    }
    
    init(defaults: UserDefaults = .standard) {
        self.defaults = defaults
        let history = Self.loadFromDefaults(defaults, key: key)
        self.historySubject = CurrentValueSubject(history)
    }
    
    func save(_ history: SessionHistory) {
        guard let data = try? JSONEncoder().encode(history) else { return }
        defaults.set(data, forKey: key)
        historySubject.send(history)
    }
    
    func load() -> SessionHistory {
        historySubject.value
    }
    
    private static func loadFromDefaults(_ defaults: UserDefaults, key: String) -> SessionHistory {
        guard let data = defaults.data(forKey: key),
              let history = try? JSONDecoder().decode(SessionHistory.self, from: data) else {
            return .empty
        }
        return history
    }
}
