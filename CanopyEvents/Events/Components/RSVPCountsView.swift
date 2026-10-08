import SwiftUI

/// "8 going · 2 maybe · 1 on the waitlist": always shown, even when the
/// names on a guest list are hidden. Going, maybe and waitlist count
/// plus-ones too (`counts.total`); can't go is people.
struct RSVPCountsView: View {
    let counts: RSVPCounts

    var body: some View {
        Text(summary)
            .font(.subheadline)
            .foregroundStyle(Palette.muted)
    }

    private var summary: String {
        var parts = ["\(counts.total.going) going"]
        if counts.total.maybe > 0 { parts.append("\(counts.total.maybe) maybe") }
        if counts.total.waitlisted > 0 { parts.append("\(counts.total.waitlisted) on the waitlist") }
        if counts.notGoing > 0 { parts.append("\(counts.notGoing) can't go") }
        return parts.joined(separator: " · ")
    }
}

#Preview {
    RSVPCountsView(counts: PreviewData.event(MockEvents.gameNightId).counts)
        .padding()
        .preferredColorScheme(.dark)
}
