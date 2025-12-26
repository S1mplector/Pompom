import Foundation

protocol NotificationPort {
    func requestAuthorization() async -> Bool
    func sendNotification(title: String, body: String)
    func removeAllPendingNotifications()
}
