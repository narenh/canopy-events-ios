import Foundation

/// What the picked are sent to, 100 at a time (what the API takes):
/// inviting them to the event, adding them to the list, or "Save as list"
/// from the invite sheet.
extension PeoplePickerModel {
    /// The picked who can still be picked, in the order picked.
    private var picked: [Person.ID] {
        picker.selected.filter(picker.isPickable)
    }

    /// Invites the picked to the event. Returns how many were invited, or
    /// nil if it stopped on an error.
    func invite(using repository: any EventsRepository) async -> Int? {
        guard case .event(let event) = target else { return nil }
        let ids = picked
        guard !ids.isEmpty else { return 0 }
        isSending = true
        defer { isSending = false }
        var invited = 0
        do {
            for chunk in ids.chunked(100) {
                let result = try await repository.invite(eventId: event.id, personIds: chunk)
                invited += result.invited.count
                for person in result.invited { picker.taken[person.id] = .rsvp(.invited) }
            }
            return invited
        } catch {
            picker.dropUnpickable()
            errorMessage = error.localizedDescription
            return nil
        }
    }

    /// Adds the picked to the list. Returns the words to show ("Added 5
    /// people. Invited them to 1 event."), or nil if it stopped on an error.
    func addToList(using repository: any EventsRepository) async -> String? {
        guard case .list(let list) = target else { return nil }
        isSending = true
        defer { isSending = false }
        guard let result = await add(picked, to: list.id, using: repository) else { return nil }
        return PeoplePicker.addedNotice(added: result.added, invitedTo: result.invitedTo)
    }

    /// "Save as list": the picked onto one of your lists, or a new one
    /// named `name` (nil `listId`). Invites nobody to this event (unless
    /// the list is on it), and the picks stay. Sets `notice` and returns
    /// true when it's done.
    func saveAsList(to listId: OwnedList.ID?, named name: String, using repository: any EventsRepository) async -> Bool {
        let ids = picked
        guard !ids.isEmpty else { return false }
        isSending = true
        defer { isSending = false }
        let list: PeoplePicker.PickList
        if let existing = picker.lists.first(where: { $0.id == listId }) {
            list = existing
        } else {
            do {
                let made = try await repository.createList(name: name)
                list = PeoplePicker.PickList(id: made.id, name: made.name, memberIds: [])
                picker.lists.append(list)
            } catch {
                errorMessage = error.localizedDescription
                return false
            }
        }
        guard let result = await add(ids, to: list.id, using: repository) else { return false }
        if let index = picker.lists.firstIndex(where: { $0.id == list.id }) {
            picker.lists[index].memberIds += ids.filter { !list.memberIds.contains($0) }
        }
        // A list on events still to come invites them there, maybe here too.
        if result.invitedTo > 0, let fresh = try? await taken(from: repository) {
            picker.taken = fresh.0
            picker.dropUnpickable()
        }
        notice = PeoplePicker.savedNotice(ids.count, to: list.name, invitedTo: result.invitedTo)
        return true
    }

    /// Adds `ids` to a list of yours: how many were added, and how many
    /// events it invited them to (the most any one request did: they're
    /// the same list's events). On the list's own picker, they're marked
    /// "On list" as they go. Nil, with `errorMessage`, on an error.
    private func add(_ ids: [Person.ID], to listId: OwnedList.ID,
                     using repository: any EventsRepository) async -> (added: Int, invitedTo: Int)? {
        var added = 0, invitedTo = 0
        defer { picker.dropUnpickable() }
        do {
            for chunk in ids.chunked(100) {
                let result = try await repository.addListMembers(listId: listId, personIds: chunk)
                added += result.added.count
                invitedTo = max(invitedTo, result.invitedTo)
                if picker.kind == .list {
                    for id in result.added.map(\.id) + result.alreadyOn { picker.taken[id] = .onList }
                }
            }
            return (added, invitedTo)
        } catch {
            errorMessage = error.localizedDescription
            return nil
        }
    }
}

private extension Array {
    /// Runs of at most `size`, in order.
    func chunked(_ size: Int) -> [[Element]] {
        stride(from: 0, to: count, by: size).map { Array(self[$0..<Swift.min($0 + size, count)]) }
    }
}
