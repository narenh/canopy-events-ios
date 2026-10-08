/// What an event detail is (the API's `EventDetail.type`), with how it's
/// drawn (docs/api.md, "Event details"). The server may add types: an
/// unknown one decodes as `unknown`, which the app doesn't show.
nonisolated enum EventDetailType: String, Codable, Hashable, CaseIterable, Sendable {
    case link
    case info
    case dressCode = "dress_code"
    case food
    case parking
    case accommodation
    case phone
    case unknown

    init(from decoder: any Decoder) throws {
        let raw = try decoder.singleValueContainer().decode(String.self)
        self = Self(rawValue: raw) ?? .unknown
    }

    /// The types a host can add, in the editor's chip order.
    static let addable: [EventDetailType] = [.link, .info, .dressCode, .food, .parking, .accommodation, .phone]

    /// The heading when `label` is nil; nil for the one-line types.
    var heading: String? {
        switch self {
        case .info: "Info"
        case .dressCode: "Dress code"
        case .food: "Food"
        case .parking: "Parking"
        case .accommodation: "Where to stay"
        case .link, .phone, .unknown: nil
        }
    }

    var systemImage: String {
        switch self {
        case .link: "link"
        case .info: "info.circle"
        case .dressCode: "tshirt"
        case .food: "fork.knife"
        case .parking: "parkingsign"
        case .accommodation: "bed.double"
        case .phone: "phone"
        case .unknown: "questionmark"
        }
    }

    /// The editor's chip: "+ Link", "+ Stay"...
    var chipTitle: String {
        switch self {
        case .link: "Link"
        case .info: "Info"
        case .dressCode: "Dress code"
        case .food: "Food"
        case .parking: "Parking"
        case .accommodation: "Stay"
        case .phone: "Phone"
        case .unknown: ""
        }
    }

    /// The editor's placeholder for the value (the web's).
    var placeholder: String {
        switch self {
        case .link: "Paste a link"
        case .info: "Anything else people should know"
        case .dressCode: "What to wear"
        case .food: "What's on the menu, or what to bring"
        case .parking: "Where to park"
        case .accommodation: "Where people can stay"
        case .phone: "Phone number"
        case .unknown: ""
        }
    }

    /// Hidden from someone signed out (or removed), like the address.
    var isPrivate: Bool { self == .parking || self == .accommodation || self == .phone }
}
