import SwiftUI

struct ShakeEffect: GeometryEffect {
    var amount: CGFloat = 5
    var shakesPerUnit = 3
    var animatableData: CGFloat
    
    func effectValue(size: CGSize) -> ProjectionTransform {
        ProjectionTransform(CGAffineTransform(translationX:
            amount * sin(animatableData * .pi * CGFloat(shakesPerUnit)),
            y: 0))
    }
}

struct BounceEffect: ViewModifier {
    @State private var isAnimating = false
    let trigger: Bool
    
    func body(content: Content) -> some View {
        content
            .scaleEffect(isAnimating ? 1.1 : 1.0)
            .animation(.spring(response: 0.3, dampingFraction: 0.5), value: isAnimating)
            .onChange(of: trigger) { _, newValue in
                if newValue {
                    isAnimating = true
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.15) {
                        isAnimating = false
                    }
                }
            }
    }
}

struct PressEffect: ViewModifier {
    @State private var isPressed = false
    
    func body(content: Content) -> some View {
        content
            .scaleEffect(isPressed ? 0.95 : 1.0)
            .animation(.spring(response: 0.2, dampingFraction: 0.7), value: isPressed)
            .simultaneousGesture(
                DragGesture(minimumDistance: 0)
                    .onChanged { _ in isPressed = true }
                    .onEnded { _ in isPressed = false }
            )
    }
}

struct GlowEffect: ViewModifier {
    let color: Color
    let radius: CGFloat
    let isActive: Bool
    
    func body(content: Content) -> some View {
        content
            .shadow(color: isActive ? color.opacity(0.5) : .clear, radius: radius)
            .animation(.easeInOut(duration: 0.3), value: isActive)
    }
}

struct CardStyle: ViewModifier {
    let isHovering: Bool
    
    func body(content: Content) -> some View {
        content
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(Color(nsColor: .controlBackgroundColor))
                    .shadow(
                        color: .black.opacity(isHovering ? 0.15 : 0.08),
                        radius: isHovering ? 8 : 4,
                        y: isHovering ? 4 : 2
                    )
            )
            .scaleEffect(isHovering ? 1.02 : 1.0)
            .animation(.spring(response: 0.3), value: isHovering)
    }
}

struct SlideTransition: ViewModifier {
    let isVisible: Bool
    let edge: Edge
    
    func body(content: Content) -> some View {
        content
            .opacity(isVisible ? 1 : 0)
            .offset(x: offsetX, y: offsetY)
            .animation(.spring(response: 0.4, dampingFraction: 0.8), value: isVisible)
    }
    
    private var offsetX: CGFloat {
        guard !isVisible else { return 0 }
        switch edge {
        case .leading: return -20
        case .trailing: return 20
        default: return 0
        }
    }
    
    private var offsetY: CGFloat {
        guard !isVisible else { return 0 }
        switch edge {
        case .top: return -20
        case .bottom: return 20
        default: return 0
        }
    }
}

extension View {
    func shake(trigger: Int) -> some View {
        modifier(ShakeEffect(animatableData: CGFloat(trigger)))
    }
    
    func bounce(trigger: Bool) -> some View {
        modifier(BounceEffect(trigger: trigger))
    }
    
    func pressEffect() -> some View {
        modifier(PressEffect())
    }
    
    func glow(color: Color, radius: CGFloat = 10, isActive: Bool = true) -> some View {
        modifier(GlowEffect(color: color, radius: radius, isActive: isActive))
    }
    
    func cardStyle(isHovering: Bool = false) -> some View {
        modifier(CardStyle(isHovering: isHovering))
    }
    
    func slideIn(isVisible: Bool, from edge: Edge = .bottom) -> some View {
        modifier(SlideTransition(isVisible: isVisible, edge: edge))
    }
    
    @ViewBuilder
    func `if`<Content: View>(_ condition: Bool, transform: (Self) -> Content) -> some View {
        if condition {
            transform(self)
        } else {
            self
        }
    }
    
    func onFirstAppear(perform action: @escaping () -> Void) -> some View {
        modifier(OnFirstAppearModifier(action: action))
    }
}

struct OnFirstAppearModifier: ViewModifier {
    let action: () -> Void
    @State private var hasAppeared = false
    
    func body(content: Content) -> some View {
        content
            .onAppear {
                guard !hasAppeared else { return }
                hasAppeared = true
                action()
            }
    }
}

struct LoadingOverlay: ViewModifier {
    let isLoading: Bool
    let message: String
    
    func body(content: Content) -> some View {
        ZStack {
            content
                .disabled(isLoading)
                .blur(radius: isLoading ? 2 : 0)
            
            if isLoading {
                VStack(spacing: 12) {
                    ProgressView()
                        .scaleEffect(1.2)
                    
                    Text(message)
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                .padding(24)
                .background(
                    RoundedRectangle(cornerRadius: 12)
                        .fill(.ultraThinMaterial)
                )
                .transition(.scale.combined(with: .opacity))
            }
        }
        .animation(.easeInOut(duration: 0.2), value: isLoading)
    }
}

extension View {
    func loading(isLoading: Bool, message: String = "Loading...") -> some View {
        modifier(LoadingOverlay(isLoading: isLoading, message: message))
    }
}
