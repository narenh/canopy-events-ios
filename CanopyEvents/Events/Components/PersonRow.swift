import SwiftUI

/// A person in a list: avatar, full name, and an optional detail line. A
/// friend made by friend link has a two-people icon at the start of that
/// line, read as "Friend link".
struct PersonRow<Accessory: View>: View {
    let person: Person
    var detail: String?
    var isFriendLink = false
    @ViewBuilder var accessory: Accessory

    var body: some View {
        HStack(spacing: Spacing.medium) {
            Avatar(person: person)
            VStack(alignment: .leading, spacing: Spacing.xxSmall) {
                Text(person.fullName)
                if isFriendLink || detail != nil {
                    detailLine
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }
            }
            Spacer(minLength: 0)
            accessory
        }
    }

    @ViewBuilder private var detailLine: some View {
        let words = detail ?? ""
        if isFriendLink {
            let icon = Image(systemName: "person.2")
            Group {
                if words.isEmpty { Text(icon) } else { Text("\(icon) \(words)") }
            }
            .accessibilityLabel(["Friend link", words].filter { !$0.isEmpty }.joined(separator: ", "))
        } else {
            Text(words)
        }
    }
}

extension PersonRow where Accessory == EmptyView {
    init(person: Person, detail: String? = nil, isFriendLink: Bool = false) {
        self.init(person: person, detail: detail, isFriendLink: isFriendLink) { EmptyView() }
    }
}

#Preview {
    List {
        PersonRow(person: MockPeople.ana, detail: "Host")
        PersonRow(person: MockPeople.ben)
        PersonRow(person: MockPeople.theo, detail: "2 events together", isFriendLink: true)
        PersonRow(person: MockPeople.ines, isFriendLink: true)
        PersonRow(person: MockPeople.hana, detail: "+2 guests") {
            StatusBadge(kind: .status(.going))
        }
    }
    .canopyScreen()
    .preferredColorScheme(.dark)
}
