import Foundation
import Observation

/// The host's "Lists…": the event's lists and yours, putting one on
/// (which invites everyone on it), taking one off, and making one that
/// goes on at once. Changes save straight away.
@Observable
final class EventListsModel {
    private(set) var event: Event
    /// Yours; nil while loading.
    private(set) var myLists: [OwnedList]?
    /// After a change: "Invited 17 from Drag Race."
    private(set) var notice: String?
    private(set) var isWorking = false
    var newName = ""
    var errorMessage: String?

    init(event: Event) {
        self.event = event
    }

    var onEvent: [HostList] { event.hostLists ?? [] }
    var others: [OwnedList] { (myLists ?? []).filter { list in !onEvent.contains { $0.id == list.id } } }
    var isOpen: Bool { EventPhase(event: event).isOpen }
    var canCreate: Bool { !newName.trimmingCharacters(in: .whitespaces).isEmpty && !isWorking }

    func load(from repository: any EventsRepository) async {
        myLists = (try? await repository.lists()) ?? []
    }

    func attach(_ list: OwnedList, using repository: any EventsRepository) async -> Event? {
        await run {
            let attached = try await repository.attachList(eventId: self.event.id, listId: list.id)
            self.notice = switch attached.invitedCount {
            case 0: "\(list.name) is on this event."
            case 1: "Invited 1 from \(list.name)."
            default: "Invited \(attached.invitedCount) from \(list.name)."
            }
            return attached.event
        }
    }

    func detach(_ list: HostList, using repository: any EventsRepository) async -> Event? {
        await run {
            self.notice = nil
            return try await repository.detachList(eventId: self.event.id, listId: list.id)
        }
    }

    /// Makes a list from `newName` and puts it on (it has nobody to invite yet).
    func create(using repository: any EventsRepository) async -> Event? {
        let name = newName
        return await run {
            let list = try await repository.createList(name: name)
            self.newName = ""
            self.myLists?.append(list)
            self.notice = "\(list.name) is on this event."
            return try await repository.attachList(eventId: self.event.id, listId: list.id).event
        }
    }

    private func run(_ change: () async throws -> Event) async -> Event? {
        isWorking = true
        defer { isWorking = false }
        do {
            event = try await change()
            return event
        } catch {
            errorMessage = error.localizedDescription
            return nil
        }
    }
}
