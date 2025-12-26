import SwiftUI

struct CircularProgressView: View {
    let progress: Double
    let color: Color
    let lineWidth: CGFloat
    let showGlow: Bool
    
    init(progress: Double, color: Color, lineWidth: CGFloat = 8, showGlow: Bool = true) {
        self.progress = progress
        self.color = color
        self.lineWidth = lineWidth
        self.showGlow = showGlow
    }
    
    var body: some View {
        ZStack {
            // Background circle
            Circle()
                .stroke(
                    color.opacity(0.15),
                    lineWidth: lineWidth
                )
            
            // Progress circle
            Circle()
                .trim(from: 0, to: min(progress, 1.0))
                .stroke(
                    AngularGradient(
                        gradient: Gradient(colors: [
                            color.opacity(0.8),
                            color,
                            color.opacity(0.8)
                        ]),
                        center: .center,
                        startAngle: .degrees(-90),
                        endAngle: .degrees(270)
                    ),
                    style: StrokeStyle(lineWidth: lineWidth, lineCap: .round)
                )
                .rotationEffect(.degrees(-90))
                .animation(.easeInOut(duration: 0.3), value: progress)
            
            // Glow effect
            if showGlow && progress > 0 {
                Circle()
                    .trim(from: 0, to: min(progress, 1.0))
                    .stroke(
                        color,
                        style: StrokeStyle(lineWidth: lineWidth, lineCap: .round)
                    )
                    .rotationEffect(.degrees(-90))
                    .blur(radius: 8)
                    .opacity(0.5)
            }
        }
    }
}

struct PulsingCircle: View {
    let color: Color
    @State private var isPulsing = false
    
    var body: some View {
        Circle()
            .fill(color.opacity(0.3))
            .scaleEffect(isPulsing ? 1.1 : 1.0)
            .animation(
                .easeInOut(duration: 1.0).repeatForever(autoreverses: true),
                value: isPulsing
            )
            .onAppear {
                isPulsing = true
            }
    }
}

struct AnimatedTimerText: View {
    let time: String
    let isRunning: Bool
    
    var body: some View {
        Text(time)
            .font(.system(size: 52, weight: .semibold, design: .rounded))
            .monospacedDigit()
            .foregroundStyle(
                LinearGradient(
                    colors: [.primary, .primary.opacity(0.8)],
                    startPoint: .top,
                    endPoint: .bottom
                )
            )
            .contentTransition(.numericText())
            .animation(.spring(response: 0.3), value: time)
    }
}

#Preview {
    VStack(spacing: 20) {
        CircularProgressView(progress: 0.65, color: .red)
            .frame(width: 200, height: 200)
        
        AnimatedTimerText(time: "25:00", isRunning: true)
    }
    .padding()
}
