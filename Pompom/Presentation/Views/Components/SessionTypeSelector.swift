import SwiftUI

struct SessionTypeSelector: View {
    @Binding var selectedType: SessionType
    let isDisabled: Bool
    
    var body: some View {
        HStack(spacing: 4) {
            ForEach(SessionType.allCases, id: \.self) { type in
                SessionTypeButton(
                    type: type,
                    isSelected: selectedType == type,
                    isDisabled: isDisabled
                ) {
                    withAnimation(.spring(response: 0.3)) {
                        selectedType = type
                    }
                }
            }
        }
        .padding(4)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color(nsColor: .controlBackgroundColor))
        )
    }
}

struct SessionTypeButton: View {
    let type: SessionType
    let isSelected: Bool
    let isDisabled: Bool
    let action: () -> Void
    
    private var color: Color {
        switch type {
        case .work: return .red
        case .shortBreak: return .green
        case .longBreak: return .blue
        }
    }
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: 4) {
                Image(systemName: type.icon)
                    .font(.caption)
                
                Text(type.rawValue)
                    .font(.caption)
                    .fontWeight(isSelected ? .semibold : .regular)
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 8)
            .background(
                RoundedRectangle(cornerRadius: 8)
                    .fill(isSelected ? color.opacity(0.2) : Color.clear)
            )
            .foregroundColor(isSelected ? color : .secondary)
        }
        .buttonStyle(.plain)
        .disabled(isDisabled)
        .opacity(isDisabled ? 0.6 : 1)
    }
}

#Preview {
    SessionTypeSelector(selectedType: .constant(.work), isDisabled: false)
        .padding()
}
