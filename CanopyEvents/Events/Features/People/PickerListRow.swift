import SwiftUI

/// One of your lists in the invite sheet, with "Invite all <n>" (its
/// people not on the event yet): a toggle, prominent once they're all
/// picked, and pressing it again unpicks them. "All invited" when there's
/// nobody left.
struct InviteListRow: View {
    let list: InvitePicker.PickList
    /// Its people who could be picked.
    let pickable: Int
    let isAllPicked: Bool
    let onToggle: () -> Void

    var body: some View {
        HStack(spacing: Spacing.medium) {
            Image(systemName: "list.bullet")
                .font(.title3)
                .foregroundStyle(Palette.muted)
                .frame(width: 40)
                .accessibilityHidden(true)
            VStack(alignment: .leading, spacing: Spacing.xxSmall) {
                Text(list.name)
                Text(InvitePicker.count(list.memberIds.count))
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }
            .accessibilityElement(children: .combine)
            Spacer(minLength: 0)
            if pickable > 0 {
                Group {
                    if isAllPicked {
                        Button(action: onToggle) { label }.accentProminentButtonStyle()
                    } else {
                        Button(action: onToggle) { label }.glassButtonStyle()
                    }
                }
                .accessibilityAddTraits(isAllPicked ? .isSelected : [])
                .accessibilityHint(isAllPicked ? "Unpicks them" : "")
            } else {
                Text("ALL INVITED")
                    .font(Typography.tag)
                    .tracking(0.4)
                    .padding(.horizontal, 9)
                    .padding(.vertical, 3)
                    .overlay { RoundedRectangle(cornerRadius: 8).strokeBorder(.white.opacity(0.55), lineWidth: 1) }
                    .accessibilityLabel("All invited")
            }
        }
    }

    private var label: some View {
        Text("Invite all \(pickable)")
            .font(.subheadline.weight(.bold))
            .lineLimit(1)
    }
}

#Preview {
    List {
        InviteListRow(list: .init(id: "a", name: "Drag Race", memberIds: Array(repeating: "x", count: 20)), pickable: 17, isAllPicked: false) {}
        InviteListRow(list: .init(id: "b", name: "Climbing", memberIds: ["a", "b", "c"]), pickable: 3, isAllPicked: true) {}
        InviteListRow(list: .init(id: "c", name: "Book club", memberIds: ["a"]), pickable: 0, isAllPicked: false) {}
    }
    .canopyScreen()
}
