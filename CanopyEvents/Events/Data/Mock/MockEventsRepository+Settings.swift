import Foundation

/// Your settings, each at its default until changed.
extension MockEventsRepository {
    static let defaultSettings = Settings(calendarInvites: true)

    func settings() async throws -> Settings {
        await pause()
        return backend.settings[personId] ?? Self.defaultSettings
    }

    func updateSettings(calendarInvites: Bool?) async throws -> Settings {
        await pause()
        var settings = backend.settings[personId] ?? Self.defaultSettings
        if let calendarInvites { settings.calendarInvites = calendarInvites }
        backend.settings[personId] = settings
        return settings
    }
}
