import SwiftUI
import Charts

struct ProductivityChartsView: View {
    let history: SessionHistory
    let dailyGoal: Int
    
    @State private var selectedTimeRange: TimeRange = .week
    
    enum TimeRange: String, CaseIterable {
        case week = "7 Days"
        case twoWeeks = "14 Days"
        case month = "30 Days"
        
        var days: Int {
            switch self {
            case .week: return 7
            case .twoWeeks: return 14
            case .month: return 30
            }
        }
    }
    
    var body: some View {
        VStack(spacing: 16) {
            // Time range picker
            HStack {
                Text("Time Range")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                
                Spacer()
                
                Picker("Time Range", selection: $selectedTimeRange) {
                    ForEach(TimeRange.allCases, id: \.self) { range in
                        Text(range.rawValue).tag(range)
                    }
                }
                .pickerStyle(.segmented)
                .labelsHidden()
                .fixedSize()
            }
            .padding(.horizontal)
            
            // Sessions chart
            SessionsBarChart(
                data: chartData,
                dailyGoal: dailyGoal
            )
            .frame(height: 180)
            .padding(.horizontal)
            
            // Work vs Break pie chart
            HStack(spacing: 16) {
                WorkBreakPieChart(history: history)
                    .frame(width: 120, height: 120)
                
                VStack(alignment: .leading, spacing: 8) {
                    ChartLegendItem(color: .red, label: "Work", value: formatMinutes(totalWorkMinutes))
                    ChartLegendItem(color: .green, label: "Break", value: formatMinutes(totalBreakMinutes))
                }
            }
            .padding()
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(Color(nsColor: .controlBackgroundColor))
            )
        }
    }
    
    private var chartData: [DailyChartData] {
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())
        
        return (0..<selectedTimeRange.days).map { dayOffset in
            let date = calendar.date(byAdding: .day, value: -dayOffset, to: today)!
            let stats = history.dailyStats.first { calendar.isDate($0.date, inSameDayAs: date) }
            
            return DailyChartData(
                date: date,
                sessions: stats?.workSessions ?? 0,
                workMinutes: stats?.workMinutes ?? 0,
                breakMinutes: stats?.breakMinutes ?? 0
            )
        }.reversed()
    }
    
    private var totalWorkMinutes: Int {
        chartData.reduce(0) { $0 + $1.workMinutes }
    }
    
    private var totalBreakMinutes: Int {
        chartData.reduce(0) { $0 + $1.breakMinutes }
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

struct DailyChartData: Identifiable {
    let id = UUID()
    let date: Date
    let sessions: Int
    let workMinutes: Int
    let breakMinutes: Int
    
    var dayLabel: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "E"
        return formatter.string(from: date)
    }
    
    var shortDate: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "M/d"
        return formatter.string(from: date)
    }
}

struct SessionsBarChart: View {
    let data: [DailyChartData]
    let dailyGoal: Int
    
    var body: some View {
        Chart {
            ForEach(data) { item in
                BarMark(
                    x: .value("Date", item.date, unit: .day),
                    y: .value("Sessions", item.sessions)
                )
                .foregroundStyle(
                    item.sessions >= dailyGoal
                        ? Color.green.gradient
                        : Color.red.gradient
                )
                .cornerRadius(4)
            }
            
            // Goal line
            RuleMark(y: .value("Goal", dailyGoal))
                .foregroundStyle(.orange)
                .lineStyle(StrokeStyle(lineWidth: 2, dash: [5, 5]))
                .annotation(position: .top, alignment: .trailing) {
                    Text("Goal: \(dailyGoal)")
                        .font(.caption2)
                        .foregroundColor(.orange)
                }
        }
        .chartXAxis {
            AxisMarks(values: .stride(by: .day)) { value in
                if let date = value.as(Date.self) {
                    AxisValueLabel {
                        Text(dayLabel(for: date))
                            .font(.caption2)
                    }
                }
            }
        }
        .chartYAxis {
            AxisMarks(position: .leading) { value in
                AxisGridLine()
                AxisValueLabel()
            }
        }
    }
    
    private func dayLabel(for date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "E"
        return String(formatter.string(from: date).prefix(1))
    }
}

struct WorkBreakPieChart: View {
    let history: SessionHistory
    
    var body: some View {
        let workMinutes = history.thisWeekStats.reduce(0) { $0 + $1.workMinutes }
        let breakMinutes = history.thisWeekStats.reduce(0) { $0 + $1.breakMinutes }
        let total = max(workMinutes + breakMinutes, 1)
        
        Chart {
            SectorMark(
                angle: .value("Work", workMinutes),
                innerRadius: .ratio(0.5),
                angularInset: 2
            )
            .foregroundStyle(.red.gradient)
            .cornerRadius(4)
            
            SectorMark(
                angle: .value("Break", breakMinutes),
                innerRadius: .ratio(0.5),
                angularInset: 2
            )
            .foregroundStyle(.green.gradient)
            .cornerRadius(4)
        }
        .chartBackground { _ in
            VStack(spacing: 2) {
                Text("\(workMinutes + breakMinutes)")
                    .font(.title3)
                    .fontWeight(.bold)
                Text("min")
                    .font(.caption2)
                    .foregroundColor(.secondary)
            }
        }
    }
}

struct ChartLegendItem: View {
    let color: Color
    let label: String
    let value: String
    
    var body: some View {
        HStack(spacing: 8) {
            Circle()
                .fill(color)
                .frame(width: 10, height: 10)
            
            Text(label)
                .font(.caption)
                .foregroundColor(.secondary)
            
            Spacer()
            
            Text(value)
                .font(.caption)
                .fontWeight(.medium)
        }
    }
}

struct SessionsTrendChart: View {
    let data: [DailyChartData]
    
    var body: some View {
        Chart {
            ForEach(data) { item in
                LineMark(
                    x: .value("Date", item.date, unit: .day),
                    y: .value("Minutes", item.workMinutes)
                )
                .foregroundStyle(.red)
                .interpolationMethod(.catmullRom)
                
                AreaMark(
                    x: .value("Date", item.date, unit: .day),
                    y: .value("Minutes", item.workMinutes)
                )
                .foregroundStyle(
                    LinearGradient(
                        colors: [.red.opacity(0.3), .red.opacity(0.05)],
                        startPoint: .top,
                        endPoint: .bottom
                    )
                )
                .interpolationMethod(.catmullRom)
            }
        }
        .chartXAxis {
            AxisMarks(values: .stride(by: .day)) { _ in
                AxisGridLine()
            }
        }
    }
}

struct RealtimeWeeklyHeatmap: View {
    let history: SessionHistory
    let dailyGoal: Int
    
    private let days = ["M", "T", "W", "T", "F", "S", "S"]
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("This Week")
                .font(.caption)
                .fontWeight(.medium)
                .foregroundColor(.secondary)
            
            HStack(spacing: 6) {
                ForEach(Array(weekData.enumerated()), id: \.offset) { index, data in
                    VStack(spacing: 4) {
                        RoundedRectangle(cornerRadius: 6)
                            .fill(colorForSessions(data.sessions))
                            .frame(width: 36, height: 36)
                            .overlay {
                                if data.sessions > 0 {
                                    Text("\(data.sessions)")
                                        .font(.caption2)
                                        .fontWeight(.bold)
                                        .foregroundColor(.white)
                                }
                            }
                        
                        Text(days[index])
                            .font(.caption2)
                            .foregroundColor(data.isToday ? .accentColor : .secondary)
                            .fontWeight(data.isToday ? .bold : .regular)
                    }
                }
            }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color(nsColor: .controlBackgroundColor))
        )
    }
    
    private var weekData: [(sessions: Int, isToday: Bool)] {
        let calendar = Calendar.current
        let today = Date()
        
        // Get start of this week (Monday)
        var components = calendar.dateComponents([.yearForWeekOfYear, .weekOfYear], from: today)
        components.weekday = 2 // Monday
        let startOfWeek = calendar.date(from: components) ?? today
        
        return (0..<7).map { dayOffset in
            let date = calendar.date(byAdding: .day, value: dayOffset, to: startOfWeek)!
            let isToday = calendar.isDateInToday(date)
            let stats = history.dailyStats.first { calendar.isDate($0.date, inSameDayAs: date) }
            return (sessions: stats?.workSessions ?? 0, isToday: isToday)
        }
    }
    
    private func colorForSessions(_ sessions: Int) -> Color {
        if sessions == 0 {
            return Color.secondary.opacity(0.2)
        }
        let ratio = min(Double(sessions) / Double(dailyGoal), 1.5)
        if ratio >= 1.0 {
            return .green
        } else if ratio >= 0.5 {
            return .orange
        } else {
            return .red.opacity(0.7)
        }
    }
}

struct StreakIndicator: View {
    let currentStreak: Int
    let longestStreak: Int
    
    var body: some View {
        HStack(spacing: 16) {
            VStack(spacing: 4) {
                HStack(spacing: 4) {
                    Image(systemName: "flame.fill")
                        .foregroundColor(.orange)
                    Text("\(currentStreak)")
                        .font(.title2)
                        .fontWeight(.bold)
                }
                Text("Current")
                    .font(.caption2)
                    .foregroundColor(.secondary)
            }
            
            Divider()
                .frame(height: 40)
            
            VStack(spacing: 4) {
                HStack(spacing: 4) {
                    Image(systemName: "trophy.fill")
                        .foregroundColor(.yellow)
                    Text("\(longestStreak)")
                        .font(.title2)
                        .fontWeight(.bold)
                }
                Text("Best")
                    .font(.caption2)
                    .foregroundColor(.secondary)
            }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color(nsColor: .controlBackgroundColor))
        )
    }
}

#Preview {
    ProductivityChartsView(
        history: .empty,
        dailyGoal: 8
    )
    .frame(width: 400)
    .padding()
}
