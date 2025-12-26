import Foundation
import Combine

protocol HistoryPersistencePort {
    func save(_ history: SessionHistory)
    func load() -> SessionHistory
    var historyPublisher: AnyPublisher<SessionHistory, Never> { get }
}
