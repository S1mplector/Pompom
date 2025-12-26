import Foundation
import Combine

final class SystemTimerAdapter: TimerPort {
    private var timer: Timer?
    private let tickSubject = PassthroughSubject<Date, Never>()
    
    var tickPublisher: AnyPublisher<Date, Never> {
        tickSubject.eraseToAnyPublisher()
    }
    
    func start() {
        stop()
        timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { [weak self] _ in
            self?.tickSubject.send(Date())
        }
        RunLoop.main.add(timer!, forMode: .common)
    }
    
    func stop() {
        timer?.invalidate()
        timer = nil
    }
    
    deinit {
        stop()
    }
}
