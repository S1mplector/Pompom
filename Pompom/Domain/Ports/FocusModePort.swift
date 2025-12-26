import Foundation

protocol FocusModePort {
    var isFocusModeEnabled: Bool { get }
    func enableFocusMode()
    func disableFocusMode()
}
