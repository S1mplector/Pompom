import Foundation
import Combine

@MainActor
final class SettingsViewModel: ObservableObject {
    @Published var workMinutes: Double
    @Published var shortBreakMinutes: Double
    @Published var longBreakMinutes: Double
    @Published var sessionsUntilLongBreak: Double
    @Published var autoStartBreaks: Bool
    @Published var autoStartPomodoros: Bool
    @Published var soundEnabled: Bool
    @Published var notificationsEnabled: Bool
    @Published var selectedTheme: AppTheme
    @Published var focusModeEnabled: Bool
    @Published var tickingSoundEnabled: Bool
    @Published var showTimeInMenuBar: Bool
    @Published var dailyGoal: Int
    
    @Published private(set) var statistics: SessionStatistics
    
    private let settingsUseCase: SettingsUseCaseProtocol
    private var cancellables = Set<AnyCancellable>()
    private var isUpdatingFromPublisher = false
    
    init(settingsUseCase: SettingsUseCaseProtocol) {
        self.settingsUseCase = settingsUseCase
        
        let defaultSettings = TimerSettings.default
        self.workMinutes = defaultSettings.workDuration / 60
        self.shortBreakMinutes = defaultSettings.shortBreakDuration / 60
        self.longBreakMinutes = defaultSettings.longBreakDuration / 60
        self.sessionsUntilLongBreak = Double(defaultSettings.sessionsUntilLongBreak)
        self.autoStartBreaks = defaultSettings.autoStartBreaks
        self.autoStartPomodoros = defaultSettings.autoStartPomodoros
        self.soundEnabled = defaultSettings.soundEnabled
        self.notificationsEnabled = defaultSettings.notificationsEnabled
        self.selectedTheme = defaultSettings.theme
        self.focusModeEnabled = defaultSettings.focusModeEnabled
        self.tickingSoundEnabled = defaultSettings.tickingSoundEnabled
        self.showTimeInMenuBar = defaultSettings.showTimeInMenuBar
        self.dailyGoal = defaultSettings.dailyGoal
        self.statistics = .empty
        
        setupSubscriptions()
    }
    
    private func setupSubscriptions() {
        settingsUseCase.settingsPublisher
            .receive(on: DispatchQueue.main)
            .sink { [weak self] settings in
                self?.updateFromSettings(settings)
            }
            .store(in: &cancellables)
        
        settingsUseCase.statisticsPublisher
            .receive(on: DispatchQueue.main)
            .sink { [weak self] statistics in
                self?.statistics = statistics
            }
            .store(in: &cancellables)
        
        setupSettingsBinding()
    }
    
    private func updateFromSettings(_ settings: TimerSettings) {
        isUpdatingFromPublisher = true
        workMinutes = settings.workDuration / 60
        shortBreakMinutes = settings.shortBreakDuration / 60
        longBreakMinutes = settings.longBreakDuration / 60
        sessionsUntilLongBreak = Double(settings.sessionsUntilLongBreak)
        autoStartBreaks = settings.autoStartBreaks
        autoStartPomodoros = settings.autoStartPomodoros
        soundEnabled = settings.soundEnabled
        notificationsEnabled = settings.notificationsEnabled
        selectedTheme = settings.theme
        focusModeEnabled = settings.focusModeEnabled
        tickingSoundEnabled = settings.tickingSoundEnabled
        showTimeInMenuBar = settings.showTimeInMenuBar
        dailyGoal = settings.dailyGoal
        isUpdatingFromPublisher = false
    }
    
    private func setupSettingsBinding() {
        Publishers.CombineLatest4(
            $workMinutes,
            $shortBreakMinutes,
            $longBreakMinutes,
            $sessionsUntilLongBreak
        )
        .combineLatest(
            Publishers.CombineLatest4(
                $autoStartBreaks,
                $autoStartPomodoros,
                $soundEnabled,
                $notificationsEnabled
            )
        )
        .combineLatest(
            Publishers.CombineLatest4(
                $selectedTheme,
                $focusModeEnabled,
                $tickingSoundEnabled,
                $showTimeInMenuBar
            )
        )
        .combineLatest($dailyGoal)
        .dropFirst()
        .debounce(for: .milliseconds(300), scheduler: DispatchQueue.main)
        .sink { [weak self] _ in
            self?.saveSettings()
        }
        .store(in: &cancellables)
    }
    
    private func saveSettings() {
        guard !isUpdatingFromPublisher else { return }
        
        let settings = TimerSettings(
            workDuration: workMinutes * 60,
            shortBreakDuration: shortBreakMinutes * 60,
            longBreakDuration: longBreakMinutes * 60,
            sessionsUntilLongBreak: Int(sessionsUntilLongBreak),
            autoStartBreaks: autoStartBreaks,
            autoStartPomodoros: autoStartPomodoros,
            soundEnabled: soundEnabled,
            notificationsEnabled: notificationsEnabled,
            theme: selectedTheme,
            focusModeEnabled: focusModeEnabled,
            tickingSoundEnabled: tickingSoundEnabled,
            showTimeInMenuBar: showTimeInMenuBar,
            dailyGoal: dailyGoal
        )
        settingsUseCase.updateSettings(settings)
    }
    
    func resetSettings() {
        settingsUseCase.resetSettings()
    }
    
    func resetStatistics() {
        settingsUseCase.resetStatistics()
    }
    
    func requestNotificationPermission() {
        Task {
            _ = await settingsUseCase.requestNotificationPermission()
        }
    }
}
