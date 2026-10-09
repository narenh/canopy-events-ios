import Foundation

/// The host's "Duplicate".
extension EventDetailModel {
    /// Fetches what a copy of this event starts with; setting
    /// `duplicating` opens the new-event editor with it. Nothing is made
    /// until the host saves there.
    func duplicate(using repository: any EventsRepository) async {
        do {
            duplicating = try await repository.duplicateDraft(eventId: eventId)
        } catch {
            errorMessage = error.localizedDescription
        }
    }
}
