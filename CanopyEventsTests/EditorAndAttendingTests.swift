import Foundation
import Testing
@testable import CanopyEvents

/// The editor's when and color rules, and Attending's words and order.
@MainActor
struct EditorAndAttendingTests {
    @Test func theEndMovesWithTheStartAndDefaultsToThreeHours() throws {
        let model = EventEditorModel(event: nil)
        model.addEnd()
        #expect(model.draft.endsAt == nil, "no end before there's a start")
        model.pickStartDay(.now)
        model.addEnd()
        let start = try #require(model.draft.startsAt)
        #expect(model.draft.endsAt == start.addingTimeInterval(3 * 3600))
        let later = start.addingTimeInterval(86_400)
        model.setStart(later)
        #expect(model.draft.endsAt == later.addingTimeInterval(3 * 3600))
        model.removeEnd()
        #expect(model.draft.endsAt == nil)
    }

    @Test func anUntouchedNewEventIsCanopyGreenAndGreyKeepsTheHue() {
        let model = EventEditorModel(event: nil)
        #expect(model.draft.themeHue == nil && !model.draft.themeGrayscale)
        model.draft.theme = .hue(300)
        model.draft.theme = .grayscale
        #expect(model.draft.themeHue == 300 && model.draft.themeGrayscale)
        model.draft.theme = ThemeSliderScale.theme(at: ThemeSliderScale.greySteps + 300)
        #expect(model.draft.theme == .hue(300) && !model.draft.themeGrayscale)
    }

    @Test func matchPhotoUsesTheSavedCoversColor() {
        let model = EventEditorModel(event: PreviewData.event(MockEvents.supperClubId))
        #expect(model.coverMatch == .hue(45) && model.draft.theme == .hue(30))
        model.matchPhoto()
        #expect(model.draft.theme == .hue(45))
        model.removeCover()
        #expect(model.coverMatch == nil && !model.hasCover)
    }

    @Test func attendingSummaryAndOrder() {
        var counts = RSVPCounts(going: 4, maybe: 2, notGoing: 1, invited: nil, waitlisted: 3)
        counts.guests = GuestCounts(going: 2, maybe: 1, waitlisted: 0)
        #expect(Attending.summary(counts) == "4 Going · 2 Maybe · 3 Waitlist · +3 guests")
        #expect(Attending.summary(RSVPCounts()) == "0 Going · 0 Maybe")
        let p = MockPeople.self
        let guests = [p.ana, p.ben, p.chloe].map { Guest(person: $0, status: .going, guests: 0, guestsOverLimit: false) }
            + [Guest(person: p.diego, status: .maybe, guests: 0, guestsOverLimit: false),
               Guest(person: p.elif, status: .notGoing, guests: 0, guestsOverLimit: false)]
        #expect(Attending.people(friends: [p.ben], guests: guests).map(\.id) == [p.ben, p.chloe, p.ana, p.diego].map(\.id))
    }
}
