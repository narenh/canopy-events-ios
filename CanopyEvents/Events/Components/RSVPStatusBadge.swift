import SwiftUI

/// Someone's RSVP status as a small tag: "Going", "Waitlist", ...
struct RSVPStatusBadge: View {
    let status: RSVPStatus

    var body: some View {
        TagLabel(title: title, systemImage: status.systemImage, tint: tint)
    }

    private var title: String {
        status == .waitlisted ? "Waitlist" : status.title
    }

    private var tint: Color {
        switch status {
        case .going: .accentColor
        case .maybe: .yellow
        case .notGoing: Palette.danger
        case .waitlisted: .orange
        case .invited: Palette.link
        case .removed: Palette.muted
        }
    }
}

#Preview {
    VStack(alignment: .leading) {
        ForEach(RSVPStatus.allCases, id: \.self) { RSVPStatusBadge(status: $0) }
    }
    .padding()
    .preferredColorScheme(.dark)
}
