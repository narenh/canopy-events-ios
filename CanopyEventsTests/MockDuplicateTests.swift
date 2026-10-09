import Foundation
import Testing
@testable import CanopyEvents

/// Duplicating against docs/api.md: the draft's fields, who may ask for
/// one, what a saved copy carries and doesn't, its own cover, and
/// `coverFrom`'s refusals. Not in a target yet, like `MockFlowTests`.
@MainActor
struct MockDuplicateTests {
    let session = AppSession.mock(delay: .zero)

    /// Maya's finale with everything a copy carries: details (parking too,
    /// which signed-out people don't see), a cap, plus-ones, a grey page
    /// with an accent, a hidden guest list and a background as its cover.
    private func richFinale(_ repository: any EventsRepository) async throws -> Event {
        var draft = EventDraft(event: try await repository.event(id: MockEvents.dragFinaleId))
        draft.details = [EventDetailInput(type: .dressCode, value: "Fierce"), EventDetailInput(type: .parking, value: "Street only")]
        draft.capacity = 30
        draft.guestsAllowed = 2
        draft.guestListVisibility = .responded
        draft.theme = .grayscale
        draft.accentHue = 200
        _ = try await repository.updateEvent(id: MockEvents.dragFinaleId, with: draft)
        return try await repository.setCoverBackground(eventId: MockEvents.dragFinaleId, backgroundId: MockBackgrounds.all[0].id)
    }

    /// The draft as the host saves it, a week from now.
    private func copyDraft(_ draft: DuplicateDraft) -> EventDraft {
        var copy = EventDraft(duplicate: draft)
        copy.startsAt = .now.addingTimeInterval(7 * 86_400)
        return copy
    }

    @Test func theDraftIsTheEventsFieldsWithNoTimesAndYourLists() async throws {
        try await session.signInWithPasskey()
        let repository = session.repository
        let original = try await richFinale(repository)
        let draft = try await repository.duplicateDraft(eventId: original.id)
        #expect(draft.title == original.title && draft.description == original.description)
        #expect(draft.locationName == original.locationName && draft.locationAddress == original.locationAddress)
        #expect(draft.timeZone == original.timeZone)
        #expect(draft.details.map(\.type) == [.dressCode, .parking] && draft.details.map(\.value) == ["Fierce", "Street only"])
        #expect(draft.guestListVisibility == .responded && draft.guestsAllowed == 2 && draft.capacity == 30)
        #expect(draft.themeHue == 320 && draft.themeGrayscale && draft.accentHue == 200)
        #expect(draft.coverFrom == original.id && draft.coverImageUrl == original.coverImageUrl)
        #expect(draft.coverImages == original.coverImages && draft.coverTheme == original.coverTheme)
        #expect(draft.lists == [DuplicateDraftList(id: MockLists.dragRaceId, name: "Drag Race")])
        let form = EventDraft(duplicate: draft)
        #expect(form.startsAt == nil && form.endsAt == nil && form.coverFrom == original.id && !form.isValid)
        // An event with no cover has nothing to copy.
        #expect(try await repository.duplicateDraft(eventId: MockEvents.gameNightId).coverFrom == nil)
    }

    @Test func onlyVerifiedHostsGetADraftAndACohostGetsOnlyTheirOwnLists() async throws {
        try await session.signInWithPasskey()
        let maya = session.repository
        let guest = await #expect(throws: APIError.self) { try await maya.duplicateDraft(eventId: MockEvents.rooftopId) }
        #expect(guest?.reason == .hostsOnly)
        let wrong = await #expect(throws: APIError.self) { try await maya.duplicateDraft(eventId: "zzzzzzzzzzzz") }
        #expect(wrong?.reason == .eventNotFound)

        let backend = MockBackend(delay: .zero)
        let sam = MockEventsRepository(backend: backend, personId: MockPeople.sam.id)
        let quick = await #expect(throws: APIError.self) { try await sam.duplicateDraft(eventId: MockEvents.dragFinaleId) }
        #expect(quick?.reason == .emailUnverified)
        // Ben co-hosts the birthday: unverified, he's refused even so.
        let b = MockPeople.ben
        var ben = MockPeople.quickUser(id: b.id, firstName: b.firstName, lastName: b.lastName, email: "ben@example.com")
        backend.save(ben)
        let benRepository = MockEventsRepository(backend: backend, personId: b.id)
        let unverified = await #expect(throws: APIError.self) { try await benRepository.duplicateDraft(eventId: MockEvents.birthdayId) }
        #expect(unverified?.reason == .emailUnverified)
        // Verified, he gets it, without Maya's list on it.
        ben.emailVerified = true
        backend.save(ben)
        let mayaHere = MockEventsRepository(backend: backend, personId: MockPeople.maya.id)
        _ = try await mayaHere.attachList(eventId: MockEvents.birthdayId, listId: MockLists.climbingId)
        #expect(try await benRepository.duplicateDraft(eventId: MockEvents.birthdayId).lists.isEmpty)
        #expect(try await mayaHere.duplicateDraft(eventId: MockEvents.birthdayId).lists.map(\.name) == ["Climbing"])
    }

    @Test func aCopyHasEverythingButItsPeopleUpdatesAndLists() async throws {
        try await session.signInWithPasskey()
        let repository = session.repository
        let original = try await richFinale(repository)
        let copy = try await repository.createEvent(copyDraft(try await repository.duplicateDraft(eventId: original.id)))
        #expect(copy.id != original.id && copy.title == original.title && copy.capacity == 30)
        #expect(copy.details.map(\.value) == ["Fierce", "Street only"] && copy.accentHue == 200)
        #expect(copy.hosts.map(\.person.id) == [MockPeople.maya.id] && copy.hosts.first?.role == .creator)
        #expect(copy.counts.going == 0 && copy.counts.maybe == 0 && copy.counts.invited == 0)
        #expect(copy.hostLists == [] && copy.status == .active && copy.coverHue == original.coverHue)
        #expect(try await repository.wall(eventId: copy.id, page: .first).entries.isEmpty)
        // The original is untouched.
        let after = try await repository.event(id: original.id)
        #expect(after.counts == original.counts && after.hostLists?.count == 1)
    }

    @Test func theCopysCoverIsItsOwn() async throws {
        try await session.signInWithPasskey()
        let repository = session.repository
        let uploaded = try await repository.setCover(eventId: MockEvents.dragFinaleId, imageData: Self.png)
        let copy = try await repository.createEvent(copyDraft(try await repository.duplicateDraft(eventId: uploaded.id)))
        let url = try #require(copy.coverImageUrl)
        #expect(url != uploaded.coverImageUrl && copy.coverImages.first?.url == url)
        #expect(FileManager.default.fileExists(atPath: url.path()))
        // Taking the original's cover off, then deleting it, leaves the copy's.
        _ = try await repository.deleteCover(eventId: uploaded.id)
        try await repository.deleteEvent(id: uploaded.id)
        #expect(try await repository.event(id: copy.id).coverImageUrl == url)

        // A seed cover (a web address) is the copy's too, in its own record.
        let birthday = try await repository.event(id: MockEvents.birthdayId)
        let picnic = try await repository.createEvent(copyDraft(try await repository.duplicateDraft(eventId: birthday.id)))
        _ = try await repository.deleteCover(eventId: birthday.id)
        #expect(try await repository.event(id: picnic.id).coverImageUrl == birthday.coverImageUrl)
    }

    @Test func coverFromIsRefusedWithNothingMade() async throws {
        try await session.signInWithPasskey()
        let repository = session.repository
        let hosting = try await repository.allEvents(.hosting).count
        var draft = copyDraft(try await repository.duplicateDraft(eventId: MockEvents.birthdayId))
        for (from, reason) in [(MockEvents.rooftopId, APIErrorReason.hostsOnly), ("zzzzzzzzzzzz", .badCoverFrom),
                               (MockEvents.gameNightId, .noCover)] {
            draft.coverFrom = from
            let error = await #expect(throws: APIError.self) { try await repository.createEvent(draft) }
            #expect(error?.reason == reason)
        }
        // Another host took the cover off meanwhile: refused, then fine without.
        draft.coverFrom = MockEvents.birthdayId
        _ = try await repository.deleteCover(eventId: MockEvents.birthdayId)
        let gone = await #expect(throws: APIError.self) { try await repository.createEvent(draft) }
        #expect(gone?.reason == .noCover)
        #expect(try await repository.allEvents(.hosting).count == hosting)
        draft.coverFrom = nil
        #expect(try await repository.createEvent(draft).coverImageUrl == nil)
    }

    @Test func theEditorStartsFromTheDraftAndDropsTheCoverWhenItChanges() async throws {
        let draft = PreviewData.duplicateDraft(MockEvents.birthdayId)
        let model = EventEditorModel(duplicating: draft)
        #expect(model.isNew && model.draft.startsAt == nil && model.draft.endsAt == nil && !model.draft.isValid)
        #expect(model.draft.title == draft.title && model.draft.guestsAllowed == 2)
        #expect(model.hasCover && model.draft.coverFrom == MockEvents.birthdayId && model.coverMatch == .hue(150))
        model.removeCover()
        #expect(!model.hasCover && model.draft.coverFrom == nil && model.coverMatch == nil)

        let replaced = EventEditorModel(duplicating: draft)
        replaced.pick(MockBackgrounds.all[0])
        #expect(replaced.draft.coverFrom == nil && replaced.hasCover)
        let photo = EventEditorModel(duplicating: draft)
        photo.pick(Self.png)
        #expect(photo.draft.coverFrom == nil && photo.hasCover)
    }

    @Test func savingACopyFromTheEditorMakesItWithTheCover() async throws {
        try await session.signInWithPasskey()
        let repository = session.repository
        let model = EventEditorModel(duplicating: try await repository.duplicateDraft(eventId: MockEvents.birthdayId))
        model.pickStartDay(.now.addingTimeInterval(7 * 86_400))
        let copy = try #require(await model.save(using: repository))
        #expect(copy.hasCover && copy.coverHue == 150 && copy.title == "Maya's birthday picnic")
        #expect(copy.hosts.count == 1)
    }

    /// A tiny PNG, for an uploaded cover.
    static let png = Data(base64Encoded: "iVBORw0KGgoAAAANSUhEUgAAAAIAAAACCAIAAAD91JpzAAAAEElEQVR4nGM4YRMARAwQCgAnHgVRmKOiDwAAAABJRU5ErkJggg==")!
}
