import Foundation
import Testing
@testable import CanopyEvents

/// The mock's location rules against docs/api.md: the pin and place id
/// as private as the address, a street name dropped, typed text private,
/// refusals, and the pin carried to a copy. Not in a target yet.
@MainActor
struct MockLocationTests {
    let backend = MockBackend(delay: .zero)
    var maya: MockEventsRepository { MockEventsRepository(backend: backend, personId: MockPeople.maya.id) }

    private func draft(_ location: EventLocation) -> EventDraft {
        var draft = EventDraft.blank()
        draft.title = "Picnic"
        draft.startsAt = .now.addingTimeInterval(86_400)
        draft.location = location
        return draft
    }

    @Test func thePinIsSeenOnlyByThoseWhoSeeTheAddress() async throws {
        let picnic = try await maya.event(id: MockEvents.birthdayId)
        #expect(picnic.location.hasPin && picnic.applePlaceId != nil && !picnic.locationAddressHidden)
        _ = try await maya.invite(eventId: MockEvents.birthdayId, personIds: [MockPeople.sam.id])
        try await maya.removeGuest(eventId: MockEvents.birthdayId, personId: MockPeople.sam.id)
        let sam = MockEventsRepository(backend: backend, personId: MockPeople.sam.id)
        let seen = try await sam.event(id: MockEvents.birthdayId)
        #expect(seen.myStatus == .removed && seen.locationName == "Dolores Park")
        #expect(seen.locationAddress == nil && seen.latitude == nil && seen.longitude == nil && seen.applePlaceId == nil)
        #expect(seen.locationAddressHidden)
    }

    @Test func aPinWithoutAnAddressIsStillHidden() {
        var event = PreviewData.event(MockEvents.birthdayId)
        event.locationAddress = nil
        MockRules.hideLocation(of: &event)
        #expect(event.locationAddressHidden && event.latitude == nil && event.applePlaceId == nil)
    }

    @Test func aNameThatIsTheStreetLineIsDropped() async throws {
        let made = try await maya.createEvent(draft(EventLocation(
            locationName: "1 Market St", locationAddress: "1  market st, San Francisco, CA", latitude: 37.794, longitude: -122.3951)))
        #expect(made.locationName == nil && made.locationAddress == "1  market st, San Francisco, CA" && made.location.hasPin)
        let named = try await maya.createEvent(draft(EventLocation(locationName: "Ferry Building", locationAddress: "1 Market St")))
        #expect(named.locationName == "Ferry Building")
    }

    @Test func typedTextFromTheEditorIsSavedPrivately() async throws {
        let editor = EventEditorModel(event: try await maya.event(id: MockEvents.birthdayId), placeSearch: FakePlaceSearch())
        editor.location.edit("Ana's, 12 Oak St")
        let saved = try #require(await editor.save(using: maya))
        #expect(saved.locationName == nil && saved.locationAddress == "Ana's, 12 Oak St")
        #expect(saved.latitude == nil && saved.longitude == nil && saved.applePlaceId == nil)
    }

    @Test func savedUntouchedTheEventKeepsItsPin() async throws {
        let picnic = try await maya.event(id: MockEvents.birthdayId)
        let editor = EventEditorModel(event: picnic, placeSearch: FakePlaceSearch())
        let saved = try #require(await editor.save(using: maya))
        #expect(saved.location == picnic.location)
    }

    @Test func badPinsAreRefused() async throws {
        let half = await #expect(throws: APIError.self) {
            try await maya.createEvent(draft(EventLocation(locationAddress: "1 Market St", latitude: 37.7)))
        }
        #expect(half?.reason == .badCoordinates)
        let nowhere = await #expect(throws: APIError.self) {
            try await maya.createEvent(draft(EventLocation(latitude: 37.7, longitude: -122.4)))
        }
        #expect(nowhere?.reason == .badCoordinates)
        let badId = await #expect(throws: APIError.self) {
            try await maya.createEvent(draft(EventLocation(locationAddress: "1 Market St", applePlaceId: "no spaces")))
        }
        #expect(badId?.reason == .badApplePlaceId)
    }

    @Test func aCopyCarriesThePin() async throws {
        let copy = try await maya.duplicateDraft(eventId: MockEvents.birthdayId)
        #expect(copy.latitude == 37.759773 && copy.longitude == -122.427063 && copy.applePlaceId == "I5B8A0D4E1F2C3B7A")
        #expect(EventDraft(duplicate: copy).location.hasPin)
    }
}
