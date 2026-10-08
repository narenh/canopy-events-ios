import SwiftUI

/// What hosts see instead of RSVP buttons: invite friends and edit.
struct HostToolsSection: View {
    let event: Event
    let onInvite: () -> Void
    let onEdit: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: Spacing.medium) {
            SectionHeader(title: event.viewer?.role == .cohost ? "You're co-hosting" : "You're hosting")
            HStack(spacing: Spacing.small) {
                Button("Invite friends", systemImage: "person.badge.plus", action: onInvite)
                    .buttonStyle(.glassProminent)
                    .disabled(event.isCancelled || event.isOver)
                Button("Edit", systemImage: "pencil", action: onEdit)
                    .buttonStyle(.glass)
            }
        }
        .glassCard()
    }
}

#Preview {
    HostToolsSection(event: PreviewData.event(MockEvents.birthdayId), onInvite: {}, onEdit: {})
        .padding()
        .canopyScreen()
        .preferredColorScheme(.dark)
}
