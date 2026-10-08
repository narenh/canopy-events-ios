import SwiftUI

/// A person in a list: avatar, full name, and an optional detail line.
struct PersonRow<Accessory: View>: View {
    let person: Person
    var detail: String?
    @ViewBuilder var accessory: Accessory

    var body: some View {
        HStack(spacing: Spacing.medium) {
            Avatar(person: person)
            VStack(alignment: .leading, spacing: Spacing.xxSmall) {
                Text(person.fullName)
                if let detail {
                    Text(detail)
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }
            }
            Spacer(minLength: 0)
            accessory
        }
    }
}

extension PersonRow where Accessory == EmptyView {
    init(person: Person, detail: String? = nil) {
        self.init(person: person, detail: detail) { EmptyView() }
    }
}

#Preview {
    List {
        PersonRow(person: MockPeople.ana, detail: "Host")
        PersonRow(person: MockPeople.ben)
        PersonRow(person: MockPeople.hana, detail: "+2 guests") {
            RSVPStatusBadge(status: .going)
        }
    }
    .canopyScreen()
    .preferredColorScheme(.dark)
}
