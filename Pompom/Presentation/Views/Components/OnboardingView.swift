import SwiftUI

struct OnboardingView: View {
    @Binding var isPresented: Bool
    @State private var currentPage = 0
    
    private let pages: [OnboardingPage] = [
        OnboardingPage(
            icon: "timer",
            iconColor: .red,
            title: "Welcome to Pompom",
            description: "A beautiful Pomodoro timer to help you stay focused and productive.",
            features: []
        ),
        OnboardingPage(
            icon: "brain.head.profile",
            iconColor: .purple,
            title: "Stay Focused",
            description: "Use the Pomodoro Technique to work in focused intervals.",
            features: [
                "25-minute work sessions",
                "5-minute short breaks",
                "15-minute long breaks after 4 sessions"
            ]
        ),
        OnboardingPage(
            icon: "checklist",
            iconColor: .blue,
            title: "Track Your Tasks",
            description: "Create tasks and track your progress throughout the day.",
            features: [
                "Add tasks with estimated pomodoros",
                "Set priorities and add notes",
                "Quick add with natural language"
            ]
        ),
        OnboardingPage(
            icon: "chart.bar.fill",
            iconColor: .green,
            title: "Monitor Progress",
            description: "Track your productivity with detailed statistics.",
            features: [
                "Daily and weekly stats",
                "Streak tracking",
                "Export your data anytime"
            ]
        ),
        OnboardingPage(
            icon: "keyboard",
            iconColor: .orange,
            title: "Keyboard Shortcuts",
            description: "Control Pompom from anywhere with global shortcuts.",
            features: [
                "⌃⌘Space - Start/Pause",
                "⌃⌘→ - Skip session",
                "⌃⌘R - Reset session"
            ]
        )
    ]
    
    var body: some View {
        VStack(spacing: 0) {
            // Page content
            TabView(selection: $currentPage) {
                ForEach(0..<pages.count, id: \.self) { index in
                    OnboardingPageView(page: pages[index])
                        .tag(index)
                }
            }
            .tabViewStyle(.automatic)
            .frame(height: 320)
            
            // Page indicators
            HStack(spacing: 8) {
                ForEach(0..<pages.count, id: \.self) { index in
                    Circle()
                        .fill(index == currentPage ? Color.accentColor : Color.secondary.opacity(0.3))
                        .frame(width: 8, height: 8)
                        .animation(.spring(response: 0.3), value: currentPage)
                }
            }
            .padding(.vertical, 16)
            
            // Navigation buttons
            HStack {
                if currentPage > 0 {
                    Button("Back") {
                        withAnimation {
                            currentPage -= 1
                        }
                    }
                    .buttonStyle(.plain)
                    .foregroundColor(.secondary)
                }
                
                Spacer()
                
                if currentPage < pages.count - 1 {
                    Button("Next") {
                        withAnimation {
                            currentPage += 1
                        }
                    }
                    .buttonStyle(.borderedProminent)
                } else {
                    Button("Get Started") {
                        UserDefaults.standard.set(true, forKey: "hasCompletedOnboarding")
                        withAnimation {
                            isPresented = false
                        }
                    }
                    .buttonStyle(.borderedProminent)
                }
            }
            .padding()
        }
        .frame(width: 400, height: 450)
        .background(Color(nsColor: .windowBackgroundColor))
    }
}

struct OnboardingPage {
    let icon: String
    let iconColor: Color
    let title: String
    let description: String
    let features: [String]
}

struct OnboardingPageView: View {
    let page: OnboardingPage
    
    var body: some View {
        VStack(spacing: 20) {
            ZStack {
                Circle()
                    .fill(page.iconColor.opacity(0.15))
                    .frame(width: 100, height: 100)
                
                Image(systemName: page.icon)
                    .font(.system(size: 44))
                    .foregroundColor(page.iconColor)
            }
            
            VStack(spacing: 8) {
                Text(page.title)
                    .font(.title2)
                    .fontWeight(.bold)
                
                Text(page.description)
                    .font(.body)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal)
            }
            
            if !page.features.isEmpty {
                VStack(alignment: .leading, spacing: 8) {
                    ForEach(page.features, id: \.self) { feature in
                        HStack(spacing: 8) {
                            Image(systemName: "checkmark.circle.fill")
                                .foregroundColor(.green)
                                .font(.caption)
                            
                            Text(feature)
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                    }
                }
                .padding()
                .background(
                    RoundedRectangle(cornerRadius: 10)
                        .fill(Color(nsColor: .controlBackgroundColor))
                )
            }
        }
        .padding()
    }
}

struct OnboardingManager {
    static var shouldShowOnboarding: Bool {
        !UserDefaults.standard.bool(forKey: "hasCompletedOnboarding")
    }
    
    static func resetOnboarding() {
        UserDefaults.standard.set(false, forKey: "hasCompletedOnboarding")
    }
}

#Preview {
    OnboardingView(isPresented: .constant(true))
}
