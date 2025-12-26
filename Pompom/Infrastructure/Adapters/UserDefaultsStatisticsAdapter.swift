import Foundation

final class UserDefaultsStatisticsAdapter: StatisticsPersistencePort {
    private let defaults: UserDefaults
    private let key = "pompom.statistics"
    
    init(defaults: UserDefaults = .standard) {
        self.defaults = defaults
    }
    
    func save(_ statistics: SessionStatistics) {
        guard let data = try? JSONEncoder().encode(statistics) else { return }
        defaults.set(data, forKey: key)
    }
    
    func load() -> SessionStatistics {
        guard let data = defaults.data(forKey: key),
              let statistics = try? JSONDecoder().decode(SessionStatistics.self, from: data) else {
            return .empty
        }
        return statistics
    }
}
