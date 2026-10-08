import SwiftUI

/// Answering with plus-ones: pick going, maybe or can't go, and how many
/// guests you're bringing (up to what the host allows). Warns when going
/// would land you on the waitlist. Saving is up to the caller.
struct RSVPSheet: View {
    let event: Event
    let onSave: (RSVPStatus, Int) -> Void

    @Environment(\.dismiss) private var dismiss
    @State private var status: RSVPStatus
    @State private var guests: Int

    init(event: Event, status: RSVPStatus, onSave: @escaping (RSVPStatus, Int) -> Void) {
        self.event = event
        self.onSave = onSave
        _status = State(initialValue: status == .waitlisted ? .going : status)
        _guests = State(initialValue: min(event.viewer?.rsvp?.guests ?? 0, event.guestsAllowed))
    }

    var body: some View {
        NavigationStack {
            Form {
                Picker("Your answer", selection: $status) {
                    ForEach(RSVPStatus.answers, id: \.self) { Text($0.title).tag($0) }
                }
                .pickerStyle(.segmented)
                .listRowBackground(Color.clear)

                if status != .notGoing && event.guestsAllowed > 0 {
                    Section {
                        Stepper("Bringing \(guests) \(guests == 1 ? "guest" : "guests")",
                                value: $guests, in: 0...event.guestsAllowed)
                    } footer: {
                        Text("The host allows up to \(event.guestsAllowed) per RSVP.")
                    }
                }

                if status == .going && event.isFull && event.myStatus != .going {
                    WaitlistNotice(isOnWaitlist: event.myStatus == .waitlisted)
                }
            }
            .navigationTitle(event.title)
            .inlineNavigationTitle()
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel", role: .cancel) { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save", role: .confirm) {
                        onSave(status, status == .notGoing ? 0 : guests)
                        dismiss()
                    }
                }
            }
        }
        .presentationDetents([.medium])
    }
}

#Preview("Plus-ones") {
    RSVPSheet(event: PreviewData.event(MockEvents.rooftopId), status: .going) { _, _ in }
        .preferredColorScheme(.dark)
}

#Preview("Full, will waitlist") {
    RSVPSheet(event: PreviewData.event(MockEvents.supperClubId, as: MockPeople.sam), status: .going) { _, _ in }
        .preferredColorScheme(.dark)
}
