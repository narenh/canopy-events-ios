import SwiftUI

/// "8 going · 2 maybe · 1 waitlist": always shown, even when the names
/// on a guest list are hidden.
struct RSVPCountsView: View {
    let counts: RSVPCounts

    var body: some View {
        Text(summary)
            .font(.subheadline)
            .foregroundStyle(Palette.muted)
    }

    private var summary: String {
        var parts = ["\(counts.going) going"]
        if counts.maybe > 0 { parts.append("\(counts.maybe) maybe") }
        if counts.waitlisted > 0 { parts.append("\(counts.waitlisted) on the waitlist") }
        if counts.notGoing > 0 { parts.append("\(counts.notGoing) can't go") }
        return parts.joined(separator: " · ")
    }
}

#Preview {
    RSVPCountsView(counts: PreviewData.event(MockEvents.gameNightId).counts)
        .padding()
        .preferredColorScheme(.dark)
}
