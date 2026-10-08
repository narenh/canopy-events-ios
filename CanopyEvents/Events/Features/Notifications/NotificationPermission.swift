import UserNotifications

/// Asking to show notifications: once, after sign-in (not at a cold
/// launch, before the app has shown what it's for). Saying no is fine:
/// the app works the same, and the inbox still has everything.
enum NotificationPermission {
    /// Asks if it hasn't been asked yet; answers whether notifications
    /// may be shown.
    @discardableResult
    static func requestIfUndetermined() async -> Bool {
        let center = UNUserNotificationCenter.current()
        switch await center.notificationSettings().authorizationStatus {
        case .notDetermined:
            return (try? await center.requestAuthorization(options: [.alert, .sound, .badge])) ?? false
        case .denied:
            return false
        default:
            return true
        }
    }
}
