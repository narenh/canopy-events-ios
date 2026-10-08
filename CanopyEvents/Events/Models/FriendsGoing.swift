/// Which of your friends are going to an event. `people` is empty while
/// you can't see the guest list's names; `count` is always all of them.
nonisolated struct FriendsGoing: Codable, Hashable {
    var count: Int
    var people: [Person]
}
