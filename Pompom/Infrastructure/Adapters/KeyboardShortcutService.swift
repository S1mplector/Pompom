import Foundation
import Carbon
import AppKit
import Combine

struct KeyboardShortcut: Equatable, Codable {
    let keyCode: UInt32
    let modifiers: UInt32
    
    static let startPause = KeyboardShortcut(keyCode: UInt32(kVK_Space), modifiers: UInt32(cmdKey | controlKey))
    static let skip = KeyboardShortcut(keyCode: UInt32(kVK_RightArrow), modifiers: UInt32(cmdKey | controlKey))
    static let reset = KeyboardShortcut(keyCode: UInt32(kVK_ANSI_R), modifiers: UInt32(cmdKey | controlKey))
}

protocol KeyboardShortcutPort {
    var shortcutTriggered: AnyPublisher<ShortcutAction, Never> { get }
    func register()
    func unregister()
}

enum ShortcutAction {
    case startPause
    case skip
    case reset
}

final class GlobalKeyboardShortcutService: KeyboardShortcutPort {
    private let shortcutSubject = PassthroughSubject<ShortcutAction, Never>()
    private var eventMonitor: Any?
    
    var shortcutTriggered: AnyPublisher<ShortcutAction, Never> {
        shortcutSubject.eraseToAnyPublisher()
    }
    
    func register() {
        eventMonitor = NSEvent.addGlobalMonitorForEvents(matching: .keyDown) { [weak self] event in
            self?.handleKeyEvent(event)
        }
    }
    
    func unregister() {
        if let monitor = eventMonitor {
            NSEvent.removeMonitor(monitor)
            eventMonitor = nil
        }
    }
    
    private func handleKeyEvent(_ event: NSEvent) {
        let modifiers = event.modifierFlags.intersection([.command, .control, .option, .shift])
        
        // Cmd + Ctrl + Space = Start/Pause
        if modifiers == [.command, .control] && event.keyCode == kVK_Space {
            shortcutSubject.send(.startPause)
        }
        // Cmd + Ctrl + Right Arrow = Skip
        else if modifiers == [.command, .control] && event.keyCode == kVK_RightArrow {
            shortcutSubject.send(.skip)
        }
        // Cmd + Ctrl + R = Reset
        else if modifiers == [.command, .control] && event.keyCode == kVK_ANSI_R {
            shortcutSubject.send(.reset)
        }
    }
    
    deinit {
        unregister()
    }
}
