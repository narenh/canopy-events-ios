import SwiftUI

/// What you see when the host shows names only to people who've
/// answered and you haven't yet: just the counts.
struct HiddenGuestListView: View {
    let counts: RSVPCounts

    var body: some View {
        ContentUnavailableView {
            Label("Guest list hidden", systemImage: "eye.slash")
        } description: {
            VStack(spacing: Spacing.small) {
                Text("The host shows who's coming once you've RSVP'd.")
                RSVPCountsView(counts: counts)
            }
        }
    }
}

#Preview {
    HiddenGuestListView(counts: PreviewData.event(MockEvents.hikeId).counts)
        .canopyScreen()
        .preferredColorScheme(.dark)
}
