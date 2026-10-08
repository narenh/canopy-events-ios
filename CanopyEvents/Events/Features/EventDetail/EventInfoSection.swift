import SwiftUI

/// When and where, plus the description and how full it is.
struct EventInfoSection: View {
    let event: Event

    var body: some View {
        VStack(alignment: .leading, spacing: Spacing.medium) {
            Label(EventDateFormatter.range(for: event), systemImage: "calendar")
            if let place = event.locationName {
                Label {
                    VStack(alignment: .leading) {
                        Text(place)
                        if let address = event.locationAddress {
                            Text(address)
                                .font(.subheadline)
                                .foregroundStyle(Palette.muted)
                        } else if event.locationAddressHidden {
                            Text("Sign in to see the address")
                                .font(.subheadline)
                                .foregroundStyle(Palette.muted)
                        }
                    }
                } icon: {
                    Image(systemName: "mappin.and.ellipse")
                }
            }
            if let spotsLeft = event.spotsLeft, let capacity = event.capacity {
                Label(spotsLeft > 0 ? "\(spotsLeft) of \(capacity) spots left" : "Full · waitlist open",
                      systemImage: "person.3")
            }
            if let description = event.description {
                Text(description)
                    .foregroundStyle(Palette.muted)
            }
        }
        .glassCard()
    }
}

#Preview {
    ScrollView {
        VStack {
            EventInfoSection(event: PreviewData.event(MockEvents.rooftopId))
            EventInfoSection(event: PreviewData.event(MockEvents.galleryId))
            EventInfoSection(event: PreviewData.event(MockEvents.supperClubId))
        }
        .padding()
    }
    .canopyScreen()
    .preferredColorScheme(.dark)
}
