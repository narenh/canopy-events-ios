import Foundation

/// What an event says about the lists on it (docs/api.md, "On the
/// event's answer"): `hostLists` to its hosts, `joinableList` to anyone
/// else. Only lists whose owner still hosts the event count.
extension MockBackend {
    /// The lists on it whose owner hosts it, in the order put on.
    func attachedLists(on record: MockEventRecord) -> [(list: MockListRecord, attachedAt: Date)] {
        record.attachedLists.compactMap { attached in
            guard let list = list(id: attached.listId), record.isHost(list.ownerId) else { return nil }
            return (list, attached.attachedAt)
        }
    }

    /// Every list on it, to a host (the count only on your own); nil for
    /// anyone else.
    func hostLists(on record: MockEventRecord, for me: Person.ID) -> [HostList]? {
        guard record.isHost(me) else { return nil }
        return attachedLists(on: record).compactMap { list, attachedAt in
            guard let owner = person(list.ownerId) else { return nil }
            let isYours = list.ownerId == me
            return HostList(id: list.id, name: list.name, code: list.code, url: list.url, owner: owner,
                            isYours: isYours, memberCount: isYours ? list.members.count : nil, attachedAt: attachedAt)
        }
    }

    /// A list on it that `me` isn't on: the creator's first, then the one
    /// put on first. Nil for hosts and anyone a host removed.
    func joinableList(on record: MockEventRecord, for me: Person.ID) -> JoinableList? {
        guard !record.isHost(me), record.guest(me)?.status != .removed else { return nil }
        let open = attachedLists(on: record).map(\.list).filter { !$0.hasMember(me) && $0.ownerId != me }
        let first = open.first { record.isCreator($0.ownerId) } ?? open.first
        guard let list = first, let owner = person(list.ownerId) else { return nil }
        return JoinableList(code: list.code, name: list.name, url: list.url, owner: owner)
    }
}
