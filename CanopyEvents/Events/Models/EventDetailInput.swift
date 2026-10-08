import Foundation

/// A detail as the editor sends it (the API's `EventDetailInput`): the
/// server checks and tidies it (a link without a scheme gets https).
nonisolated struct EventDetailInput: Codable, Hashable, Sendable, Identifiable {
    /// For the editor's rows only; not sent.
    var id = UUID().uuidString
    var type: EventDetailType
    var label: String?
    var value: String

    enum CodingKeys: String, CodingKey { case type, label, value }

    init(type: EventDetailType, label: String? = nil, value: String) {
        self.type = type
        self.label = label
        self.value = value
    }

    init(_ detail: EventDetail) {
        self.init(type: detail.type, label: detail.label, value: detail.value)
    }
}
