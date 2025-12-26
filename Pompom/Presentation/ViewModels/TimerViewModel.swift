import Foundation
import Combine
import SwiftUI

@MainActor
final class TimerViewModel: ObservableObject {
    @Published private(set) var session: PomodoroSession
    @Published private(set) var settings: TimerSettings
    
    private let timerUseCase: TimerUseCaseProtocol
    private var cancellables = Set<AnyCancellable>()
    
    var displayTime: String {
        let minutes = Int(session.remainingTime) / 60
        let seconds = Int(session.remainingTime) % 60
        return String(format: "%02d:%02d", minutes, seconds)
    }
    
    var sessionIcon: String {
        session.type.icon
    }
    
    var sessionTitle: String {
        session.type.rawValue
    }
    
    var progress: Double {
        session.progress
    }
    
    var isRunning: Bool {
        session.state == .running
    }
    
    var isPaused: Bool {
        session.state == .paused
    }
    
    var isIdle: Bool {
        session.state == .idle
    }
    
    var canStart: Bool {
        session.state == .idle || session.state == .paused
    }
    
    var canPause: Bool {
        session.state == .running
    }
    
    var sessionColor: Color {
        switch session.type {
        case .work: return .red
        case .shortBreak: return .green
        case .longBreak: return .blue
        }
    }
    
    init(timerUseCase: TimerUseCaseProtocol) {
        self.timerUseCase = timerUseCase
        
        let initialSettings = TimerSettings.default
        self.settings = initialSettings
        self.session = PomodoroSession(type: .work, duration: initialSettings.workDuration)
        
        setupSubscriptions()
    }
    
    private func setupSubscriptions() {
        timerUseCase.sessionPublisher
            .receive(on: DispatchQueue.main)
            .sink { [weak self] session in
                self?.session = session
            }
            .store(in: &cancellables)
        
        timerUseCase.settingsPublisher
            .receive(on: DispatchQueue.main)
            .sink { [weak self] settings in
                self?.settings = settings
            }
            .store(in: &cancellables)
    }
    
    func startTimer() {
        timerUseCase.startSession()
    }
    
    func pauseTimer() {
        timerUseCase.pauseSession()
    }
    
    func resumeTimer() {
        timerUseCase.resumeSession()
    }
    
    func stopTimer() {
        timerUseCase.stopSession()
    }
    
    func skipSession() {
        timerUseCase.skipSession()
    }
    
    func resetSession() {
        timerUseCase.resetSession()
    }
    
    func toggleTimer() {
        if isRunning {
            pauseTimer()
        } else {
            startTimer()
        }
    }
}
