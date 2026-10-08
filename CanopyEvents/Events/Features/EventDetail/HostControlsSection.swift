import SwiftUI

/// What hosts see instead of the RSVP buttons: "Share link" and "Invite"
/// side by side (while the event is on), then "Edit" with a ⋯ menu. The
/// creator's menu: Co-hosts…, Lists…, Show list QR (once a list is on),
/// Make a new link…, Cancel or Bring back event, and Delete event… last.
/// A co-host's: Lists…, Show list QR, Step down.
struct HostControlsSection: View {
    let event: Event
    /// A line to show after something was done ("New link made...").
    var notice: String?
    let onInvite: () -> Void
    let onEdit: () -> Void
    let onCohosts: () -> Void
    /// "Lists…": put your lists on the event, or take them off.
    var onLists: () -> Void = {}
    /// "Show list QR": the lists on the event as big QR codes.
    var onShowListQR: () -> Void = {}
    let onAction: (HostAction) -> Void

    @Environment(\.eventAccent) private var accent

    private var phase: EventPhase { EventPhase(event: event) }
    private var isCreator: Bool { event.viewer?.isCreator == true }

    var body: some View {
        VStack(alignment: .leading, spacing: Spacing.medium) {
            Text(isCreator ? "Hosting" : "Co-hosting")
                .font(Typography.sectionTitle)
                .accessibilityAddTraits(.isHeader)
            if phase == .cancelled {
                Text(isCreator ? "This event is cancelled. Bring it back from the ⋯ menu." : "This event is cancelled. Only the person who made it can bring it back.")
                    .foregroundStyle(Palette.danger)
            } else if phase == .over {
                Text("This event has ended.")
                    .foregroundStyle(Palette.muted)
            }
            if let notice {
                Text(notice)
                    .font(.subheadline)
                    .foregroundStyle(accent.text)
            }
            if phase.isOpen {
                HStack(spacing: Spacing.small) {
                    ShareLink(item: event.url, subject: Text(event.title)) {
                        wide("Share link", systemImage: "square.and.arrow.up")
                    }
                    .accentProminentButtonStyle()
                    Button(action: onInvite) { wide("Invite", systemImage: "person.badge.plus") }
                        .glassButtonStyle()
                }
            }
            HStack(spacing: Spacing.small) {
                Button(action: onEdit) { wide("Edit", systemImage: "pencil") }
                    .glassButtonStyle()
                Menu { menuItems } label: {
                    Image(systemName: "ellipsis")
                        .font(Typography.button)
                        .frame(width: 32)
                        .padding(.vertical, Spacing.xSmall)
                }
                .glassButtonStyle()
                .accessibilityLabel("More actions")
            }
        }
        .controlSize(.large)
        .glassCard()
    }

    @ViewBuilder private var menuItems: some View {
        if isCreator {
            Button("Co-hosts…", systemImage: "person.2", action: onCohosts)
            listItems
            if phase.isOpen {
                Button("Make a new link…", systemImage: "link") { onAction(.newLink) }
            }
            if phase == .cancelled {
                Button("Bring back event", systemImage: "arrow.uturn.backward") { onAction(.bringBack) }
            } else if phase.isOpen {
                Button("Cancel event", systemImage: "xmark.circle") { onAction(.cancel) }
            }
            Section {
                Button("Delete event…", systemImage: "trash", role: .destructive) { onAction(.delete) }
            }
        } else {
            listItems
            Button("Step down as co-host", systemImage: "person.badge.minus", role: .destructive) { onAction(.stepDown) }
        }
    }

    @ViewBuilder private var listItems: some View {
        Button("Lists…", systemImage: "list.bullet", action: onLists)
        if !(event.hostLists ?? []).isEmpty {
            Button("Show list QR", systemImage: "qrcode", action: onShowListQR)
        }
    }

    private func wide(_ title: String, systemImage: String) -> some View {
        Label(title, systemImage: systemImage)
            .font(Typography.button)
            .lineLimit(1)
            .minimumScaleFactor(0.8)
            .frame(maxWidth: .infinity)
    }
}

#Preview {
    ScrollView {
        VStack {
            HostControlsSection(event: PreviewData.event(MockEvents.gameNightId), onInvite: {}, onEdit: {}, onCohosts: {}, onAction: { _ in })
            HostControlsSection(event: PreviewData.event(MockEvents.birthdayId, as: MockPeople.maya), notice: "New link made.",
                                onInvite: {}, onEdit: {}, onCohosts: {}, onAction: { _ in })
        }
        .padding()
    }
    .canopyScreen(theme: .hue(300))
}
