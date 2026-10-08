import Foundation

/// Friends to suggest first when inviting, with their scores.
extension MockEventsRepository {
    func suggestedFriends(limit: Int) async throws -> [SuggestedFriend] {
        await pause()
        guard (1...50).contains(limit) else { throw APIError(message: "Suggestions are 1 to 50.", reason: .badLimit) }
        return Array(backend.suggestedFriends(of: currentUser.person).prefix(limit))
    }
}
