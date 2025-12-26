import SwiftUI

struct ProductivityInsightsCard: View {
    let statistics: SessionStatistics
    let dailyGoal: Int
    
    @State private var selectedTimeframe: Timeframe = .today
    
    enum Timeframe: String, CaseIterable {
        case today = "Today"
        case week = "This Week"
        case month = "This Month"
    }
    
    var body: some View {
        VStack(spacing: 16) {
            // Header with timeframe selector
            HStack {
                Text("Insights")
                    .font(.headline)
                
                Spacer()
                
                Picker("", selection: $selectedTimeframe) {
                    ForEach(Timeframe.allCases, id: \.self) { timeframe in
                        Text(timeframe.rawValue).tag(timeframe)
                    }
                }
                .pickerStyle(.segmented)
                .frame(width: 180)
            }
            
            // Insight cards
            LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 12) {
                InsightCard(
                    icon: "brain.head.profile",
                    title: "Focus Time",
                    value: formatMinutes(statistics.totalWorkMinutes),
                    trend: .up,
                    color: .red
                )
                
                InsightCard(
                    icon: "target",
                    title: "Goal Progress",
                    value: "\(Int(goalProgress * 100))%",
                    trend: goalProgress >= 1 ? .achieved : .neutral,
                    color: .green
                )
                
                InsightCard(
                    icon: "flame.fill",
                    title: "Current Streak",
                    value: "\(statistics.currentStreak) days",
                    trend: statistics.currentStreak > 0 ? .up : .neutral,
                    color: .orange
                )
                
                InsightCard(
                    icon: "chart.line.uptrend.xyaxis",
                    title: "Productivity",
                    value: productivityScore,
                    trend: .up,
                    color: .blue
                )
            }
            
            // Daily summary message
            DailySummaryMessage(
                completedSessions: statistics.totalWorkSessions,
                goalSessions: dailyGoal,
                streak: statistics.currentStreak
            )
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color(nsColor: .controlBackgroundColor))
        )
    }
    
    private var goalProgress: Double {
        guard dailyGoal > 0 else { return 0 }
        return Double(statistics.totalWorkSessions) / Double(dailyGoal)
    }
    
    private var productivityScore: String {
        let score = min(100, (statistics.totalWorkSessions * 12) + (statistics.currentStreak * 5))
        return "\(score)"
    }
    
    private func formatMinutes(_ minutes: Int) -> String {
        if minutes < 60 {
            return "\(minutes)m"
        }
        let hours = minutes / 60
        let mins = minutes % 60
        return mins > 0 ? "\(hours)h \(mins)m" : "\(hours)h"
    }
}

struct InsightCard: View {
    let icon: String
    let title: String
    let value: String
    let trend: Trend
    let color: Color
    
    enum Trend {
        case up, down, neutral, achieved
        
        var icon: String {
            switch self {
            case .up: return "arrow.up.right"
            case .down: return "arrow.down.right"
            case .neutral: return "minus"
            case .achieved: return "checkmark.circle.fill"
            }
        }
        
        var color: Color {
            switch self {
            case .up, .achieved: return .green
            case .down: return .red
            case .neutral: return .secondary
            }
        }
    }
    
    @State private var isHovering = false
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Image(systemName: icon)
                    .font(.caption)
                    .foregroundColor(color)
                
                Spacer()
                
                Image(systemName: trend.icon)
                    .font(.caption2)
                    .foregroundColor(trend.color)
            }
            
            Text(value)
                .font(.title2)
                .fontWeight(.bold)
                .monospacedDigit()
            
            Text(title)
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .padding(12)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(color.opacity(isHovering ? 0.15 : 0.08))
        )
        .scaleEffect(isHovering ? 1.02 : 1.0)
        .animation(.spring(response: 0.3), value: isHovering)
        .onHover { hovering in
            isHovering = hovering
        }
    }
}

struct DailySummaryMessage: View {
    let completedSessions: Int
    let goalSessions: Int
    let streak: Int
    
    private var message: (String, String, Color) {
        let progress = Double(completedSessions) / Double(max(goalSessions, 1))
        
        if progress >= 1.0 {
            return ("🎉 Amazing work!", "You've crushed your daily goal!", .green)
        } else if progress >= 0.75 {
            return ("💪 Almost there!", "Just \(goalSessions - completedSessions) more to hit your goal!", .blue)
        } else if progress >= 0.5 {
            return ("👍 Good progress!", "Keep the momentum going!", .orange)
        } else if progress > 0 {
            return ("🚀 Great start!", "\(goalSessions - completedSessions) sessions left for your goal.", .purple)
        } else {
            return ("☀️ Ready to start?", "Your first pomodoro awaits!", .yellow)
        }
    }
    
    var body: some View {
        HStack(spacing: 12) {
            Text(message.0)
                .font(.subheadline)
                .fontWeight(.medium)
            
            Text(message.1)
                .font(.caption)
                .foregroundColor(.secondary)
            
            Spacer()
        }
        .padding(12)
        .background(
            RoundedRectangle(cornerRadius: 10)
                .fill(message.2.opacity(0.1))
        )
    }
}

struct WeeklyHeatmap: View {
    let dailyData: [DayData]
    
    struct DayData: Identifiable {
        let id = UUID()
        let day: String
        let sessions: Int
        let goal: Int
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("This Week")
                .font(.subheadline)
                .fontWeight(.medium)
            
            HStack(spacing: 4) {
                ForEach(dailyData) { day in
                    VStack(spacing: 6) {
                        RoundedRectangle(cornerRadius: 4)
                            .fill(colorForProgress(day.sessions, goal: day.goal))
                            .frame(height: 40)
                        
                        Text(day.day)
                            .font(.caption2)
                            .foregroundColor(.secondary)
                    }
                }
            }
            
            // Legend
            HStack(spacing: 8) {
                Text("Less")
                    .font(.caption2)
                    .foregroundColor(.secondary)
                
                ForEach(0..<5) { level in
                    RoundedRectangle(cornerRadius: 2)
                        .fill(Color.green.opacity(Double(level) * 0.25))
                        .frame(width: 12, height: 12)
                }
                
                Text("More")
                    .font(.caption2)
                    .foregroundColor(.secondary)
            }
        }
    }
    
    private func colorForProgress(_ sessions: Int, goal: Int) -> Color {
        guard goal > 0 else { return Color.green.opacity(0.1) }
        let progress = Double(sessions) / Double(goal)
        
        if progress >= 1.0 {
            return .green
        } else if progress >= 0.75 {
            return .green.opacity(0.75)
        } else if progress >= 0.5 {
            return .green.opacity(0.5)
        } else if progress >= 0.25 {
            return .green.opacity(0.25)
        } else {
            return .green.opacity(0.1)
        }
    }
}

#Preview {
    VStack(spacing: 20) {
        ProductivityInsightsCard(
            statistics: SessionStatistics(
                totalWorkSessions: 5,
                totalWorkMinutes: 125,
                totalBreakMinutes: 25,
                currentStreak: 3,
                longestStreak: 7,
                lastSessionDate: Date()
            ),
            dailyGoal: 8
        )
        
        WeeklyHeatmap(dailyData: [
            .init(day: "M", sessions: 6, goal: 8),
            .init(day: "T", sessions: 8, goal: 8),
            .init(day: "W", sessions: 4, goal: 8),
            .init(day: "T", sessions: 7, goal: 8),
            .init(day: "F", sessions: 3, goal: 8),
            .init(day: "S", sessions: 0, goal: 8),
            .init(day: "S", sessions: 2, goal: 8)
        ])
        .padding()
    }
    .frame(width: 340)
    .padding()
}
