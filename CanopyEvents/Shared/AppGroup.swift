import Foundation

/// The App Group the app and its notification extension share
/// (`group.com.canopysf.CanopyEvents`), for the little they hand each
/// other: answers given from an expanded notification.
nonisolated enum AppGroup {
    static let identifier = "group.com.canopysf.CanopyEvents"

    /// The shared folder, or nil if the group isn't set up (no entitlement).
    static var container: URL? {
        FileManager.default.containerURL(forSecurityApplicationGroupIdentifier: identifier)
    }
}
