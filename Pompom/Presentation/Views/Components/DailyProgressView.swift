import SwiftUI

struct DailyProgressView: View {
    let completed: Int
    let goal: Int
    let color: Color
    
    private var progress: Double {
        guard goal > 0 else { return 0 }
        return min(Double(completed) / Double(goal), 1.0)
    }
    
    var body: some View {
        VStack(spacing: 8) {
            HStack(spacing: 4) {
                ForEach(0..<goal, id: \.self) { index in
                    TomatoIcon(isFilled: index < completed)
                }
            }
            
            Text("\(completed)/\(goal) pomodoros today")
                .font(.caption)
                .foregroundColor(.secondary)
        }
    }
}

struct TomatoIcon: View {
    let isFilled: Bool
    
    var body: some View {
        Image(systemName: isFilled ? "circle.fill" : "circle")
            .font(.system(size: 8))
            .foregroundColor(isFilled ? .red : .secondary.opacity(0.3))
            .animation(.spring(response: 0.3), value: isFilled)
    }
}

struct WeeklyChartView: View {
    let dailyStats: [DailyStatistics]
    
    private var maxSessions: Int {
        max(dailyStats.map { $0.workSessions }.max() ?? 1, 1)
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("This Week")
                .font(.headline)
            
            HStack(alignment: .bottom, spacing: 8) {
                ForEach(Array(dailyStats.enumerated()), id: \.offset) { index, stat in
                    VStack(spacing: 4) {
                        ChartBar(
                            value: stat.workSessions,
                            maxValue: maxSessions,
                            color: .red
                        )
                        
                        Text(dayLabel(for: stat.date))
                            .font(.system(size: 10))
                            .foregroundColor(.secondary)
                    }
                }
            }
            .frame(height: 100)
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color(nsColor: .controlBackgroundColor))
        )
    }
    
    private func dayLabel(for date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "E"
        return String(formatter.string(from: date).prefix(1))
    }
}

struct ChartBar: View {
    let value: Int
    let maxValue: Int
    let color: Color
    
    private var height: CGFloat {
        guard maxValue > 0 else { return 0 }
        return CGFloat(value) / CGFloat(maxValue) * 60
    }
    
    var body: some View {
        VStack {
            Spacer()
            
            RoundedRectangle(cornerRadius: 4)
                .fill(
                    LinearGradient(
                        colors: [color.opacity(0.8), color],
                        startPoint: .bottom,
                        endPoint: .top
                    )
                )
                .frame(width: 24, height: max(height, 4))
            
            if value > 0 {
                Text("\(value)")
                    .font(.system(size: 9, weight: .medium))
                    .foregroundColor(.secondary)
            }
        }
    }
}

#Preview {
    VStack(spacing: 20) {
        DailyProgressView(completed: 5, goal: 8, color: .red)
        
        WeeklyChartView(dailyStats: [
            DailyStatistics(date: Date(), workSessions: 4, workMinutes: 100, breakMinutes: 20),
            DailyStatistics(date: Date().addingTimeInterval(-86400), workSessions: 6, workMinutes: 150, breakMinutes: 30),
            DailyStatistics(date: Date().addingTimeInterval(-172800), workSessions: 3, workMinutes: 75, breakMinutes: 15),
        ])
    }
    .padding()
}
