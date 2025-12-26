import SwiftUI

struct MenuBarView: View {
    @EnvironmentObject var timerViewModel: TimerViewModel
    @EnvironmentObject var settingsViewModel: SettingsViewModel
    @EnvironmentObject var taskViewModel: TaskViewModel
    
    var body: some View {
        VStack(spacing: 0) {
            TimerDisplayView()
            
            Divider()
                .padding(.vertical, 8)
            
            TaskListView()
            
            Divider()
                .padding(.vertical, 8)
            
            BottomControlsView()
        }
        .padding()
        .frame(width: 320)
    }
}

struct TimerDisplayView: View {
    @EnvironmentObject var timerViewModel: TimerViewModel
    
    var body: some View {
        VStack(spacing: 16) {
            SessionIndicatorView()
            
            TimerCircleView()
            
            TimerControlsView()
        }
    }
}

struct SessionIndicatorView: View {
    @EnvironmentObject var timerViewModel: TimerViewModel
    
    var body: some View {
        HStack(spacing: 8) {
            Image(systemName: timerViewModel.sessionIcon)
                .foregroundColor(timerViewModel.sessionColor)
            
            Text(timerViewModel.sessionTitle)
                .font(.headline)
                .foregroundColor(.primary)
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 8)
        .background(
            Capsule()
                .fill(timerViewModel.sessionColor.opacity(0.15))
        )
    }
}

struct TimerCircleView: View {
    @EnvironmentObject var timerViewModel: TimerViewModel
    
    var body: some View {
        ZStack {
            Circle()
                .stroke(
                    timerViewModel.sessionColor.opacity(0.2),
                    lineWidth: 8
                )
            
            Circle()
                .trim(from: 0, to: timerViewModel.progress)
                .stroke(
                    timerViewModel.sessionColor,
                    style: StrokeStyle(lineWidth: 8, lineCap: .round)
                )
                .rotationEffect(.degrees(-90))
                .animation(.linear(duration: 0.5), value: timerViewModel.progress)
            
            VStack(spacing: 4) {
                Text(timerViewModel.displayTime)
                    .font(.system(size: 48, weight: .medium, design: .monospaced))
                    .foregroundColor(.primary)
                
                if timerViewModel.isPaused {
                    Text("PAUSED")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
        }
        .frame(width: 180, height: 180)
    }
}

struct TimerControlsView: View {
    @EnvironmentObject var timerViewModel: TimerViewModel
    
    var body: some View {
        HStack(spacing: 16) {
            Button(action: { timerViewModel.resetSession() }) {
                Image(systemName: "arrow.counterclockwise")
                    .font(.title2)
            }
            .buttonStyle(.plain)
            .disabled(timerViewModel.isIdle)
            .opacity(timerViewModel.isIdle ? 0.5 : 1)
            
            Button(action: { timerViewModel.toggleTimer() }) {
                Image(systemName: timerViewModel.isRunning ? "pause.fill" : "play.fill")
                    .font(.title)
                    .frame(width: 60, height: 60)
                    .background(timerViewModel.sessionColor)
                    .foregroundColor(.white)
                    .clipShape(Circle())
            }
            .buttonStyle(.plain)
            
            Button(action: { timerViewModel.skipSession() }) {
                Image(systemName: "forward.fill")
                    .font(.title2)
            }
            .buttonStyle(.plain)
        }
    }
}

struct BottomControlsView: View {
    var body: some View {
        HStack {
            SettingsButton()
            
            Spacer()
            
            QuitButton()
        }
    }
}

struct SettingsButton: View {
    var body: some View {
        SettingsLink {
            Label("Settings", systemImage: "gear")
        }
        .buttonStyle(.plain)
    }
}

struct QuitButton: View {
    var body: some View {
        Button(action: {
            NSApplication.shared.terminate(nil)
        }) {
            Label("Quit", systemImage: "power")
        }
        .buttonStyle(.plain)
    }
}

#Preview {
    MenuBarView()
}
