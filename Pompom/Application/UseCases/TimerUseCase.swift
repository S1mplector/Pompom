import Foundation
import Combine

protocol TimerUseCaseProtocol {
    var sessionPublisher: AnyPublisher<PomodoroSession, Never> { get }
    var settingsPublisher: AnyPublisher<TimerSettings, Never> { get }
    
    func startSession()
    func pauseSession()
    func resumeSession()
    func stopSession()
    func skipSession()
    func resetSession()
}

final class TimerUseCase: TimerUseCaseProtocol {
    private let timerPort: TimerPort
    private let notificationPort: NotificationPort
    private let soundPort: SoundPort
    private let settingsPersistence: SettingsPersistencePort
    private let statisticsPersistence: StatisticsPersistencePort
    private let historyPersistence: HistoryPersistencePort
    
    private let sessionSubject: CurrentValueSubject<PomodoroSession, Never>
    private var completedWorkSessions: Int = 0
    private var cancellables = Set<AnyCancellable>()
    private var currentTaskId: UUID?
    private var currentTaskTitle: String?
    
    var sessionPublisher: AnyPublisher<PomodoroSession, Never> {
        sessionSubject.eraseToAnyPublisher()
    }
    
    var settingsPublisher: AnyPublisher<TimerSettings, Never> {
        settingsPersistence.settingsPublisher
    }
    
    private var currentSettings: TimerSettings {
        settingsPersistence.load()
    }
    
    init(
        timerPort: TimerPort,
        notificationPort: NotificationPort,
        soundPort: SoundPort,
        settingsPersistence: SettingsPersistencePort,
        statisticsPersistence: StatisticsPersistencePort,
        historyPersistence: HistoryPersistencePort
    ) {
        self.timerPort = timerPort
        self.notificationPort = notificationPort
        self.soundPort = soundPort
        self.settingsPersistence = settingsPersistence
        self.statisticsPersistence = statisticsPersistence
        self.historyPersistence = historyPersistence
        
        let settings = settingsPersistence.load()
        let initialSession = PomodoroSession(type: .work, duration: settings.workDuration)
        self.sessionSubject = CurrentValueSubject(initialSession)
        
        setupTimerSubscription()
        setupSettingsSubscription()
    }
    
    func setCurrentTask(id: UUID?, title: String?) {
        self.currentTaskId = id
        self.currentTaskTitle = title
    }
    
    private func setupTimerSubscription() {
        timerPort.tickPublisher
            .sink { [weak self] _ in
                self?.tick()
            }
            .store(in: &cancellables)
    }
    
    private func setupSettingsSubscription() {
        settingsPersistence.settingsPublisher
            .sink { [weak self] settings in
                self?.handleSettingsChange(settings)
            }
            .store(in: &cancellables)
    }
    
    private func handleSettingsChange(_ settings: TimerSettings) {
        let currentSession = sessionSubject.value
        guard currentSession.state == .idle else { return }
        
        let newDuration = settings.duration(for: currentSession.type)
        let updatedSession = PomodoroSession(type: currentSession.type, duration: newDuration)
        sessionSubject.send(updatedSession)
    }
    
    private func tick() {
        var session = sessionSubject.value
        guard session.state == .running else { return }
        
        session = session.withRemainingTime(session.remainingTime - 1)
        
        if session.remainingTime <= 0 {
            completeSession()
        } else {
            sessionSubject.send(session)
        }
    }
    
    func startSession() {
        var session = sessionSubject.value
        session = session.withState(.running)
        sessionSubject.send(session)
        timerPort.start()
    }
    
    func pauseSession() {
        var session = sessionSubject.value
        session = session.withState(.paused)
        sessionSubject.send(session)
        timerPort.stop()
    }
    
    func resumeSession() {
        startSession()
    }
    
    func stopSession() {
        timerPort.stop()
        let settings = currentSettings
        let session = PomodoroSession(type: .work, duration: settings.workDuration)
        sessionSubject.send(session)
        completedWorkSessions = 0
    }
    
    func skipSession() {
        timerPort.stop()
        transitionToNextSession()
    }
    
    func resetSession() {
        timerPort.stop()
        let currentSession = sessionSubject.value
        let settings = currentSettings
        let duration = settings.duration(for: currentSession.type)
        let resetSession = PomodoroSession(type: currentSession.type, duration: duration)
        sessionSubject.send(resetSession)
    }
    
    private func completeSession() {
        timerPort.stop()
        
        let completedSession = sessionSubject.value
        
        // Update statistics
        var statistics = statisticsPersistence.load()
        statistics = statistics.withCompletedSession(
            type: completedSession.type,
            duration: completedSession.duration
        )
        statisticsPersistence.save(statistics)
        
        // Record to history
        let historyRecord = CompletedSession(
            type: completedSession.type,
            duration: completedSession.duration,
            completedAt: Date(),
            taskId: currentTaskId,
            taskTitle: currentTaskTitle
        )
        var history = historyPersistence.load()
        history.addCompletedSession(historyRecord)
        historyPersistence.save(history)
        
        let settings = currentSettings
        
        if settings.soundEnabled {
            if completedSession.type == .work {
                soundPort.playSessionComplete()
            } else {
                soundPort.playBreakComplete()
            }
        }
        
        if settings.notificationsEnabled {
            let (title, body) = notificationContent(for: completedSession.type)
            notificationPort.sendNotification(title: title, body: body)
        }
        
        if completedSession.type == .work {
            completedWorkSessions += 1
        }
        
        transitionToNextSession()
        
        if shouldAutoStart(after: completedSession.type) {
            startSession()
        }
    }
    
    private func transitionToNextSession() {
        let currentSession = sessionSubject.value
        let settings = currentSettings
        let nextType = nextSessionType(after: currentSession.type)
        let duration = settings.duration(for: nextType)
        let nextSession = PomodoroSession(type: nextType, duration: duration)
        sessionSubject.send(nextSession)
    }
    
    private func nextSessionType(after currentType: SessionType) -> SessionType {
        let settings = currentSettings
        
        switch currentType {
        case .work:
            if completedWorkSessions >= settings.sessionsUntilLongBreak {
                completedWorkSessions = 0
                return .longBreak
            }
            return .shortBreak
        case .shortBreak, .longBreak:
            return .work
        }
    }
    
    private func shouldAutoStart(after sessionType: SessionType) -> Bool {
        let settings = currentSettings
        switch sessionType {
        case .work:
            return settings.autoStartBreaks
        case .shortBreak, .longBreak:
            return settings.autoStartPomodoros
        }
    }
    
    private func notificationContent(for sessionType: SessionType) -> (title: String, body: String) {
        switch sessionType {
        case .work:
            return ("Work Session Complete!", "Time for a break. Great job staying focused!")
        case .shortBreak:
            return ("Break Over", "Ready to get back to work?")
        case .longBreak:
            return ("Long Break Over", "Feeling refreshed? Let's continue!")
        }
    }
}
