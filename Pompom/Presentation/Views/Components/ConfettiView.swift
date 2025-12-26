import SwiftUI

struct ConfettiView: View {
    @State private var particles: [ConfettiParticle] = []
    @State private var isAnimating = false
    
    let colors: [Color] = [.red, .orange, .yellow, .green, .blue, .purple, .pink]
    
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                ForEach(particles) { particle in
                    ConfettiPiece(particle: particle)
                }
            }
            .onAppear {
                createParticles(in: geometry.size)
            }
        }
        .allowsHitTesting(false)
    }
    
    private func createParticles(in size: CGSize) {
        for _ in 0..<50 {
            let particle = ConfettiParticle(
                x: CGFloat.random(in: 0...size.width),
                y: -20,
                color: colors.randomElement() ?? .red,
                rotation: Double.random(in: 0...360),
                scale: CGFloat.random(in: 0.5...1.2)
            )
            particles.append(particle)
        }
    }
}

struct ConfettiParticle: Identifiable {
    let id = UUID()
    var x: CGFloat
    var y: CGFloat
    let color: Color
    var rotation: Double
    let scale: CGFloat
}

struct ConfettiPiece: View {
    let particle: ConfettiParticle
    @State private var offsetY: CGFloat = 0
    @State private var rotation: Double = 0
    @State private var opacity: Double = 1
    
    var body: some View {
        Rectangle()
            .fill(particle.color)
            .frame(width: 8 * particle.scale, height: 12 * particle.scale)
            .rotationEffect(.degrees(rotation))
            .offset(x: particle.x, y: offsetY)
            .opacity(opacity)
            .onAppear {
                withAnimation(.easeOut(duration: Double.random(in: 2...4))) {
                    offsetY = 400 + CGFloat.random(in: 0...200)
                    rotation = particle.rotation + Double.random(in: 180...720)
                }
                withAnimation(.easeIn(duration: 3).delay(1)) {
                    opacity = 0
                }
            }
    }
}

struct CelebrationOverlay: View {
    @Binding var isShowing: Bool
    let message: String
    let subtitle: String
    
    @State private var scale: CGFloat = 0.5
    @State private var opacity: Double = 0
    
    var body: some View {
        ZStack {
            if isShowing {
                Color.black.opacity(0.3)
                    .ignoresSafeArea()
                    .transition(.opacity)
                
                VStack(spacing: 16) {
                    Image(systemName: "star.circle.fill")
                        .font(.system(size: 60))
                        .foregroundStyle(
                            LinearGradient(
                                colors: [.yellow, .orange],
                                startPoint: .top,
                                endPoint: .bottom
                            )
                        )
                        .symbolEffect(.bounce, value: isShowing)
                    
                    Text(message)
                        .font(.title2)
                        .fontWeight(.bold)
                    
                    Text(subtitle)
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                    
                    Button("Awesome!") {
                        withAnimation(.spring()) {
                            isShowing = false
                        }
                    }
                    .buttonStyle(.borderedProminent)
                    .padding(.top, 8)
                }
                .padding(32)
                .background(
                    RoundedRectangle(cornerRadius: 20)
                        .fill(.ultraThinMaterial)
                        .shadow(radius: 20)
                )
                .scaleEffect(scale)
                .opacity(opacity)
                .onAppear {
                    withAnimation(.spring(response: 0.5, dampingFraction: 0.7)) {
                        scale = 1
                        opacity = 1
                    }
                }
                .transition(.scale.combined(with: .opacity))
                
                ConfettiView()
            }
        }
        .animation(.spring(), value: isShowing)
    }
}

struct GoalCompletedView: View {
    @Binding var isShowing: Bool
    let completedCount: Int
    let goalCount: Int
    
    var body: some View {
        CelebrationOverlay(
            isShowing: $isShowing,
            message: "🎉 Daily Goal Complete!",
            subtitle: "You finished \(completedCount) pomodoros today"
        )
    }
}

struct SessionCompletedView: View {
    @Binding var isShowing: Bool
    let sessionType: SessionType
    
    var message: String {
        switch sessionType {
        case .work:
            return "Great work! 💪"
        case .shortBreak:
            return "Break's over!"
        case .longBreak:
            return "Feeling refreshed?"
        }
    }
    
    var subtitle: String {
        switch sessionType {
        case .work:
            return "Time for a well-deserved break"
        case .shortBreak, .longBreak:
            return "Ready to get back to work?"
        }
    }
    
    var body: some View {
        CelebrationOverlay(
            isShowing: $isShowing,
            message: message,
            subtitle: subtitle
        )
    }
}

#Preview {
    ZStack {
        Color.gray.opacity(0.2)
        
        CelebrationOverlay(
            isShowing: .constant(true),
            message: "🎉 Goal Complete!",
            subtitle: "You've completed 8 pomodoros today"
        )
    }
    .frame(width: 400, height: 500)
}
