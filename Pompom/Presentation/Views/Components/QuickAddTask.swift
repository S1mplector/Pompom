import SwiftUI

struct QuickAddTaskView: View {
    @EnvironmentObject var taskViewModel: TaskViewModel
    @Binding var isPresented: Bool
    
    @State private var input: String = ""
    @State private var parsedTask: ParsedTaskInput?
    @FocusState private var isFocused: Bool
    
    var body: some View {
        VStack(spacing: 16) {
            // Header
            HStack {
                Image(systemName: "sparkles")
                    .foregroundColor(.purple)
                
                Text("Quick Add")
                    .font(.headline)
                
                Spacer()
                
                Button {
                    isPresented = false
                } label: {
                    Image(systemName: "xmark.circle.fill")
                        .foregroundColor(.secondary)
                }
                .buttonStyle(.plain)
            }
            
            // Input field
            HStack(spacing: 8) {
                Image(systemName: "text.cursor")
                    .foregroundColor(.secondary)
                
                TextField("e.g., 'Write report 3 pomodoros high priority'", text: $input)
                    .textFieldStyle(.plain)
                    .focused($isFocused)
                    .onSubmit {
                        addTask()
                    }
                    .onChange(of: input) { _, newValue in
                        parsedTask = TaskInputParser.parse(newValue)
                    }
            }
            .padding(12)
            .background(
                RoundedRectangle(cornerRadius: 10)
                    .fill(Color(nsColor: .textBackgroundColor))
            )
            
            // Preview
            if let parsed = parsedTask, !parsed.title.isEmpty {
                TaskPreviewCard(parsed: parsed)
                    .transition(.asymmetric(
                        insertion: .move(edge: .top).combined(with: .opacity),
                        removal: .opacity
                    ))
            }
            
            // Hints
            VStack(alignment: .leading, spacing: 8) {
                Text("Tips:")
                    .font(.caption)
                    .fontWeight(.medium)
                    .foregroundColor(.secondary)
                
                HintRow(icon: "number", text: "Add a number for pomodoros: \"3 pomodoros\"")
                HintRow(icon: "exclamationmark.triangle", text: "Set priority: \"high\", \"medium\", or \"low\"")
                HintRow(icon: "note.text", text: "Add notes: \"note: remember to...\"")
            }
            .font(.caption)
            .foregroundColor(.secondary.opacity(0.8))
            
            // Actions
            HStack {
                Button("Cancel") {
                    isPresented = false
                }
                .buttonStyle(.plain)
                .foregroundColor(.secondary)
                
                Spacer()
                
                Button("Add Task") {
                    addTask()
                }
                .buttonStyle(.borderedProminent)
                .disabled(parsedTask?.title.isEmpty ?? true)
                .keyboardShortcut(.return, modifiers: [])
            }
        }
        .padding()
        .frame(width: 350)
        .background(Color(nsColor: .windowBackgroundColor))
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .shadow(color: .black.opacity(0.2), radius: 20, y: 10)
        .onAppear {
            isFocused = true
        }
        .animation(.spring(response: 0.3), value: parsedTask?.title)
    }
    
    private func addTask() {
        guard let parsed = parsedTask, !parsed.title.isEmpty else { return }
        
        let task = PomodoroTask(
            title: parsed.title,
            notes: parsed.notes,
            estimatedPomodoros: parsed.pomodoros,
            priority: parsed.priority
        )
        
        taskViewModel.addTaskDirectly(task)
        isPresented = false
    }
}

struct TaskPreviewCard: View {
    let parsed: ParsedTaskInput
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text("Preview")
                    .font(.caption)
                    .foregroundColor(.secondary)
                
                Spacer()
            }
            
            HStack(spacing: 12) {
                // Priority indicator
                Circle()
                    .fill(parsed.priority.displayColor)
                    .frame(width: 8, height: 8)
                
                // Title
                Text(parsed.title)
                    .font(.subheadline)
                    .fontWeight(.medium)
                    .lineLimit(1)
                
                Spacer()
                
                // Pomodoros
                HStack(spacing: 2) {
                    ForEach(0..<min(parsed.pomodoros, 5), id: \.self) { _ in
                        Image(systemName: "circle.fill")
                            .font(.system(size: 6))
                            .foregroundColor(.red)
                    }
                    if parsed.pomodoros > 5 {
                        Text("+\(parsed.pomodoros - 5)")
                            .font(.caption2)
                            .foregroundColor(.secondary)
                    }
                }
            }
            
            if !parsed.notes.isEmpty {
                Text(parsed.notes)
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .lineLimit(2)
            }
        }
        .padding(12)
        .background(
            RoundedRectangle(cornerRadius: 10)
                .fill(Color(nsColor: .controlBackgroundColor))
                .overlay(
                    RoundedRectangle(cornerRadius: 10)
                        .stroke(Color.accentColor.opacity(0.3), lineWidth: 1)
                )
        )
    }
}

struct HintRow: View {
    let icon: String
    let text: String
    
    var body: some View {
        HStack(spacing: 6) {
            Image(systemName: icon)
                .frame(width: 14)
            Text(text)
        }
    }
}

struct ParsedTaskInput {
    var title: String
    var pomodoros: Int
    var priority: TaskPriority
    var notes: String
}

struct TaskInputParser {
    static func parse(_ input: String) -> ParsedTaskInput {
        var title = input.trimmingCharacters(in: .whitespacesAndNewlines)
        var pomodoros = 1
        var priority = TaskPriority.medium
        var notes = ""
        
        // Extract notes (note: or notes:)
        if let noteRange = title.range(of: "note:", options: .caseInsensitive) {
            notes = String(title[noteRange.upperBound...]).trimmingCharacters(in: .whitespacesAndNewlines)
            title = String(title[..<noteRange.lowerBound]).trimmingCharacters(in: .whitespacesAndNewlines)
        } else if let noteRange = title.range(of: "notes:", options: .caseInsensitive) {
            notes = String(title[noteRange.upperBound...]).trimmingCharacters(in: .whitespacesAndNewlines)
            title = String(title[..<noteRange.lowerBound]).trimmingCharacters(in: .whitespacesAndNewlines)
        }
        
        // Extract priority
        let priorityPatterns: [(String, TaskPriority)] = [
            ("high priority", .high),
            ("high", .high),
            ("!!", .high),
            ("urgent", .high),
            ("medium priority", .medium),
            ("medium", .medium),
            ("!", .medium),
            ("low priority", .low),
            ("low", .low)
        ]
        
        for (pattern, p) in priorityPatterns {
            if let range = title.range(of: pattern, options: .caseInsensitive) {
                priority = p
                title = title.replacingCharacters(in: range, with: "").trimmingCharacters(in: .whitespacesAndNewlines)
                break
            }
        }
        
        // Extract pomodoros
        let pomodoroPatterns = [
            #"(\d+)\s*pomodoros?"#,
            #"(\d+)\s*poms?"#,
            #"(\d+)\s*🍅"#,
            #"est:?\s*(\d+)"#
        ]
        
        for pattern in pomodoroPatterns {
            if let regex = try? NSRegularExpression(pattern: pattern, options: .caseInsensitive),
               let match = regex.firstMatch(in: title, range: NSRange(title.startIndex..., in: title)),
               let numberRange = Range(match.range(at: 1), in: title) {
                if let number = Int(title[numberRange]), number > 0, number <= 20 {
                    pomodoros = number
                }
                if let fullRange = Range(match.range, in: title) {
                    title = title.replacingCharacters(in: fullRange, with: "").trimmingCharacters(in: .whitespacesAndNewlines)
                }
                break
            }
        }
        
        // Clean up extra spaces
        title = title.components(separatedBy: .whitespaces)
            .filter { !$0.isEmpty }
            .joined(separator: " ")
        
        return ParsedTaskInput(
            title: title,
            pomodoros: pomodoros,
            priority: priority,
            notes: notes
        )
    }
}

extension TaskPriority {
    var displayColor: Color {
        switch self {
        case .low: return .gray
        case .medium: return .orange
        case .high: return .red
        }
    }
}

#Preview {
    QuickAddTaskView(isPresented: .constant(true))
        .frame(width: 400, height: 400)
}
