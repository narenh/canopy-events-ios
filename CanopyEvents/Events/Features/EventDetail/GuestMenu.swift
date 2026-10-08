import SwiftUI

/// A guest's ⋯ on their RSVP card's heading line (the web's): Mute or
/// Unmute, Remove me from event, and, per host, Opt out of invites from
/// them (or Allow invites again).
struct GuestMenu: View {
    let event: Event
    /// Hosts whose invitations you've opted out of.
    let optedOut: Set<Person.ID>
    let onMute: (Bool) -> Void
    let onLeave: () -> Void
    let onOptOut: (Person, Bool) -> Void

    var body: some View {
        Menu {
            if event.viewer?.muted == true {
                Button("Unmute", systemImage: "bell") { onMute(false) }
            } else {
                Button("Mute", systemImage: "bell.slash") { onMute(true) }
            }
            Section {
                ForEach(event.hosts) { host in
                    if optedOut.contains(host.id) {
                        Button("Allow invites from \(host.person.firstName)", systemImage: "envelope") {
                            onOptOut(host.person, false)
                        }
                    } else {
                        Button("Opt out of invites from \(host.person.firstName)", systemImage: "envelope.badge.shield.half.filled") {
                            onOptOut(host.person, true)
                        }
                    }
                }
            }
            Section {
                Button("Remove me from event", systemImage: "rectangle.portrait.and.arrow.right", role: .destructive, action: onLeave)
            }
        } label: {
            Image(systemName: "ellipsis")
                .font(.body.weight(.semibold))
                .frame(width: 32, height: 32)
                .contentShape(.rect)
        }
        .foregroundStyle(.white)
        .accessibilityLabel("More")
    }
}
