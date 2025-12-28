import SwiftUI

struct TaskRowEnhanced: View {
    let task: PomodoroTask
    let isSelected: Bool
    let onToggle: () -> Void
    let onSelect: () -> Void
    let onDelete: () -> Void
    let onEdit: () -> Void
    
    @State private var isHovered = false
    
    var body: some View {
        HStack(spacing: 12) {
            // Checkbox
            CheckboxButton(isChecked: task.isCompleted, action: onToggle)
            
            // Task content
            VStack(alignment: .leading, spacing: 2) {
                Text(task.title)
                    .font(.subheadline)
                    .fontWeight(isSelected ? .medium : .regular)
                    .strikethrough(task.isCompleted)
                    .foregroundColor(task.isCompleted ? .secondary : .primary)
                    .lineLimit(2)
                
                if task.estimatedPomodoros > 1 || task.completedPomodoros > 0 {
                    PomodoroProgressPills(
                        completed: task.completedPomodoros,
                        total: task.estimatedPomodoros
                    )
                }
            }
            
            Spacer()
            
            // Actions
            if isHovered && !task.isCompleted {
                HStack(spacing: 4) {
                    IconButton(icon: "pencil", color: .blue, action: onEdit)
                    IconButton(icon: "trash", color: .red, action: onDelete)
                }
                .transition(.opacity.combined(with: .scale(scale: 0.8)))
            }
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 10)
        .background(
            RoundedRectangle(cornerRadius: 10)
                .fill(backgroundColor)
                .overlay(
                    RoundedRectangle(cornerRadius: 10)
                        .stroke(isSelected ? Color.accentColor.opacity(0.5) : Color.clear, lineWidth: 1.5)
                )
        )
        .onTapGesture {
            if !task.isCompleted {
                onSelect()
            }
        }
        .onHover { hovering in
            withAnimation(.easeInOut(duration: 0.15)) {
                isHovered = hovering
            }
        }
    }
    
    private var backgroundColor: Color {
        if isSelected {
            return Color.accentColor.opacity(0.1)
        } else if isHovered {
            return Color(nsColor: .controlBackgroundColor)
        }
        return Color.clear
    }
}

struct CheckboxButton: View {
    let isChecked: Bool
    let action: () -> Void
    
    @State private var isHovered = false
    
    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 6)
                .fill(isChecked ? Color.green : Color.clear)
                .frame(width: 22, height: 22)
            
            RoundedRectangle(cornerRadius: 6)
                .stroke(isChecked ? Color.green : Color.secondary.opacity(0.5), lineWidth: 1.5)
                .frame(width: 22, height: 22)
            
            if isChecked {
                Image(systemName: "checkmark")
                    .font(.system(size: 12, weight: .bold))
                    .foregroundColor(.white)
            }
        }
        .scaleEffect(isHovered ? 1.1 : 1.0)
        .contentShape(Rectangle())
        .onTapGesture {
            action()
        }
        .onHover { hovering in
            withAnimation(.spring(response: 0.2)) {
                isHovered = hovering
            }
        }
    }
}

struct PomodoroProgressPills: View {
    let completed: Int
    let total: Int
    
    var body: some View {
        HStack(spacing: 3) {
            ForEach(0..<total, id: \.self) { index in
                Capsule()
                    .fill(index < completed ? Color.red : Color.secondary.opacity(0.2))
                    .frame(width: 16, height: 4)
            }
            
            Text("\(completed)/\(total)")
                .font(.system(size: 10))
                .foregroundColor(.secondary)
                .padding(.leading, 4)
        }
    }
}

#Preview {
    VStack(spacing: 8) {
        TaskRowEnhanced(
            task: PomodoroTask(title: "Design new feature", estimatedPomodoros: 4, completedPomodoros: 2),
            isSelected: true,
            onToggle: {},
            onSelect: {},
            onDelete: {},
            onEdit: {}
        )
        
        TaskRowEnhanced(
            task: PomodoroTask(title: "Review pull requests", estimatedPomodoros: 2),
            isSelected: false,
            onToggle: {},
            onSelect: {},
            onDelete: {},
            onEdit: {}
        )
    }
    .padding()
    .frame(width: 300)
}
