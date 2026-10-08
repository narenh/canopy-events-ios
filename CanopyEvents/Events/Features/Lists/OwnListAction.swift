/// The asks-first actions on one of your lists, with what each
/// confirmation says (the web's words, public/copy.js `lists`).
enum OwnListAction: Hashable, Identifiable {
    case resetLink
    case delete
    case remove(ListMember)

    var id: Self { self }

    func title(list: String) -> String {
        switch self {
        case .resetLink: "Make a new link for \(list)?"
        case .delete: "Delete \(list)?"
        case .remove(let member): "Take \(member.person.fullName) off \(list)?"
        }
    }

    var message: String {
        switch self {
        case .resetLink: "The old link and QR code stop working. Everyone on it stays."
        case .delete: "Its link stops working and it comes off your events. Invitations already sent stay."
        case .remove: "They won't be told."
        }
    }

    var confirmLabel: String {
        switch self {
        case .resetLink: "Make a new link"
        case .delete: "Delete list"
        case .remove: "Remove"
        }
    }
}
