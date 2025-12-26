import SwiftUI

struct PrimaryControlButton: View {
    let icon: String
    let color: Color
    let size: CGFloat
    let action: () -> Void
    
    @State private var isPressed = false
    
    init(icon: String, color: Color, size: CGFloat = 60, action: @escaping () -> Void) {
        self.icon = icon
        self.color = color
        self.size = size
        self.action = action
    }
    
    var body: some View {
        Button(action: {
            withAnimation(.spring(response: 0.2)) {
                action()
            }
        }) {
            ZStack {
                Circle()
                    .fill(
                        LinearGradient(
                            colors: [color, color.opacity(0.8)],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .shadow(color: color.opacity(0.4), radius: isPressed ? 4 : 8, y: isPressed ? 2 : 4)
                
                Image(systemName: icon)
                    .font(.system(size: size * 0.35, weight: .semibold))
                    .foregroundColor(.white)
            }
            .frame(width: size, height: size)
            .scaleEffect(isPressed ? 0.95 : 1.0)
        }
        .buttonStyle(.plain)
        .onHover { hovering in
            withAnimation(.spring(response: 0.2)) {
                isPressed = hovering
            }
        }
    }
}

struct SecondaryControlButton: View {
    let icon: String
    let isEnabled: Bool
    let action: () -> Void
    
    @State private var isHovered = false
    
    var body: some View {
        Button(action: action) {
            Image(systemName: icon)
                .font(.title2)
                .foregroundColor(isEnabled ? .primary : .secondary)
                .opacity(isEnabled ? 1 : 0.5)
                .scaleEffect(isHovered ? 1.1 : 1.0)
        }
        .buttonStyle(.plain)
        .disabled(!isEnabled)
        .onHover { hovering in
            withAnimation(.spring(response: 0.2)) {
                isHovered = hovering && isEnabled
            }
        }
    }
}

struct IconButton: View {
    let icon: String
    let color: Color
    let action: () -> Void
    
    @State private var isHovered = false
    
    var body: some View {
        Button(action: action) {
            Image(systemName: icon)
                .font(.body)
                .foregroundColor(isHovered ? color : .secondary)
                .padding(8)
                .background(
                    Circle()
                        .fill(isHovered ? color.opacity(0.15) : Color.clear)
                )
        }
        .buttonStyle(.plain)
        .onHover { hovering in
            withAnimation(.easeInOut(duration: 0.15)) {
                isHovered = hovering
            }
        }
    }
}

#Preview {
    HStack(spacing: 20) {
        SecondaryControlButton(icon: "arrow.counterclockwise", isEnabled: true) {}
        PrimaryControlButton(icon: "play.fill", color: .red) {}
        SecondaryControlButton(icon: "forward.fill", isEnabled: true) {}
    }
    .padding()
}
