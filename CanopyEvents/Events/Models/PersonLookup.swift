/// Finding someone to invite by their phone or Instagram, exactly one of
/// the two (`GET /api/v1/people/lookup?phone=` or `?instagram=`), as
/// typed: "(415) 555-1234", "@ana.lima". The server cleans it and matches
/// exactly. Look up when they press "find", never as they type.
nonisolated enum PersonLookup: Hashable {
    case phone(String)
    case instagram(String)
}
