import Foundation

/// One of an event's extra fields (the API's `EventDetail`): a link, the
/// dress code, parking... in the host's order.
nonisolated struct EventDetail: Codable, Hashable, Sendable {
    var type: EventDetailType
    /// A link's text, a phone's label, or a heading in place of the type's.
    var label: String?
    /// An http(s) address, a phone number as typed, or plain text (line
    /// breaks kept, never turned into links).
    var value: String
    /// Where tapping goes: a link's address or `tel:` and digits; nil for text.
    var href: String?

    /// The heading for a two-line detail: `label`, else the type's.
    var heading: String? { label ?? type.heading }

    /// The link's text: its label, or its address shortened as the web
    /// does (no scheme, no leading www., no trailing slash; past 48
    /// characters, 47 and "…").
    var linkText: String {
        if let label, !label.isEmpty { return label }
        var text = value
        for prefix in ["https://", "http://"] where text.lowercased().hasPrefix(prefix) {
            text = String(text.dropFirst(prefix.count))
        }
        if text.lowercased().hasPrefix("www.") { text = String(text.dropFirst(4)) }
        if text.hasSuffix("/") { text = String(text.dropLast()) }
        return text.count > 48 ? String(text.prefix(47)) + "…" : text
    }

    /// Only a link's http(s) address or a phone's `tel:`; nothing else opens.
    var url: URL? {
        guard let href, let url = URL(string: href), let scheme = url.scheme?.lowercased() else { return nil }
        switch type {
        case .link: return scheme == "http" || scheme == "https" ? url : nil
        case .phone: return scheme == "tel" ? url : nil
        default: return nil
        }
    }
}
