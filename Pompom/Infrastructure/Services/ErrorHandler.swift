import Foundation
import AppKit
import os.log

enum AppError: LocalizedError {
    case persistenceError(String)
    case notificationError(String)
    case soundError(String)
    case importError(String)
    case exportError(String)
    case unknown(Error)
    
    var errorDescription: String? {
        switch self {
        case .persistenceError(let message):
            return "Data Error: \(message)"
        case .notificationError(let message):
            return "Notification Error: \(message)"
        case .soundError(let message):
            return "Sound Error: \(message)"
        case .importError(let message):
            return "Import Error: \(message)"
        case .exportError(let message):
            return "Export Error: \(message)"
        case .unknown(let error):
            return "Unknown Error: \(error.localizedDescription)"
        }
    }
    
    var recoverySuggestion: String? {
        switch self {
        case .persistenceError:
            return "Try restarting the app. If the problem persists, reset your data from Settings."
        case .notificationError:
            return "Check System Preferences > Notifications to ensure Pompom has permission."
        case .soundError:
            return "Check your system volume and sound settings."
        case .importError:
            return "Make sure you selected a valid Pompom backup file."
        case .exportError:
            return "Make sure you have write permissions to the selected location."
        case .unknown:
            return "Try restarting the app."
        }
    }
}

final class ErrorHandler {
    static let shared = ErrorHandler()
    
    private let logger = Logger(subsystem: "com.pompom.app", category: "errors")
    
    private init() {}
    
    func handle(_ error: Error, context: String = "", showAlert: Bool = true) {
        let appError: AppError
        
        if let ae = error as? AppError {
            appError = ae
        } else {
            appError = .unknown(error)
        }
        
        logger.error("[\(context)] \(appError.localizedDescription)")
        
        if showAlert {
            showErrorAlert(appError)
        }
    }
    
    func log(_ message: String, level: OSLogType = .info) {
        logger.log(level: level, "\(message)")
    }
    
    func logDebug(_ message: String) {
        #if DEBUG
        logger.debug("\(message)")
        #endif
    }
    
    private func showErrorAlert(_ error: AppError) {
        DispatchQueue.main.async {
            let alert = NSAlert()
            alert.messageText = error.errorDescription ?? "An error occurred"
            alert.informativeText = error.recoverySuggestion ?? ""
            alert.alertStyle = .warning
            alert.addButton(withTitle: "OK")
            alert.runModal()
        }
    }
    
    func showInfo(title: String, message: String) {
        DispatchQueue.main.async {
            let alert = NSAlert()
            alert.messageText = title
            alert.informativeText = message
            alert.alertStyle = .informational
            alert.addButton(withTitle: "OK")
            alert.runModal()
        }
    }
    
    func showConfirmation(
        title: String,
        message: String,
        confirmTitle: String = "Confirm",
        cancelTitle: String = "Cancel",
        isDestructive: Bool = false
    ) -> Bool {
        let alert = NSAlert()
        alert.messageText = title
        alert.informativeText = message
        alert.alertStyle = isDestructive ? .critical : .warning
        alert.addButton(withTitle: confirmTitle)
        alert.addButton(withTitle: cancelTitle)
        
        return alert.runModal() == .alertFirstButtonReturn
    }
}

@propertyWrapper
struct SafeUserDefault<T: Codable> {
    let key: String
    let defaultValue: T
    let container: UserDefaults
    
    init(key: String, defaultValue: T, container: UserDefaults = .standard) {
        self.key = key
        self.defaultValue = defaultValue
        self.container = container
    }
    
    var wrappedValue: T {
        get {
            guard let data = container.data(forKey: key) else {
                return defaultValue
            }
            
            do {
                return try JSONDecoder().decode(T.self, from: data)
            } catch {
                ErrorHandler.shared.logDebug("Failed to decode \(key): \(error)")
                return defaultValue
            }
        }
        set {
            do {
                let data = try JSONEncoder().encode(newValue)
                container.set(data, forKey: key)
            } catch {
                ErrorHandler.shared.handle(
                    AppError.persistenceError("Failed to save \(key)"),
                    context: "SafeUserDefault",
                    showAlert: false
                )
            }
        }
    }
}
