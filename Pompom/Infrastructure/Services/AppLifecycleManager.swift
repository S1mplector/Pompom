import Foundation
import AppKit
import ServiceManagement

final class AppLifecycleManager: ObservableObject {
    static let shared = AppLifecycleManager()
    
    @Published var isLaunchAtLoginEnabled: Bool {
        didSet {
            setLaunchAtLogin(enabled: isLaunchAtLoginEnabled)
        }
    }
    
    private let launchAtLoginKey = "launchAtLogin"
    
    private init() {
        self.isLaunchAtLoginEnabled = UserDefaults.standard.bool(forKey: launchAtLoginKey)
    }
    
    private func setLaunchAtLogin(enabled: Bool) {
        UserDefaults.standard.set(enabled, forKey: launchAtLoginKey)
        
        if #available(macOS 13.0, *) {
            do {
                if enabled {
                    try SMAppService.mainApp.register()
                } else {
                    try SMAppService.mainApp.unregister()
                }
            } catch {
                print("Failed to update login item: \(error)")
            }
        }
    }
    
    func setupAppearance() {
        NSApp.setActivationPolicy(.accessory)
    }
    
    func showAboutPanel() {
        NSApp.orderFrontStandardAboutPanel(
            options: [
                .applicationName: "Pompom",
                .applicationVersion: Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString") as? String ?? "1.0",
                .version: Bundle.main.object(forInfoDictionaryKey: "CFBundleVersion") as? String ?? "1",
                .credits: NSAttributedString(
                    string: "A beautiful Pomodoro timer for macOS\n\nBuilt with SwiftUI",
                    attributes: [
                        .font: NSFont.systemFont(ofSize: 11),
                        .foregroundColor: NSColor.secondaryLabelColor
                    ]
                )
            ]
        )
    }
    
    func openSettings() {
        if #available(macOS 14.0, *) {
            NSApp.sendAction(Selector(("showSettingsWindow:")), to: nil, from: nil)
        } else {
            NSApp.sendAction(Selector(("showPreferencesWindow:")), to: nil, from: nil)
        }
    }
    
    func quitApp() {
        NSApplication.shared.terminate(nil)
    }
}

extension Bundle {
    var appName: String {
        object(forInfoDictionaryKey: "CFBundleName") as? String ?? "Pompom"
    }
    
    var appVersion: String {
        object(forInfoDictionaryKey: "CFBundleShortVersionString") as? String ?? "1.0"
    }
    
    var buildNumber: String {
        object(forInfoDictionaryKey: "CFBundleVersion") as? String ?? "1"
    }
    
    var fullVersion: String {
        "\(appVersion) (\(buildNumber))"
    }
}
