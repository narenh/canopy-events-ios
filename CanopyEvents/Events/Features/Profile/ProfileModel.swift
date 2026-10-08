import Foundation
import Observation

/// Editing your own profile. Your details live in the account service,
/// so saving goes through `AppSession`, not the events repository.
@Observable
final class ProfileModel {
    var draft: ProfileDraft
    private(set) var saved: ProfileDraft
    private(set) var isSaving = false
    var errorMessage: String?

    init(me: Me) {
        draft = ProfileDraft(me: me)
        saved = ProfileDraft(me: me)
    }

    var hasChanges: Bool { draft != saved }

    func save(using session: AppSession) async {
        isSaving = true
        defer { isSaving = false }
        do {
            try await session.updateProfile(draft)
            saved = draft
        } catch {
            errorMessage = error.localizedDescription
        }
    }
}
