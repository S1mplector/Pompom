import SwiftUI

struct SmartBreakSuggestion: View {
    let consecutiveSessions: Int
    let totalWorkMinutes: Int
    let onTakeBreak: () -> Void
    let onDismiss: () -> Void
    
    @State private var isExpanded = true
    
    private var suggestion: BreakSuggestion {
        BreakSuggestion.suggest(
            consecutiveSessions: consecutiveSessions,
            totalWorkMinutes: totalWorkMinutes
        )
    }
    
    var body: some View {
        if isExpanded && suggestion.shouldShow {
            VStack(spacing: 12) {
                HStack(alignment: .top) {
                    Image(systemName: suggestion.icon)
                        .font(.title2)
                        .foregroundColor(suggestion.color)
                        .symbolEffect(.pulse, options: .repeating)
                    
                    VStack(alignment: .leading, spacing: 4) {
                        Text(suggestion.title)
                            .font(.subheadline)
                            .fontWeight(.semibold)
                        
                        Text(suggestion.message)
                            .font(.caption)
                            .foregroundColor(.secondary)
                            .fixedSize(horizontal: false, vertical: true)
                    }
                    
                    Spacer()
                    
                    Button {
                        withAnimation(.spring()) {
                            isExpanded = false
                        }
                        onDismiss()
                    } label: {
                        Image(systemName: "xmark.circle.fill")
                            .foregroundColor(.secondary.opacity(0.5))
                    }
                    .buttonStyle(.plain)
                }
                
                if suggestion.showActions {
                    HStack(spacing: 12) {
                        Button("Maybe Later") {
                            withAnimation(.spring()) {
                                isExpanded = false
                            }
                            onDismiss()
                        }
                        .buttonStyle(.plain)
                        .font(.caption)
                        .foregroundColor(.secondary)
                        
                        Button(suggestion.actionTitle) {
                            onTakeBreak()
                        }
                        .buttonStyle(.borderedProminent)
                        .controlSize(.small)
                    }
                }
            }
            .padding()
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(suggestion.color.opacity(0.1))
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(suggestion.color.opacity(0.3), lineWidth: 1)
                    )
            )
            .transition(.asymmetric(
                insertion: .move(edge: .top).combined(with: .opacity),
                removal: .scale.combined(with: .opacity)
            ))
        }
    }
}

struct BreakSuggestion {
    let shouldShow: Bool
    let title: String
    let message: String
    let icon: String
    let color: Color
    let actionTitle: String
    let showActions: Bool
    
    static func suggest(consecutiveSessions: Int, totalWorkMinutes: Int) -> BreakSuggestion {
        // Suggest long break after 4+ sessions
        if consecutiveSessions >= 4 {
            return BreakSuggestion(
                shouldShow: true,
                title: "Time for a longer break",
                message: "You've completed \(consecutiveSessions) sessions in a row. A 15-20 minute break will help you stay focused.",
                icon: "cup.and.saucer.fill",
                color: .blue,
                actionTitle: "Take Long Break",
                showActions: true
            )
        }
        
        // Suggest stretch after 2 hours
        if totalWorkMinutes >= 120 {
            return BreakSuggestion(
                shouldShow: true,
                title: "Quick stretch?",
                message: "You've been working for \(totalWorkMinutes / 60) hours. A quick stretch can boost your energy!",
                icon: "figure.walk",
                color: .green,
                actionTitle: "Take a Break",
                showActions: true
            )
        }
        
        // Suggest eye rest after 60 minutes
        if totalWorkMinutes >= 60 && totalWorkMinutes < 120 {
            return BreakSuggestion(
                shouldShow: true,
                title: "Rest your eyes",
                message: "Try the 20-20-20 rule: Look at something 20 feet away for 20 seconds.",
                icon: "eye",
                color: .purple,
                actionTitle: "Got it!",
                showActions: false
            )
        }
        
        return BreakSuggestion(
            shouldShow: false,
            title: "",
            message: "",
            icon: "",
            color: .clear,
            actionTitle: "",
            showActions: false
        )
    }
}

struct ProductivityTip: View {
    @State private var currentTip: Tip = Tip.random()
    @State private var isVisible = true
    
    var body: some View {
        if isVisible {
            HStack(spacing: 10) {
                Image(systemName: "lightbulb.fill")
                    .foregroundColor(.yellow)
                    .font(.caption)
                
                Text(currentTip.text)
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .lineLimit(2)
                
                Spacer()
                
                Button {
                    withAnimation(.spring()) {
                        currentTip = Tip.random()
                    }
                } label: {
                    Image(systemName: "arrow.clockwise")
                        .font(.caption2)
                        .foregroundColor(.secondary)
                }
                .buttonStyle(.plain)
            }
            .padding(10)
            .background(
                RoundedRectangle(cornerRadius: 8)
                    .fill(Color.yellow.opacity(0.1))
            )
        }
    }
}

struct Tip: Identifiable {
    let id = UUID()
    let text: String
    
    static let tips = [
        Tip(text: "💡 The Pomodoro Technique was invented by Francesco Cirillo in the late 1980s."),
        Tip(text: "🎯 Focus on one task at a time for better results."),
        Tip(text: "💧 Stay hydrated! Drink water during your breaks."),
        Tip(text: "🧘 Use breaks for quick stretches or meditation."),
        Tip(text: "📱 Put your phone in another room to minimize distractions."),
        Tip(text: "🎵 Try lo-fi music or white noise for better focus."),
        Tip(text: "📝 Write down distracting thoughts to address later."),
        Tip(text: "🌿 A tidy workspace can help improve concentration."),
        Tip(text: "⏰ After 4 pomodoros, take a longer 15-30 minute break."),
        Tip(text: "🏆 Celebrate small wins to maintain motivation!"),
        Tip(text: "🌙 Your brain consolidates learning during rest periods."),
        Tip(text: "👀 Follow the 20-20-20 rule: Every 20 min, look 20 ft away for 20 sec.")
    ]
    
    static func random() -> Tip {
        tips.randomElement() ?? tips[0]
    }
}

#Preview {
    VStack(spacing: 20) {
        SmartBreakSuggestion(
            consecutiveSessions: 4,
            totalWorkMinutes: 100,
            onTakeBreak: {},
            onDismiss: {}
        )
        
        ProductivityTip()
    }
    .padding()
    .frame(width: 320)
}
