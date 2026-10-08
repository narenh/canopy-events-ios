import Foundation

/// Your inbox and push devices, plus who gets told about an event.
extension MockEventsRepository {
    func notifications(page: PageRequest) async throws -> NotificationList {
        await pause()
        let inbox = myInbox.sorted { $0.createdAt > $1.createdAt }
        let (items, next) = try MockPaging.page(inbox, page)
        return NotificationList(notifications: items, unreadCount: unreadCount, nextCursor: next)
    }

    func unreadNotificationCount() async throws -> Int {
        await pause()
        return unreadCount
    }

    func markNotificationsRead(ids: [InboxNotification.ID]) async throws -> Int {
        await pause()
        guard (1...100).contains(ids.count) else {
            throw APIError(message: "Mark 1 to 100 at a time.", reason: .badIds)
        }
        backend.inboxes[personId] = myInbox.map { item in
            var item = item
            if ids.contains(item.id) { item.read = true }
            return item
        }
        return unreadCount
    }

    func markAllNotificationsRead() async throws -> Int {
        await pause()
        backend.inboxes[personId] = myInbox.map { item in
            var item = item
            item.read = true
            return item
        }
        return 0
    }

    func registerDevice(token: String) async throws {
        await pause()
        guard (16...4096).contains(token.count) else {
            throw APIError(message: "That isn't a device token.", reason: .badToken)
        }
        // A token is one phone: it moves to whoever registers it last.
        for owner in backend.devices.keys { backend.devices[owner]?.removeAll { $0 == token } }
        backend.devices[personId, default: []].append(token)
        backend.devices[personId] = Array(backend.devices[personId, default: []].suffix(10))
    }

    func unregisterDevice(token: String) async throws {
        await pause()
        backend.devices[personId]?.removeAll { $0 == token }
    }

    /// Tells everyone going, maybe or waitlisted, and the other hosts.
    func notifyEveryoneComing(_ record: MockEventRecord, _ type: NotificationType, details: NotificationDetails? = nil) {
        let guests = record.guests.filter { $0.status.canPost }.map(\.person.id)
        for id in guests + record.event.hosts.map(\.person.id) {
            backend.notify(id, type, about: record.event, from: currentUser.person, details: details)
        }
    }

    private var myInbox: [InboxNotification] { backend.inboxes[personId, default: []] }
    private var unreadCount: Int { myInbox.filter { !$0.read }.count }
}
