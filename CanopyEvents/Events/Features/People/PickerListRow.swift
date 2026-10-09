import SwiftUI

/// One of your lists in a picker, with "Invite all <n>" ("Add all <n>"),
/// its people not there yet: a toggle, prominent once they're all picked,
/// and pressing it again unpicks them. "All invited" ("All on it") when
/// there's nobody left.
struct PickerListRow: View {
    let kind: PeoplePicker.Kind
    let list: PeoplePicker.PickList
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
                Text(PeoplePicker.count(list.memberIds.count))
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
                PlainTag(title: kind.allDone)
            }
        }
    }

    private var label: some View {
        Text(kind.all(pickable))
            .font(.subheadline.weight(.bold))
            .lineLimit(1)
    }
}

#Preview {
    List {
        PickerListRow(kind: .invite, list: .init(id: "a", name: "Drag Race", memberIds: Array(repeating: "x", count: 20)), pickable: 17, isAllPicked: false) {}
        PickerListRow(kind: .invite, list: .init(id: "b", name: "Climbing", memberIds: ["a", "b", "c"]), pickable: 3, isAllPicked: true) {}
        PickerListRow(kind: .invite, list: .init(id: "c", name: "Book club", memberIds: ["a"]), pickable: 0, isAllPicked: false) {}
        PickerListRow(kind: .list, list: .init(id: "d", name: "Climbing", memberIds: ["a", "b"]), pickable: 2, isAllPicked: false) {}
        PickerListRow(kind: .list, list: .init(id: "e", name: "Book club", memberIds: ["a"]), pickable: 0, isAllPicked: false) {}
    }
    .canopyScreen()
}
