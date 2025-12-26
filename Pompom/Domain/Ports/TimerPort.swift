import Foundation
import Combine

protocol TimerPort {
    var tickPublisher: AnyPublisher<Date, Never> { get }
    func start()
    func stop()
}
