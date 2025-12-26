import SwiftUI

struct MiniModeView: View {
    @EnvironmentObject var timerViewModel: TimerViewModel
    @Binding var isExpanded: Bool
    
    @State private var isHovering = false
    
    var body: some View {
        HStack(spacing: 12) {
            // Mini progress ring
            ZStack {
                Circle()
                    .stroke(timerViewModel.sessionColor.opacity(0.2), lineWidth: 3)
                
                Circle()
                    .trim(from: 0, to: timerViewModel.progress)
                    .stroke(timerViewModel.sessionColor, style: StrokeStyle(lineWidth: 3, lineCap: .round))
                    .rotationEffect(.degrees(-90))
                
                Image(systemName: timerViewModel.session.type.icon)
                    .font(.caption2)
                    .foregroundColor(timerViewModel.sessionColor)
            }
            .frame(width: 28, height: 28)
            
            // Time
            Text(timerViewModel.displayTime)
                .font(.system(size: 18, weight: .semibold, design: .rounded))
                .monospacedDigit()
                .contentTransition(.numericText())
            
            Spacer()
            
            // Quick controls
            HStack(spacing: 8) {
                Button {
                    timerViewModel.toggleTimer()
                } label: {
                    Image(systemName: timerViewModel.isRunning ? "pause.fill" : "play.fill")
                        .font(.caption)
                        .foregroundColor(timerViewModel.sessionColor)
                        .frame(width: 24, height: 24)
                        .background(
                            Circle()
                                .fill(timerViewModel.sessionColor.opacity(0.15))
                        )
                }
                .buttonStyle(.plain)
                
                Button {
                    withAnimation(.spring(response: 0.3)) {
                        isExpanded = true
                    }
                } label: {
                    Image(systemName: "arrow.up.left.and.arrow.down.right")
                        .font(.caption2)
                        .foregroundColor(.secondary)
                }
                .buttonStyle(.plain)
            }
            .opacity(isHovering ? 1 : 0.6)
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(.ultraThinMaterial)
                .shadow(color: .black.opacity(0.1), radius: 10, y: 5)
        )
        .onHover { hovering in
            withAnimation(.easeInOut(duration: 0.2)) {
                isHovering = hovering
            }
        }
    }
}

struct FloatingTimerView: View {
    @EnvironmentObject var timerViewModel: TimerViewModel
    
    @State private var isDragging = false
    @State private var position: CGPoint = .zero
    
    var body: some View {
        ZStack {
            // Glow effect when running
            if timerViewModel.isRunning {
                Circle()
                    .fill(timerViewModel.sessionColor.opacity(0.3))
                    .frame(width: 90, height: 90)
                    .blur(radius: 20)
            }
            
            // Main circle
            ZStack {
                Circle()
                    .fill(.ultraThinMaterial)
                    .frame(width: 70, height: 70)
                
                Circle()
                    .trim(from: 0, to: timerViewModel.progress)
                    .stroke(timerViewModel.sessionColor, style: StrokeStyle(lineWidth: 4, lineCap: .round))
                    .frame(width: 60, height: 60)
                    .rotationEffect(.degrees(-90))
                
                VStack(spacing: 0) {
                    Text(timerViewModel.displayTime)
                        .font(.system(size: 14, weight: .bold, design: .rounded))
                        .monospacedDigit()
                    
                    Image(systemName: timerViewModel.isRunning ? "pause.fill" : "play.fill")
                        .font(.system(size: 8))
                        .foregroundColor(.secondary)
                }
            }
            .shadow(color: .black.opacity(0.2), radius: 10, y: 5)
            .scaleEffect(isDragging ? 1.1 : 1.0)
        }
        .animation(.spring(response: 0.3), value: isDragging)
        .animation(.spring(response: 0.3), value: timerViewModel.isRunning)
    }
}

struct CompactStatsBar: View {
    let completedToday: Int
    let goalToday: Int
    let currentStreak: Int
    
    var body: some View {
        HStack(spacing: 16) {
            HStack(spacing: 4) {
                Image(systemName: "checkmark.circle.fill")
                    .foregroundColor(.green)
                    .font(.caption2)
                
                Text("\(completedToday)/\(goalToday)")
                    .font(.caption)
                    .monospacedDigit()
            }
            
            Divider()
                .frame(height: 12)
            
            HStack(spacing: 4) {
                Image(systemName: "flame.fill")
                    .foregroundColor(.orange)
                    .font(.caption2)
                
                Text("\(currentStreak)")
                    .font(.caption)
                    .monospacedDigit()
            }
        }
        .foregroundColor(.secondary)
    }
}

#Preview {
    VStack(spacing: 40) {
        MiniModeView(isExpanded: .constant(false))
            .frame(width: 280)
        
        FloatingTimerView()
        
        CompactStatsBar(completedToday: 5, goalToday: 8, currentStreak: 3)
    }
    .padding()
}
