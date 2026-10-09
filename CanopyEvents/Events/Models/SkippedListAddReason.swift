/// Why someone wasn't added to a list. `notFound` is also how someone
/// who opted out of your invitations is skipped, deliberately the same as
/// no account, so the answer never says who did.
nonisolated enum SkippedListAddReason: String, Codable, Hashable {
    case isYou = "is_you"
    case notFound = "not_found"
}
