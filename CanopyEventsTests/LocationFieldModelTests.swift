import Foundation
import Testing
@testable import CanopyEvents

/// The Location field's behavior, driven by a fake Apple Maps: how an
/// event opens, typing and suggestions, Use "…", picking, editing after a
/// pick and clearing (the web's views/editor.html). Not in a target yet.
@MainActor
struct LocationFieldModelTests {
    let search = FakePlaceSearch()
    let park = PlaceSuggestion(id: "poi-1", title: "Dolores Park", subtitle: "Dolores St & 19th St, San Francisco", kind: .poi)
    let street = PlaceSuggestion(id: "addr-1", title: "1 Dolores St", subtitle: "San Francisco, CA", kind: .address)

    private func field(_ location: EventLocation = EventLocation()) -> LocationFieldModel {
        LocationFieldModel(location: location, search: search)
    }

    @Test func anEventOpensAsAPickOrAsItsText() {
        let picnic = PreviewData.event(MockEvents.birthdayId).location
        let kept = field(picnic)
        #expect(kept.text == "Dolores Park" && kept.line == "Dolores St & 19th St, San Francisco")
        #expect(kept.mode == .kept && kept.value == picnic && picnic.hasPin)
        let addressOnly = field(EventLocation(locationAddress: "742 Valencia St"))
        #expect(addressOnly.text == "742 Valencia St" && addressOnly.line.isEmpty)
        let nameOnly = field(EventLocation(locationName: "The usual"))
        #expect(nameOnly.text == "The usual" && nameOnly.value.locationName == "The usual")
    }

    @Test func typingAsksFromTwoCharactersAndKeepsOnlyCurrentAnswers() {
        let model = field()
        model.edit("d")
        #expect(search.asked.isEmpty && !model.offersSuggestions)
        model.edit("do")
        model.edit("dol ")
        #expect(search.asked == ["do", "dol"] && model.offersSuggestions)
        search.answer("do", [street])
        #expect(model.suggestions.isEmpty)
        search.answer("dol", [park, street])
        #expect(model.suggestions == [park, street])
        // The last ones stay until the next arrive.
        model.edit("dolo")
        #expect(model.suggestions == [park, street])
    }

    @Test func typedTextIsSavedPrivately() {
        let model = field(PreviewData.event(MockEvents.birthdayId).location)
        model.edit("Ana's, 12 Oak St")
        model.close()
        #expect(model.value == EventLocation(locationAddress: "Ana's, 12 Oak St"))
        #expect(model.line.isEmpty && model.mode == .typed)
    }

    @Test func aPickFillsTheFieldsThenTheWholePlace() async {
        search.places[park.id] = PickedPlace(
            name: "Dolores Park", address: "19th St & Dolores St, San Francisco, CA 94114, United States",
            latitude: 37.759773, longitude: -122.427063, applePlaceId: "I5B8A0D4E1F2C3B7A", kind: .poi)
        search.holdsPicks = true
        let model = field()
        model.edit("dolores")
        let picking = Task { await model.pick(park) }
        await Task.yield()
        #expect(model.text == "Dolores Park" && model.line == park.subtitle)
        #expect(model.value == EventLocation(locationName: "Dolores Park", locationAddress: park.subtitle))
        search.resolve()
        await picking.value
        #expect(model.value.hasPin && model.value.applePlaceId == "I5B8A0D4E1F2C3B7A")
        #expect(model.line == "19th St & Dolores St, San Francisco, CA 94114, United States")
        #expect(!model.offersSuggestions)
    }

    @Test func anAddressPickIsNeverTheName() async {
        let model = field()
        model.edit("1 dolores")
        await model.pick(street)
        // Not found: what's known so far stays.
        #expect(model.text == "1 Dolores St" && model.value.locationName == nil)
        #expect(model.value.locationAddress == "1 Dolores St, San Francisco, CA" && !model.value.hasPin)
    }

    @Test func editingAfterAPickLetsItGo() async {
        search.places[park.id] = PickedPlace(name: "Dolores Park", address: "19th St", latitude: 1, longitude: 2, kind: .poi)
        search.holdsPicks = true
        let model = field()
        model.edit("dolores")
        let picking = Task { await model.pick(park) }
        await Task.yield()
        model.edit("Dolores Park, by the tennis courts")
        search.resolve()
        await picking.value
        // The late answer doesn't bring the pick back.
        #expect(model.value == EventLocation(locationAddress: "Dolores Park, by the tennis courts"))
        #expect(model.line.isEmpty && model.mode == .typed)
    }

    @Test func clearingEmptiesIt() {
        let model = field(PreviewData.event(MockEvents.birthdayId).location)
        model.clear()
        #expect(model.text.isEmpty && model.line.isEmpty && model.value == EventLocation())
    }
}
