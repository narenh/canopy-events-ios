import Foundation
import Observation

/// Profile's events settings: whether invitations go in your calendar,
/// and the hosts whose invitations you've opted out of.
@Observable
final class ProfileSettingsModel {
    private(set) var calendarInvites = true
    private(set) var optedOut: [Person] = []
    private(set) var hasLoaded = false
    var errorMessage: String?

    func load(from repository: any EventsRepository) async {
        do {
            async let settings = repository.settings()
            async let optouts = repository.inviteOptouts()
            calendarInvites = try await settings.calendarInvites
            optedOut = try await optouts.hosts
            hasLoaded = true
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    func setCalendarInvites(_ on: Bool, using repository: any EventsRepository) async {
        calendarInvites = on
        do {
            calendarInvites = try await repository.updateSettings(calendarInvites: on).calendarInvites
        } catch {
            calendarInvites = !on
            errorMessage = error.localizedDescription
        }
    }

    /// Undo an opt-out: their invitations reach you again.
    func allowInvites(from host: Person, using repository: any EventsRepository) async {
        do {
            try await repository.optInToInvites(from: host.id)
            optedOut.removeAll { $0.id == host.id }
        } catch {
            errorMessage = error.localizedDescription
        }
    }
}
