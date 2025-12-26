import SwiftUI

@main
struct PompomApp: App {
    @StateObject private var container = DependencyContainer()
    @State private var showOnboarding = OnboardingManager.shouldShowOnboarding
    
    var body: some Scene {
        MenuBarExtra {
            ZStack {
                EnhancedMenuBarView()
                    .environmentObject(container.timerViewModel)
                    .environmentObject(container.settingsViewModel)
                    .environmentObject(container.taskViewModel)
                
                if showOnboarding {
                    OnboardingView(isPresented: $showOnboarding)
                        .transition(.opacity)
                }
            }
            .animation(.easeInOut, value: showOnboarding)
        } label: {
            MenuBarLabel()
                .environmentObject(container.timerViewModel)
                .environmentObject(container.settingsViewModel)
        }
        .menuBarExtraStyle(.window)
        
        Settings {
            EnhancedSettingsView()
                .environmentObject(container.settingsViewModel)
                .environmentObject(container.taskViewModel)
        }
    }
}

struct MenuBarLabel: View {
    @EnvironmentObject var timerViewModel: TimerViewModel
    @EnvironmentObject var settingsViewModel: SettingsViewModel
    
    var body: some View {
        HStack(spacing: 4) {
            Image(systemName: timerViewModel.sessionIcon)
                .symbolRenderingMode(.hierarchical)
                .foregroundColor(menuBarColor)
            
            if settingsViewModel.showTimeInMenuBar {
                Text(timerViewModel.displayTime)
                    .monospacedDigit()
                    .foregroundColor(menuBarColor)
            }
        }
    }
    
    private var menuBarColor: Color {
        if timerViewModel.isRunning {
            return timerViewModel.sessionColor
        }
        return .primary
    }
}
