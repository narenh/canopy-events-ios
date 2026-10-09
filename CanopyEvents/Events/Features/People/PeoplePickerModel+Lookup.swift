import Foundation

/// Looking someone up by a whole phone number or @username, and "Filter
/// by past event".
extension PeoplePickerModel {
    /// For a whole phone number or @username, once they stop typing (the
    /// view calls this in `.task(id:)`, which cancels it as they type on).
    func lookUp(using repository: any EventsRepository) async {
        let typed = picker.query.trimmingCharacters(in: .whitespaces)
        guard let kind = LookupKind(typed) else { lookup = nil; return }
        let key = "\(kind):\(typed.lowercased())"
        if let known = lookups[key] { lookup = PickerLookup(query: typed, state: known); return }
        lookup = PickerLookup(query: typed, state: .looking)
        try? await Task.sleep(for: .milliseconds(450))
        guard !Task.isCancelled else { return }
        let state: PickerLookup.State
        do {
            if let person = try await repository.lookUpPerson(kind.lookup(typed)), person.id != picker.me {
                picker.add(person, detail: PeoplePicker.detail(foundBy: kind))
                state = .found(person.id)
            } else {
                state = .none
            }
            lookups[key] = state
        } catch let error as APIError {
            state = .failed(PickerLookup.words(for: error.reason) ?? error.message)
        } catch {
            state = .failed(error.localizedDescription)
        }
        if picker.query.trimmingCharacters(in: .whitespaces) == typed { lookup = PickerLookup(query: typed, state: state) }
    }

    /// "Filter by past event": narrows the list to that event's hosts and
    /// its going and maybe guests you can see, ticking nobody; nil goes
    /// back to everyone. Returns the words to read out ("Showing 4 from
    /// Beach bonfire."), or nil.
    func filter(by eventId: Event.ID?, using repository: any EventsRepository) async -> String? {
        fromId = eventId
        guard let eventId, let past = pastEvents.first(where: { $0.id == eventId }) else {
            picker.from = nil
            return nil
        }
        do {
            let from: PeoplePicker.PastFilter
            if let known = pastPeople[eventId] {
                from = known
            } else {
                from = try await people(of: past, from: repository)
                pastPeople[eventId] = from
            }
            guard fromId == eventId else { return nil }
            picker.from = from
            return PeoplePicker.showing(from)
        } catch {
            if fromId == eventId { fromId = picker.from?.eventId }
            errorMessage = error.localizedDescription
            return nil
        }
    }

    private func people(of past: Event, from repository: any EventsRepository) async throws -> PeoplePicker.PastFilter {
        async let going = repository.guestList(eventId: past.id, status: .going, page: PageRequest(limit: 100))
        async let maybe = repository.guestList(eventId: past.id, status: .maybe, page: PageRequest(limit: 100))
        let (goingList, maybeList) = try await (going, maybe)
        // Its hosts too: not on its guest list, but they were there.
        let people = past.hosts.map(\.person) + (goingList.guests + maybeList.guests).map(\.person)
        var ids: [Person.ID] = []
        for person in people where person.id != picker.me && !ids.contains(person.id) {
            picker.add(person, detail: PeoplePicker.detail(fromEvent: past.title))
            ids.append(person.id)
        }
        return PeoplePicker.PastFilter(eventId: past.id, title: past.title, ids: ids, isHidden: !goingList.guestsVisible)
    }
}
